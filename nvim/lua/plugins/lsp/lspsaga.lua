-- Optional lspsaga configuration for enhanced LSP UI
-- This provides a better UI for LSP functions but is not required
-- When loaded, it will override the native LSP keymaps

return {
  {
    "nvimdev/lspsaga.nvim",
    optional = true,
    config = function()
      -- Set flag to prevent native keymaps from loading
      vim.g.lspsaga_keymaps_enabled = true
      require("lspsaga").setup({
        ui = {
          border = "rounded",
          winblend = 0,
          expand = "",
          collapse = "",
          code_action = "💡",
          incoming = " ",
          outgoing = " ",
          hover = " ",
        },
        hover = {
          max_width = 0.6,
        },
        diagnostic = {
          show_code_action = true,
          show_source = true,
          jump_num_shortcut = true,
          keys = {
            exec_action = "o",
            quit = "q",
          },
        },
        code_action = {
          num_shortcut = true,
          keys = {
            quit = "q",
            exec = "<CR>",
          },
        },
        lightbulb = {
          enable = true,
          enable_in_insert = true,
          sign = true,
          sign_priority = 40,
          virtual_text = true,
        },
        preview = {
          lines_above = 0,
          lines_below = 10,
        },
        scroll_preview = {
          scroll_down = "<C-f>",
          scroll_up = "<C-b>",
        },
        finder = {
          edit = { "o", "<CR>" },
          vsplit = "s",
          split = "i",
          tabe = "t",
          quit = { "q", "<ESC>" },
        },
      })

      -- Set up lspsaga keymaps (replaces native LSP keymaps)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local opts = { buffer = bufnr, silent = true }
          
          -- Enhanced navigation with lspsaga
          vim.keymap.set('n', 'gd', '<cmd>Lspsaga peek_definition<CR>', opts)
          vim.keymap.set('n', 'gr', '<cmd>Lspsaga finder<CR>', opts)
          vim.keymap.set('n', 'K', '<cmd>Lspsaga hover_doc<CR>', opts)
          vim.keymap.set('n', '<leader>ca', '<cmd>Lspsaga code_action<CR>', opts)
          vim.keymap.set('v', '<leader>ca', '<cmd>Lspsaga code_action<CR>', opts)
          vim.keymap.set('n', '<leader>rn', '<cmd>Lspsaga rename<CR>', opts)
          vim.keymap.set('n', '[d', '<cmd>Lspsaga diagnostic_jump_prev<CR>', opts)
          vim.keymap.set('n', ']d', '<cmd>Lspsaga diagnostic_jump_next<CR>', opts)
          vim.keymap.set('n', '<leader>e', '<cmd>Lspsaga show_line_diagnostics<CR>', opts)
          vim.keymap.set('n', '<leader>o', '<cmd>Lspsaga outline<CR>', opts)
          
          -- Keep native keymaps that lspsaga doesn't replace
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<leader>f', function()
            vim.lsp.buf.format({ async = true })
          end, opts)
          vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          
          -- Inlay hints toggle
          if vim.lsp.inlay_hint then
            vim.keymap.set('n', '<leader>ih', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
            end, opts)
          end
        end,
      })
    end
  }
}
