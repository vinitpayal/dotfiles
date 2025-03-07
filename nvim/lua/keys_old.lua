-- [[ keys.lua ]]
local builtin = require('telescope.builtin')
local telescope_extensions = require('telescope').extensions

vim.api.nvim_set_keymap('t', '<C-t>', '<C-\\><C-n>CR>', { noremap = true, silent = true })
local wk = require("which-key")

wk.register({
  ["<leader>"] = {
    name = "<leader>",
    t = {
      name = "+floaterm",
      l = { [[:FloatermNew --height=0.98 --width=0.98 lazygit<CR>]], "lazygit" },
      n = { [[:FloatermNew<CR>]], "new terminal" },
      t = { [[:FloatermToggle<CR>]], "toggle terminal" },
      m = { [[:FloatermNew --height=0.2 --wintype=split --position=bottom<CR>]], "mini term at bottom" },
      r = { [[:FloatermNew --width=0.45 --wintype=vsplit<CR>]], "mini term at right half" }
    },
    f = {
      name = "+telescope",
      i = { builtin.help_tags, "telescope help" },
      f = { builtin.find_files, "search files" },
      k = { builtin.live_grep, "search keyword" },
      m = { builtin.lsp_dynamic_workspace_symbols, "search methods" },
      h = { builtin.resume, "search history" }, 
      b = { builtin.buffers, "search buffers" },
      t = { builtin.treesitter,"search treesitter"},
      d = {
          name = "+dir",
          k = { telescope_extensions.dir.live_grep, "search keyword in dir" },
          f = { telescope_extensions.dir.find_files, "search files in dir" },
      },
      l = {
        name = "+lsp",
        r = { builtin.lsp_references, "lsp references" },
        i = { builtin.lsp_implementations, "lsp implementations" },
        d = { builtin.lsp_definitions, "lsp definitions" }
      },
      g = {
        name = "+git",
        b = { builtin.git_branches, "git branches" },
        c = { builtin.git_bcommits, "git current file commits" },
        s = { builtin.git_status, "git status" },
      },
    },
    u = { [[:DBUIToggle<CR>]], "toggle dbui" },
    n = { [[:NvimTreeToggle<CR>]], "toggle nvim tree" },
    p = { [[:PackerSync<CR>]], "sync packer" },
    c = {
        name = "+clipboard(neoclip)",
        h = { [[:lua require('telescope').extensions.neoclip.default()<CR>]], "search clipboard history" }
    } 
  },
  z = {
    name = "+fold",
    R = { require('ufo').openAllFolds, "ufo-open folds" },
    M = { require('ufo').closeAllFolds, "ufo-close folds" },
    P = { require('ufo').peekFoldedLinesUnderCursor, "Quick peek into folded area" }
  },
  g = {
    name = "+goto",
    p = {
      name = "+preview-plugin",
      d = { require('goto-preview').goto_preview_definition, "goto_preview_definition" },
      t = { require('goto-preview').goto_preview_type_definition, "goto_preview_type_definition" },
      i = { require('goto-preview').goto_preview_implementation, "goto_preview_implementation" },
      r = { require('goto-preview').goto_preview_references, "goto_preview_references" }
    },
    P = { require('goto-preview').close_all_win, "close all previews" }
  },
  v = {
    name = "+vcs",
    b = { [[:GitBlameToggle<CR>]], "toggle git blame" },
  }
  --m = {
  --  name="+lsp",
  --  a = { vim.lsp.buf.code_action, "code action" },
  --  A = { vim.lsp.buf.range_code_action, "range code action" },
  --  d = { vim.lsp.buf.definition, "go to definition" },
  --  D = { vim.lsp.buf.declaration, "go to declaration" },
  --  r = { vim.lsp.buf.references, "go to references" },
  --  R = { vim.lsp.buf.rename, "rename" },
  --  i = { vim.lsp.buf.implementation, "go to implementation" },
  --  s = { vim.lsp.buf.signature_help, "signature help" },
  --  t = { vim.lsp.buf.type_definition, "go to type definition" },
  --  f = { vim.lsp.buf.formatting, "format" },
  --  F = { vim.lsp.buf.formatting_sync, "format sync" },
  --  e = { vim.lsp.diagnostic.show_line_diagnostics, "show line diagnostics" },
  --  E = { vim.lsp.diagnostic.set_loclist, "set loclist" },
  --  p = { vim.lsp.diagnostic.goto_prev, "go to previous diagnostic" },
  --  n = { vim.lsp.diagnostic.goto_next, "go to next diagnostic" },
  --  q = { vim.lsp.diagnostic.set_qflist, "set qflist" },
  --  l = { vim.lsp.diagnostic.show_line_diagnostics, "show line diagnostics" },
  --},
  --g = {
  --  b = { [[:GitBlameToggle<CR>]], "toggle git blame" },
  --  c = { builtin.git_bcommits, "current file commits" },
  --  a = { builtin.git_commits, "all commits" },
  --  s = { builtin.git_status, "git status" },
  --  l = { builtin.git_branches, "git branches" },
  --  z = {
  --    R = { require('ufo').openAllFolds, "ufo-open folds" },
  --    M = { require('ufo').closeAllFolds, "ufo-close folds" }
  --  }
  --},
})

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    --vim.lsp.buf.format { async = true }
    --end, opts)
  end,
})
