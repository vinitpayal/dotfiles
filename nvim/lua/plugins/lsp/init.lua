return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp"
    },
    config = function()
      local mason = require("mason")
      local mason_lspconfig = require("mason-lspconfig")
      local lspconfig = require("lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      mason.setup()
      mason_lspconfig.setup {
        ensure_installed = { "pyright", "pylsp", "ts_ls", "bashls", "jsonls", "marksman" },
        automatic_installation = true,
      }

      local capabilities = cmp_nvim_lsp.default_capabilities()
      local on_attach = function(client, bufnr)
        -- Add your custom LSP keymaps here if needed
      end

      local servers = {
        pyright = {},
        pylsp = {},
        ts_ls = {},
        bashls = {},
        jsonls = {},
        marksman = {},
      }

      if mason_lspconfig.setup_handlers then
        mason_lspconfig.setup_handlers {
          function(server_name)
            lspconfig[server_name].setup(vim.tbl_deep_extend("force", {
              on_attach = on_attach,
              capabilities = capabilities,
            }, servers[server_name] or {}))
          end,
        }
      else
        for server_name, config in pairs(servers) do
          lspconfig[server_name].setup(vim.tbl_deep_extend("force", {
            on_attach = on_attach,
            capabilities = capabilities,
          }, config))
        end
      end
    end
  },
}
