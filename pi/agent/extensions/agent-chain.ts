/**
 * Agent Chain — Sequential pipeline orchestrator
 *
 * Runs opinionated, repeatable agent workflows. Chains are defined in
 * .pi/agents/agent-chain.yaml — each chain is a sequence of agent steps
 * with prompt templates. The user's original prompt flows into step 1,
 * the output becomes $INPUT for step 2's prompt template, and so on.
 * $ORIGINAL is always the user's original prompt.
 *
 * The primary Pi agent has NO codebase tools — it can ONLY kick off the
 * pipeline via the `run_chain` tool. On boot you select a chain; the
 * agent decides when to run it based on the user's prompt.
 *
 * Agents maintain session context within a Pi session — re-running the
 * chain lets each agent resume where it left off.
 *
 * Commands:
 *   /chain             — switch active chain
 *   /chain-list        — list all available chains
 *   /chain-model       — set runtime model overrides per step
 *   /chain-answer      — answer pending clarification questions and resume
 *
 * Usage: pi -e extensions/agent-chain.ts
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { Text, truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";
import { spawn } from "child_process";
import { readFileSync, existsSync, readdirSync, mkdirSync, unlinkSync } from "fs";
import { join, resolve } from "path";
import { homedir } from "os";
//import { applyExtensionDefaults } from "./utils/themeMap.ts";

// ── Types ────────────────────────────────────────

interface ChainStep {
  agent: string;
  prompt: string;
  model?: string;  // per-step YAML model override
}

interface ChainDef {
  name: string;
  description: string;
  model?: string;  // chain-level YAML model override
  steps: ChainStep[];
}

interface AgentDef {
  name: string;
  description: string;
  tools: string;
  systemPrompt: string;
  /** Optional model override baked into the agent's frontmatter (e.g. "openrouter/anthropic/sonnet-4-6"). */
  model?: string;
}

interface StepState {
  agent: string;
  status: "pending" | "running" | "done" | "error";
  elapsed: number;
  lastWork: string;
  model: string;
}

interface ClarificationState {
  chainName: string;
  stepIndex: number;
  inputBeforeStep: string;
  originalPrompt: string;
  rounds: number;
  questions: string[];
}

interface ChainDecision {
  status: "READY" | "NEEDS_CLARIFICATION";
  questions: string[];
  assumptions: string[];
  cleanedOutput: string;
}

// ── Display Name Helper ──────────────────────────

function displayName(name: string): string {
  return name.split("-").map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(" ");
}

function shortModel(model: string): string {
  if (!model) return "—";
  const parts = model.split("/");
  return parts[parts.length - 1];
}

function formatTokens(value: number): string {
  return Math.round(value).toLocaleString("en-US");
}

// ── Shared Helpers ──────────────────────────────

function clean(value?: string): string | undefined {
  if (!value) return undefined;
  let trimmed = value.trim();
  if (!trimmed) return undefined;
  if ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
    (trimmed.startsWith("'") && trimmed.endsWith("'"))) {
    trimmed = trimmed.slice(1, -1).trim();
  }
  return trimmed || undefined;
}

const CHAIN_DECISION_OPEN = "<CHAIN_DECISION>";
const CHAIN_DECISION_CLOSE = "</CHAIN_DECISION>";
const MAX_CLARIFICATION_ROUNDS = 3;

const plannerClarificationContract = `

Before ending, append this block exactly once:
<CHAIN_DECISION>
status: READY | NEEDS_CLARIFICATION
questions:
- question 1
- question 2
assumptions_if_unanswered:
- assumption 1
</CHAIN_DECISION>

Rules:
- Ask at most 3 high-impact questions.
- Use NEEDS_CLARIFICATION only if answers materially change implementation.
- Use READY when you can proceed safely.
- Keep the normal planning output above this block.`;

function parseDecisionList(block: string, section: string): string[] {
  const sectionMatch = block.match(new RegExp(`${section}\\s*:\\s*([\\s\\S]*?)(?=\\n\\s*[a-zA-Z_]+\\s*:|$)`, "i"));
  if (!sectionMatch) return [];
  return sectionMatch[1]
    .split("\n")
    .map(l => l.trim())
    .filter(l => l.startsWith("-"))
    .map(l => l.replace(/^-\s*/, "").trim())
    .filter(Boolean);
}

function parseChainDecision(output: string): ChainDecision | undefined {
  const start = output.indexOf(CHAIN_DECISION_OPEN);
  const end = output.indexOf(CHAIN_DECISION_CLOSE);
  if (start === -1 || end === -1 || end < start) return undefined;

  const block = output.slice(start + CHAIN_DECISION_OPEN.length, end).trim();
  const cleanedOutput = (output.slice(0, start) + output.slice(end + CHAIN_DECISION_CLOSE.length)).trim();

  const statusMatch = block.match(/status\s*:\s*([A-Z_]+)/i);
  const rawStatus = statusMatch?.[1]?.toUpperCase();
  if (rawStatus !== "READY" && rawStatus !== "NEEDS_CLARIFICATION") return undefined;

  return {
    status: rawStatus,
    questions: parseDecisionList(block, "questions"),
    assumptions: parseDecisionList(block, "assumptions_if_unanswered"),
    cleanedOutput,
  };
}

function injectPlannerContract(step: ChainStep, prompt: string): string {
  if (step.agent.toLowerCase() !== "planner") return prompt;
  return prompt.includes(CHAIN_DECISION_OPEN) ? prompt : `${prompt}${plannerClarificationContract}`;
}

// ── Chain YAML Parser ────────────────────────────

function parseChainYaml(raw: string): ChainDef[] {
  const chains: ChainDef[] = [];
  let current: ChainDef | null = null;
  let currentStep: ChainStep | null = null;

  for (const line of raw.split("\n")) {
    // Chain name: top-level key
    const chainMatch = line.match(/^(\S[^:]*):$/);
    if (chainMatch) {
      if (current && currentStep) {
        current.steps.push(currentStep);
        currentStep = null;
      }
      current = { name: chainMatch[1].trim(), description: "", steps: [] };
      chains.push(current);
      continue;
    }

    // Chain description
    const descMatch = line.match(/^\s+description:\s+(.+)$/);
    if (descMatch && current && !currentStep) {
      let desc = descMatch[1].trim();
      if ((desc.startsWith('"') && desc.endsWith('"')) ||
        (desc.startsWith("'") && desc.endsWith("'"))) {
        desc = desc.slice(1, -1);
      }
      current.description = desc;
      continue;
    }

    // Chain-level or per-step model override
    const modelMatch = line.match(/^\s+model:\s+(.+)$/);
    if (modelMatch) {
      const m = clean(modelMatch[1]);
      if (currentStep) {
        currentStep.model = m;   // per-step model
      } else if (current) {
        current.model = m;       // chain-level model
      }
      continue;
    }

    // "steps:" label — skip
    if (line.match(/^\s+steps:\s*$/) && current) {
      continue;
    }

    // Step agent line
    const agentMatch = line.match(/^\s+-\s+agent:\s+(.+)$/);
    if (agentMatch && current) {
      if (currentStep) {
        current.steps.push(currentStep);
      }
      currentStep = { agent: agentMatch[1].trim(), prompt: "" };
      continue;
    }

    // Step prompt line
    const promptMatch = line.match(/^\s+prompt:\s+(.+)$/);
    if (promptMatch && currentStep) {
      let prompt = promptMatch[1].trim();
      if ((prompt.startsWith('"') && prompt.endsWith('"')) ||
        (prompt.startsWith("'") && prompt.endsWith("'"))) {
        prompt = prompt.slice(1, -1);
      }
      prompt = prompt.replace(/\\n/g, "\n");
      currentStep.prompt = prompt;
      continue;
    }
  }

  if (current && currentStep) {
    current.steps.push(currentStep);
  }

  return chains;
}

// ── Frontmatter Parser ───────────────────────────

function parseAgentFile(filePath: string): AgentDef | null {
  try {
    const raw = readFileSync(filePath, "utf-8");
    const match = raw.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
    if (!match) return null;

    const frontmatter: Record<string, string> = {};
    for (const line of match[1].split("\n")) {
      const idx = line.indexOf(":");
      if (idx > 0) {
        frontmatter[line.slice(0, idx).trim()] = line.slice(idx + 1).trim();
      }
    }

    const name = clean(frontmatter.name);
    if (!name) return null;

    const description = clean(frontmatter.description) ?? "";
    const tools = clean(frontmatter.tools) ?? "read,grep,find,ls";
    const model = clean(frontmatter.model);

    return {
      name,
      description,
      tools,
      model,
      systemPrompt: match[2].trim(),
    };
  } catch {
    return null;
  }
}

function scanAgentDirs(cwd: string): Map<string, AgentDef> {
  const dirs = [
    join(cwd, "agents"),
    join(cwd, ".claude", "agents"),
    join(cwd, ".pi", "agents"),
    join(homedir(), ".pi", "agents"),
  ];

  const agents = new Map<string, AgentDef>();

  for (const dir of dirs) {
    if (!existsSync(dir)) continue;
    try {
      for (const file of readdirSync(dir)) {
        if (!file.endsWith(".md")) continue;
        const fullPath = resolve(dir, file);
        const def = parseAgentFile(fullPath);
        if (def && !agents.has(def.name.toLowerCase())) {
          agents.set(def.name.toLowerCase(), def);
        }
      }
    } catch { }
  }

  return agents;
}

function resolveChainPath(cwd: string): string | null {
  const candidatePaths = [
    join(cwd, ".pi", "agents", "agent-chain.yaml"),
    join(cwd, ".claude", "agents", "agent-chain.yaml"),
    join(cwd, "agents", "agent-chain.yaml"),
    join(homedir(), ".pi", "agents", "agent-chain.yaml"),
  ];

  for (const path of candidatePaths) {
    if (existsSync(path)) return path;
  }

  return null;
}

// ── Extension ────────────────────────────────────

export default function (pi: ExtensionAPI) {
  let allAgents: Map<string, AgentDef> = new Map();
  let chains: ChainDef[] = [];
  let activeChain: ChainDef | null = null;
  let widgetCtx: any;
  let sessionDir = "";
  const agentSessions: Map<string, string | null> = new Map();

  // Per-step state for the active chain
  let stepStates: StepState[] = [];
  let pendingReset = false;

  // Runtime model overrides (session-scoped; do not modify YAML/frontmatter)
  let chainModelOverride: string | undefined;
  const stepModelOverrides: Map<number, string> = new Map();

  // Clarification loop state (session-scoped)
  let pendingClarification: ClarificationState | null = null;

  function loadChains(cwd: string) {
    sessionDir = join(cwd, ".pi", "agent-sessions");
    if (!existsSync(sessionDir)) {
      mkdirSync(sessionDir, { recursive: true });
    }

    allAgents = scanAgentDirs(cwd);

    agentSessions.clear();
    for (const [key] of allAgents) {
      const sessionFile = join(sessionDir, `chain-${key}.json`);
      agentSessions.set(key, existsSync(sessionFile) ? sessionFile : null);
    }

    const chainPath = resolveChainPath(cwd);
    if (chainPath) {
      try {
        chains = parseChainYaml(readFileSync(chainPath, "utf-8"));
      } catch {
        chains = [];
      }
    } else {
      chains = [];
    }
  }

  function getEffectiveStepModel(chain: ChainDef, step: ChainStep, stepIndex: number): string | undefined {
    const agentDef = allAgents.get(step.agent.toLowerCase());
    return stepModelOverrides.get(stepIndex) ?? chainModelOverride ?? step.model ?? chain.model ?? agentDef?.model;
  }

  function buildPendingStepStates(chain: ChainDef): StepState[] {
    return chain.steps.map((s, i) => ({
      agent: s.agent,
      status: "pending" as const,
      elapsed: 0,
      lastWork: "",
      model: getEffectiveStepModel(chain, s, i) ?? "",
    }));
  }

  function activateChain(chain: ChainDef) {
    activeChain = chain;
    pendingClarification = null;
    chainModelOverride = undefined;
    stepModelOverrides.clear();
    stepStates = buildPendingStepStates(chain);
    // Skip widget re-registration if reset is pending — let before_agent_start handle it
    if (!pendingReset) {
      updateWidget();
    }
  }

  // ── Card Rendering ──────────────────────────

  function renderCard(state: StepState, colWidth: number, theme: any): string[] {
    const w = colWidth - 2;
    const truncate = (s: string, max: number) => s.length > max ? s.slice(0, max - 3) + "..." : s;

    const statusColor = state.status === "pending" ? "dim"
      : state.status === "running" ? "accent"
        : state.status === "done" ? "success" : "error";
    const statusIcon = state.status === "pending" ? "○"
      : state.status === "running" ? "●"
        : state.status === "done" ? "✓" : "✗";

    const name = displayName(state.agent);
    const nameStr = theme.fg("accent", theme.bold(truncate(name, w)));
    const nameVisible = Math.min(name.length, w);

    const modelText = shortModel(state.model);
    const modelStr = theme.fg("dim", truncate(modelText, w));
    const modelVisible = Math.min(modelText.length, w);

    const statusStr = `${statusIcon} ${state.status}`;
    const timeStr = state.status !== "pending" ? ` ${Math.round(state.elapsed / 1000)}s` : "";
    const statusLine = theme.fg(statusColor, statusStr + timeStr);
    const statusVisible = statusStr.length + timeStr.length;

    const workRaw = state.lastWork || "";
    const workText = workRaw ? truncate(workRaw, Math.min(50, w - 1)) : "";
    const workLine = workText ? theme.fg("muted", workText) : theme.fg("dim", "—");
    const workVisible = workText ? workText.length : 1;

    const top = "┌" + "─".repeat(w) + "┐";
    const bot = "└" + "─".repeat(w) + "┘";
    const border = (content: string, visLen: number) =>
      theme.fg("dim", "│") + content + " ".repeat(Math.max(0, w - visLen)) + theme.fg("dim", "│");

    return [
      theme.fg("dim", top),
      border(" " + nameStr, 1 + nameVisible),
      border(" " + modelStr, 1 + modelVisible),
      border(" " + statusLine, 1 + statusVisible),
      border(" " + workLine, 1 + workVisible),
      theme.fg("dim", bot),
    ];
  }

  function updateWidget() {
    if (!widgetCtx) return;

    widgetCtx.ui.setWidget("agent-chain", (_tui: any, theme: any) => {
      const text = new Text("", 0, 1);

      return {
        render(width: number): string[] {
          if (!activeChain || stepStates.length === 0) {
            text.setText(theme.fg("dim", "No chain active. Use /chain to select one."));
            return text.render(width);
          }

          const arrowWidth = 5; // " ──▶ "
          const cols = stepStates.length;
          const totalArrowWidth = arrowWidth * (cols - 1);
          const colWidth = Math.max(12, Math.floor((width - totalArrowWidth) / cols));
          const arrowRow = 3; // middle of 6-line card (0-indexed)

          const cards = stepStates.map(s => renderCard(s, colWidth, theme));
          const cardHeight = cards[0].length;
          const outputLines: string[] = [];

          for (let line = 0; line < cardHeight; line++) {
            let row = cards[0][line];
            for (let c = 1; c < cols; c++) {
              if (line === arrowRow) {
                row += theme.fg("dim", " ──▶ ");
              } else {
                row += " ".repeat(arrowWidth);
              }
              row += cards[c][line];
            }
            outputLines.push(row);
          }

          text.setText(outputLines.join("\n"));
          return text.render(width);
        },
        invalidate() {
          text.invalidate();
        },
      };
    });
  }

  // ── Run Agent (subprocess) ──────────────────

  function runAgent(
    agentDef: AgentDef,
    task: string,
    stepIndex: number,
    ctx: any,
    modelOverride?: string,
  ): Promise<{ output: string; exitCode: number; elapsed: number }> {
    const ctxModel = (ctx.model?.provider && ctx.model?.id)
      ? `${ctx.model.provider}/${ctx.model.id}`
      : undefined;
    // Priority: per-step/chain YAML override > agent .md frontmatter > runtime ctx > hardcoded default
    const model = modelOverride ?? agentDef.model ?? ctxModel ?? "openrouter/google/gemini-3-flash-preview";

    const agentKey = agentDef.name.toLowerCase().replace(/\s+/g, "-");
    const agentSessionFile = join(sessionDir, `chain-${agentKey}.json`);
    const hasSession = agentSessions.get(agentKey);

    const state = stepStates[stepIndex];
    state.model = model;

    const args = [
      "--mode", "json",
      "-p",
      "--no-extensions",
      "--model", model,
      "--tools", agentDef.tools,
      "--append-system-prompt", agentDef.systemPrompt,
      "--session", agentSessionFile,
    ];

    if (hasSession) {
      args.push("-c");
    }

    args.push(task);

    const textChunks: string[] = [];
    const startTime = Date.now();

    return new Promise((resolve) => {
      const proc = spawn("pi", args, {
        stdio: ["ignore", "pipe", "pipe"],
        env: { ...process.env },
      });

      const timer = setInterval(() => {
        state.elapsed = Date.now() - startTime;
        updateWidget();
      }, 1000);

      let buffer = "";

      proc.stdout!.setEncoding("utf-8");
      proc.stdout!.on("data", (chunk: string) => {
        buffer += chunk;
        const lines = buffer.split("\n");
        buffer = lines.pop() || "";
        for (const line of lines) {
          if (!line.trim()) continue;
          try {
            const event = JSON.parse(line);
            if (event.type === "message_update") {
              const delta = event.assistantMessageEvent;
              if (delta?.type === "text_delta") {
                textChunks.push(delta.delta || "");
                const full = textChunks.join("");
                const last = full.split("\n").filter((l: string) => l.trim()).pop() || "";
                state.lastWork = last;
                updateWidget();
              }
            }
          } catch { }
        }
      });

      proc.stderr!.setEncoding("utf-8");
      proc.stderr!.on("data", () => { });

      proc.on("close", (code) => {
        if (buffer.trim()) {
          try {
            const event = JSON.parse(buffer);
            if (event.type === "message_update") {
              const delta = event.assistantMessageEvent;
              if (delta?.type === "text_delta") textChunks.push(delta.delta || "");
            }
          } catch { }
        }

        clearInterval(timer);
        const elapsed = Date.now() - startTime;
        state.elapsed = elapsed;
        const output = textChunks.join("");
        state.lastWork = output.split("\n").filter((l: string) => l.trim()).pop() || "";

        if (code === 0) {
          agentSessions.set(agentKey, agentSessionFile);
        }

        resolve({ output, exitCode: code ?? 1, elapsed });
      });

      proc.on("error", (err) => {
        clearInterval(timer);
        resolve({
          output: `Error spawning agent: ${err.message}`,
          exitCode: 1,
          elapsed: Date.now() - startTime,
        });
      });
    });
  }

  // ── Run Chain (sequential pipeline) ─────────

  async function runChain(
    task: string,
    ctx: any,
  ): Promise<{
    output: string;
    success: boolean;
    status: "done" | "error" | "needs_clarification";
    elapsed: number;
    clarification?: { stepIndex: number; stepAgent: string; questions: string[]; rounds: number; maxRounds: number };
  }> {
    if (!activeChain) {
      return { output: "No chain active", success: false, status: "error", elapsed: 0 };
    }

    const chainStart = Date.now();
    const resumeState = pendingClarification && pendingClarification.chainName === activeChain.name
      ? pendingClarification
      : null;

    // Clear and rebuild step states for the current run.
    stepStates = buildPendingStepStates(activeChain);

    const startStep = resumeState?.stepIndex ?? 0;
    for (let i = 0; i < startStep; i++) {
      stepStates[i].status = "done";
      stepStates[i].lastWork = "completed earlier";
    }

    pendingClarification = null;
    updateWidget();

    let input = resumeState
      ? `${resumeState.inputBeforeStep}\n\nUser clarifications:\n${task}`
      : task;
    const originalPrompt = resumeState?.originalPrompt ?? task;

    for (let i = startStep; i < activeChain.steps.length; i++) {
      const step = activeChain.steps[i];
      const stepInput = input;
      stepStates[i].status = "running";
      updateWidget();

      const resolvedPromptBase = step.prompt
        .replace(/\$INPUT/g, stepInput)
        .replace(/\$ORIGINAL/g, originalPrompt);
      const resolvedPrompt = injectPlannerContract(step, resolvedPromptBase);

      const agentDef = allAgents.get(step.agent.toLowerCase());
      if (!agentDef) {
        stepStates[i].status = "error";
        stepStates[i].lastWork = `Agent "${step.agent}" not found`;
        updateWidget();
        return {
          output: `Error at step ${i + 1}: Agent "${step.agent}" not found. Available: ${Array.from(allAgents.keys()).join(", ")}`,
          success: false,
          status: "error",
          elapsed: Date.now() - chainStart,
        };
      }

      // Priority: runtime step override > runtime chain override > YAML step > YAML chain
      const stepModelOverride = getEffectiveStepModel(activeChain, step, i);
      const result = await runAgent(agentDef, resolvedPrompt, i, ctx, stepModelOverride);

      if (result.exitCode !== 0) {
        stepStates[i].status = "error";
        updateWidget();
        return {
          output: `Error at step ${i + 1} (${step.agent}): ${result.output}`,
          success: false,
          status: "error",
          elapsed: Date.now() - chainStart,
        };
      }

      const decision = parseChainDecision(result.output);
      const stepOutput = decision?.cleanedOutput || result.output;

      if (decision?.status === "NEEDS_CLARIFICATION") {
        const baseRound = resumeState && i === resumeState.stepIndex ? resumeState.rounds : 0;
        const nextRound = baseRound + 1;

        // Prevent endless clarify loops — continue with assumptions on the final round.
        if (nextRound > MAX_CLARIFICATION_ROUNDS) {
          stepStates[i].status = "done";
          stepStates[i].lastWork = "max clarification rounds reached; proceeding with assumptions";
          updateWidget();
          input = stepOutput;
          continue;
        }

        const questions = decision.questions.length > 0
          ? decision.questions
          : ["Please clarify the requirements for this step so I can proceed safely."];

        stepStates[i].status = "pending";
        stepStates[i].lastWork = "awaiting clarification";
        updateWidget();

        pendingClarification = {
          chainName: activeChain.name,
          stepIndex: i,
          inputBeforeStep: stepInput,
          originalPrompt,
          rounds: nextRound,
          questions,
        };

        const assumptions = decision.assumptions.length > 0
          ? `\n\nAssumptions if unanswered:\n${decision.assumptions.map((a, idx) => `${idx + 1}. ${a}`).join("\n")}`
          : "";

        return {
          output:
            `Need clarification before continuing (step ${i + 1}: ${displayName(step.agent)}).\n\n` +
            questions.map((q, idx) => `${idx + 1}. ${q}`).join("\n") +
            assumptions +
            `\n\nUse the ask-user-question extension tool (whatever name it is registered under in this session) to ask these, then call run_chain again with the user's answer to continue from this step.`,
          success: false,
          status: "needs_clarification",
          elapsed: Date.now() - chainStart,
          clarification: {
            stepIndex: i,
            stepAgent: step.agent,
            questions,
            rounds: nextRound,
            maxRounds: MAX_CLARIFICATION_ROUNDS,
          },
        };
      }

      stepStates[i].status = "done";
      updateWidget();

      input = stepOutput;
    }

    return { output: input, success: true, status: "done", elapsed: Date.now() - chainStart };
  }

  function getModelRef(model: any): string {
    return `${model.provider}/${model.id}`;
  }

  async function selectModelRef(ctx: any, title: string): Promise<string | undefined> {
    const options = Array.from(new Set(ctx.modelRegistry.getAvailable().map((m: any) => getModelRef(m)))).sort();
    if (options.length === 0) {
      ctx.ui.notify("No available models found. Check auth/provider configuration.", "warning");
      return undefined;
    }
    return await ctx.ui.select(title, options);
  }

  // ── run_chain Tool ──────────────────────────

  pi.registerTool({
    name: "run_chain",
    label: "Run Chain",
    description: "Execute the active agent chain pipeline. Steps run sequentially and pass output forward. If a planner step needs clarification, the chain pauses, returns questions, and resumes on the next run_chain call.",
    parameters: Type.Object({
      task: Type.String({ description: "The task/prompt for the chain to process" }),
    }),

    async execute(_toolCallId, params, _signal, onUpdate, ctx) {
      const { task } = params as { task: string };

      if (onUpdate) {
        onUpdate({
          content: [{ type: "text", text: `Starting chain: ${activeChain?.name}...` }],
          details: { chain: activeChain?.name, task, status: "running" },
        });
      }

      const result = await runChain(task, ctx);

      const truncated = result.output.length > 8000
        ? result.output.slice(0, 8000) + "\n\n... [truncated]"
        : result.output;

      const status = result.status;
      const summary = `[chain:${activeChain?.name}] ${status} in ${Math.round(result.elapsed / 1000)}s`;

      return {
        content: [{ type: "text", text: `${summary}\n\n${truncated}` }],
        details: {
          chain: activeChain?.name,
          task,
          status,
          elapsed: result.elapsed,
          fullOutput: result.output,
          clarification: result.clarification,
        },
      };
    },

    renderCall(args, theme) {
      const task = (args as any).task || "";
      const preview = task.length > 60 ? task.slice(0, 57) + "..." : task;
      return new Text(
        theme.fg("toolTitle", theme.bold("run_chain ")) +
        theme.fg("accent", activeChain?.name || "?") +
        theme.fg("dim", " — ") +
        theme.fg("muted", preview),
        0, 0,
      );
    },

    renderResult(result, options, theme) {
      const details = result.details as any;
      if (!details) {
        const text = result.content[0];
        return new Text(text?.type === "text" ? text.text : "", 0, 0);
      }

      if (options.isPartial || details.status === "running") {
        return new Text(
          theme.fg("accent", `● ${details.chain || "chain"}`) +
          theme.fg("dim", " running..."),
          0, 0,
        );
      }

      const icon = details.status === "done" ? "✓"
        : details.status === "needs_clarification" ? "?" : "✗";
      const color = details.status === "done" ? "success"
        : details.status === "needs_clarification" ? "warning" : "error";
      const elapsed = typeof details.elapsed === "number" ? Math.round(details.elapsed / 1000) : 0;
      const header = theme.fg(color, `${icon} ${details.chain}`) +
        theme.fg("dim", ` ${elapsed}s`);

      if (options.expanded && details.fullOutput) {
        const output = details.fullOutput.length > 4000
          ? details.fullOutput.slice(0, 4000) + "\n... [truncated]"
          : details.fullOutput;
        return new Text(header + "\n" + theme.fg("muted", output), 0, 0);
      }

      return new Text(header, 0, 0);
    },
  });

  // ── Commands ─────────────────────────────────

  pi.registerCommand("chain", {
    description: "Switch active chain",
    handler: async (_args, ctx) => {
      widgetCtx = ctx;
      if (chains.length === 0) {
        ctx.ui.notify("No chains defined in .pi/agents/agent-chain.yaml", "warning");
        return;
      }

      const options = chains.map(c => {
        const steps = c.steps.map(s => displayName(s.agent)).join(" → ");
        const desc = c.description ? ` — ${c.description}` : "";
        return `${c.name}${desc} (${steps})`;
      });

      const choice = await ctx.ui.select("Select Chain", options);
      if (choice === undefined) return;

      const idx = options.indexOf(choice);
      activateChain(chains[idx]);
      const flow = chains[idx].steps.map(s => displayName(s.agent)).join(" → ");
      ctx.ui.setStatus("agent-chain", `Chain: ${chains[idx].name} (${chains[idx].steps.length} steps)`);
      ctx.ui.notify(
        `Chain: ${chains[idx].name}\n${chains[idx].description}\n${flow}\n\n` +
        `/chain-model       Set runtime model overrides for steps\n` +
        `/chain-answer      Answer clarification questions and resume chain`,
        "info",
      );
    },
  });

  pi.registerCommand("chain-list", {
    description: "List all available chains",
    handler: async (_args, ctx) => {
      widgetCtx = ctx;
      if (chains.length === 0) {
        ctx.ui.notify("No chains defined in .pi/agents/agent-chain.yaml", "warning");
        return;
      }

      const list = chains.map(c => {
        const desc = c.description ? `  ${c.description}` : "";
        const steps = c.steps.map((s, i) =>
          `  ${i + 1}. ${displayName(s.agent)}`
        ).join("\n");
        return `${c.name}:${desc ? "\n" + desc : ""}\n${steps}`;
      }).join("\n\n");

      ctx.ui.notify(list, "info");
    },
  });

  pi.registerCommand("chain-model", {
    description: "Set runtime model overrides for chain steps (without editing YAML)",
    handler: async (args, ctx) => {
      widgetCtx = ctx;
      if (!activeChain) {
        ctx.ui.notify("No active chain. Use /chain first.", "warning");
        return;
      }

      const renderCurrent = () => activeChain!.steps.map((s, i) => {
        const source = stepModelOverrides.has(i) ? "step" : chainModelOverride ? "chain" : "default";
        const model = getEffectiveStepModel(activeChain!, s, i) || "(inherits runtime/default)";
        return `${i + 1}. ${displayName(s.agent)} — ${model} [${source}]`;
      }).join("\n");

      const tokens = (args || "").trim().split(/\s+/).filter(Boolean);
      if (tokens.length === 0 || tokens[0] === "list") {
        ctx.ui.notify(
          `Current chain model mappings:\n${renderCurrent()}\n\n` +
          `Usage:\n` +
          `/chain-model <stepIndex> <provider/model>\n` +
          `/chain-model <stepIndex>              (interactive picker)\n` +
          `/chain-model all <provider/model>     (set chain-wide override)\n` +
          `/chain-model all                      (interactive picker)\n` +
          `/chain-model reset                    (clear all runtime overrides)\n` +
          `/chain-model <stepIndex> reset        (clear one step override)`,
          "info",
        );
        return;
      }

      if (tokens[0] === "reset") {
        chainModelOverride = undefined;
        stepModelOverrides.clear();
        stepStates = buildPendingStepStates(activeChain);
        updateWidget();
        ctx.ui.notify("Cleared all runtime chain model overrides.", "info");
        return;
      }

      if (tokens[0] === "all") {
        const modelRef = tokens[1] || await selectModelRef(ctx, "Select model for all chain steps");
        if (!modelRef) return;
        chainModelOverride = modelRef;
        stepModelOverrides.clear();
        stepStates = buildPendingStepStates(activeChain);
        updateWidget();
        ctx.ui.notify(`Chain-wide model override set to ${modelRef}.`, "info");
        return;
      }

      const stepIndex = Number.parseInt(tokens[0], 10) - 1;
      if (!Number.isFinite(stepIndex) || stepIndex < 0 || stepIndex >= activeChain.steps.length) {
        ctx.ui.notify(`Invalid step index \"${tokens[0]}\". Valid range: 1-${activeChain.steps.length}`, "error");
        return;
      }

      if (tokens[1] === "reset") {
        stepModelOverrides.delete(stepIndex);
        stepStates = buildPendingStepStates(activeChain);
        updateWidget();
        ctx.ui.notify(`Cleared runtime override for step ${stepIndex + 1}.`, "info");
        return;
      }

      const modelRef = tokens[1] || await selectModelRef(ctx, `Select model for step ${stepIndex + 1} (${displayName(activeChain.steps[stepIndex].agent)})`);
      if (!modelRef) return;

      stepModelOverrides.set(stepIndex, modelRef);
      stepStates = buildPendingStepStates(activeChain);
      updateWidget();
      ctx.ui.notify(
        `Set step ${stepIndex + 1} (${displayName(activeChain.steps[stepIndex].agent)}) model to ${modelRef}.`,
        "info",
      );
    },
  });

  pi.registerCommand("chain-answer", {
    description: "Answer pending chain clarification questions and resume the chain",
    handler: async (args, ctx) => {
      widgetCtx = ctx;
      if (!pendingClarification || !activeChain) {
        ctx.ui.notify("No pending clarification. Run run_chain first, then answer when prompted.", "warning");
        return;
      }

      const answer = (args || "").trim() || await ctx.ui.input("Clarification answer", "Provide answers to the pending questions");
      if (!answer) return;

      const result = await runChain(answer, ctx);
      const color: "info" | "warning" | "error" = result.status === "done" ? "info"
        : result.status === "needs_clarification" ? "warning"
          : "error";
      ctx.ui.notify(result.output, color);
    },
  });

  // ── System Prompt Override ───────────────────

  pi.on("before_agent_start", async (_event, _ctx) => {
    // Force widget reset on first turn after /new
    if (pendingReset && activeChain) {
      pendingReset = false;
      widgetCtx = _ctx;
      stepStates = buildPendingStepStates(activeChain);
      updateWidget();
    }

    if (!activeChain) return {};

    const flow = activeChain.steps.map(s => displayName(s.agent)).join(" → ");
    const desc = activeChain.description ? `\n${activeChain.description}` : "";

    // Build pipeline steps summary
    const steps = activeChain.steps.map((s, i) => {
      const agentDef = allAgents.get(s.agent.toLowerCase());
      const agentDesc = agentDef?.description || "";
      return `${i + 1}. **${displayName(s.agent)}** — ${agentDesc}`;
    }).join("\n");

    const clarificationContext = pendingClarification
      ? `\n## Pending Clarification\n` +
      `Chain is paused at step ${pendingClarification.stepIndex + 1} (${displayName(activeChain.steps[pendingClarification.stepIndex]?.agent || "unknown")}).\n` +
      `Round ${pendingClarification.rounds}/${MAX_CLARIFICATION_ROUNDS}.\n` +
      `Questions:\n${pendingClarification.questions.map((q, i) => `${i + 1}. ${q}`).join("\n")}\n` +
      `When user answers, call run_chain with ONLY the user's answer text to resume from the paused step.`
      : "";

    // Build full agent catalog (like agent-team.ts)
    const seen = new Set<string>();
    const agentCatalog = activeChain.steps
      .filter(s => {
        const key = s.agent.toLowerCase();
        if (seen.has(key)) return false;
        seen.add(key);
        return true;
      })
      .map((s, i) => {
        const agentDef = allAgents.get(s.agent.toLowerCase());
        if (!agentDef) return `### ${displayName(s.agent)}\nAgent not found.`;
        // Reflect the effective model priority, including runtime overrides
        const effectiveModel = getEffectiveStepModel(activeChain!, s, i) || agentDef.model;
        const modelLine = effectiveModel ? `\n**Model:** ${effectiveModel}` : "";
        return `### ${displayName(agentDef.name)}\n${agentDef.description}\n**Tools:** ${agentDef.tools}${modelLine}\n**Role:** ${agentDef.systemPrompt}`;
      })
      .join("\n\n");

    return {
      systemPrompt: `You are an agent with a sequential pipeline called "${activeChain.name}" at your disposal.${desc}
You have full access to your own tools AND the run_chain tool to delegate to your team.

## Active Chain: ${activeChain.name}
Flow: ${flow}

${steps}

## Agent Details

${agentCatalog}

## When to Use run_chain
- Significant work: new features, refactors, multi-file changes, anything non-trivial
- Tasks that benefit from the full pipeline: planning, building, reviewing
- When you want structured, multi-agent collaboration on a problem

## When to Work Directly
- Simple one-off commands: reading a file, checking status, listing contents
- Quick lookups, small edits, answering questions about the codebase
- Anything you can handle in a single step without needing the pipeline

## How run_chain Works
- Pass a clear task description to run_chain
- Each step's output feeds into the next step as $INPUT
- Agents maintain session context — they remember previous work within this session
- If planner asks clarification questions, chain pauses and returns those questions
- After the user replies, call run_chain again with their answer to continue from the paused step
- Chain may ask follow-up clarification questions (up to a capped number of rounds)
- After the chain completes, review the result and summarize for the user

## Question Asking Policy
- For any clarification question to the user (inside or outside chain), use the ask-user-question extension tool.
- Do NOT ask clarification questions as plain assistant text unless that tool is unavailable.
- When run_chain returns a needs-clarification result, ask those questions via that tool and then resume run_chain with the user's answer.

## Guidelines
- Use your judgment — if it's quick, just do it; if it's real work, run the chain
- Keep chain tasks focused and clearly described
- If chain is waiting for clarification, do NOT continue implementation directly; first gather the user's answers and resume run_chain
- You can mix direct work and chain runs in the same conversation${clarificationContext ? "\n\n" + clarificationContext : ""}`,
    };
  });

  // ── Session Start ───────────────────────────

  pi.on("session_start", async (_event, _ctx) => {
    //applyExtensionDefaults(import.meta.url, _ctx);
    // Clear widget with both old and new ctx — one of them will be valid
    if (widgetCtx) {
      widgetCtx.ui.setWidget("agent-chain", undefined);
    }
    _ctx.ui.setWidget("agent-chain", undefined);
    widgetCtx = _ctx;

    // Reset execution state — widget re-registration deferred to before_agent_start
    stepStates = [];
    activeChain = null;
    pendingClarification = null;
    chainModelOverride = undefined;
    stepModelOverrides.clear();
    pendingReset = true;

    // Wipe chain session files — reset agent context on /new and launch
    const sessDir = join(_ctx.cwd, ".pi", "agent-sessions");
    if (existsSync(sessDir)) {
      for (const f of readdirSync(sessDir)) {
        if (f.startsWith("chain-") && f.endsWith(".json")) {
          try { unlinkSync(join(sessDir, f)); } catch { }
        }
      }
    }

    // Reload chains + clear agentSessions map (all agents start fresh)
    loadChains(_ctx.cwd);

    if (chains.length === 0) {
      _ctx.ui.notify("No chains found in .pi/agents/agent-chain.yaml", "warning");
      return;
    }

    // Default to first chain — use /chain to switch
    activateChain(chains[0]);

    // run_chain is registered as a tool — available alongside all default tools

    const flow = activeChain!.steps.map(s => displayName(s.agent)).join(" → ");
    _ctx.ui.setStatus("agent-chain", `Chain: ${activeChain!.name} (${activeChain!.steps.length} steps)`);
    _ctx.ui.notify(
      `Chain: ${activeChain!.name}\n${activeChain!.description}\n${flow}\n\n` +
      `/chain             Switch chain\n` +
      `/chain-list        List all chains\n` +
      `/chain-model       Set runtime model overrides for steps\n` +
      `/chain-answer      Answer clarification questions and resume chain`,
      "info",
    );

    // Footer: model | chain name | context bar
    _ctx.ui.setFooter((_tui, theme, _footerData) => ({
      dispose: () => { },
      invalidate() { },
      render(width: number): string[] {
        const model = _ctx.model?.id || "no-model";
        const usage = _ctx.getContextUsage();

        const pctRaw = usage?.percent;
        const pct = typeof pctRaw === "number"
          ? Math.max(0, Math.min(100, pctRaw))
          : null;
        const filled = Math.round((pct ?? 0) / 10);
        const bar = "#".repeat(filled) + "-".repeat(10 - filled);

        const usageColor = pct === null
          ? "dim"
          : pct >= 90
            ? "error"
            : pct >= 75
              ? "warning"
              : "success";

        const pctLabel = pct === null ? "--%" : `${Math.round(pct)}%`;

        const tokens = usage?.tokens;
        const contextWindow = usage?.contextWindow;
        const tokensKnown = tokens !== null && tokens !== undefined;
        const contextKnown = contextWindow !== null && contextWindow !== undefined;
        const remaining = tokensKnown && contextKnown
          ? Math.max(0, contextWindow - tokens)
          : null;

        const ctxLabel = tokensKnown && contextKnown && remaining !== null
          ? `ctx ${formatTokens(tokens)}/${formatTokens(contextWindow)} tok · rem ${formatTokens(remaining)} tok`
          : "ctx ?/? tok";

        const compactHint = pct !== null && pct >= 85
          ? theme.fg("warning", " · /compact soon")
          : "";

        const chainLabel = activeChain
          ? theme.fg("accent", activeChain.name)
          : theme.fg("dim", "no chain");

        const left = theme.fg("dim", ` ${model}`) +
          theme.fg("muted", " · ") +
          chainLabel;
        const right =
          theme.fg(usageColor, `[${bar}] ${pctLabel}`) +
          theme.fg("dim", ` · ${ctxLabel}`) +
          compactHint +
          " ";
        const pad = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(right)));

        return [truncateToWidth(left + pad + right, width)];
      },
    }));
  });
}
