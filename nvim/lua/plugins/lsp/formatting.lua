-- Optional formatting configuration (can be loaded separately)
-- This is separate from the core LSP setup to keep dependencies minimal

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "prettierd", "prettier" },
          typescript = { "prettierd", "prettier" },
          typescriptreact = { "prettierd", "prettier" },
          javascriptreact = { "prettierd", "prettier" },
          json = { "prettierd", "prettier" },
          jsonc = { "prettierd", "prettier" },
          css = { "prettierd", "prettier" },
          scss = { "prettierd", "prettier" },
          html = { "prettierd", "prettier" },
          yaml = { "prettierd", "prettier" },
          python = { "isort", "black" },
          sh = { "shfmt" },
          bash = { "shfmt" },
          markdown = { "prettierd", "prettier" },
          lua = { "stylua" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
        formatters = {
          shfmt = {
            prepend_args = { "-i", "2" },
          },
        },
      })

      -- Override LSP formatting keymap if conform is available
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local opts = { buffer = bufnr, silent = true }
          
          -- Override formatting keymaps to use conform
          vim.keymap.set('n', '<leader>f', function()
            require("conform").format({ async = true, lsp_fallback = true })
          end, opts)
          vim.keymap.set('v', '<leader>f', function()
            require("conform").format({ async = true, lsp_fallback = true })
          end, opts)
        end,
      })
    end
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    config = function()
      require("lint").linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        python = { "flake8" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        dockerfile = { "hadolint" },
        markdown = { "markdownlint" },
        yaml = { "yamllint" },
      }

      -- Auto-lint on save and text changed
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          require("lint").try_lint()
        end,
      })
    end
  }
}
