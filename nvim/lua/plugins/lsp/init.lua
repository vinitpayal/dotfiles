return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- For enhanced completion capabilities
      "b0o/schemastore.nvim", -- JSON/YAML schemas
    },
    config = function()
      local mason = require("mason")
      local servers = require("plugins.lsp.config.servers")
      local handlers = require("plugins.lsp.config.handlers")

      -- Setup mason for easy LSP server installation
      mason.setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })

      -- List of LSP servers to ensure are installed
      local ensure_installed = {
        "typescript-language-server", -- ts_ls
        "pyright",                   -- Python
        "bash-language-server",      -- bashls
        "dockerfile-language-server", -- dockerls
        "marksman",                  -- Markdown
        "lua-language-server",       -- lua_ls
        "json-lsp",                  -- jsonls
        "yaml-language-server",      -- yamlls
      }

      -- Auto-install LSP servers
      local mason_registry = require("mason-registry")
      for _, server in ipairs(ensure_installed) do
        if not mason_registry.is_installed(server) then
          vim.cmd("MasonInstall " .. server)
        end
      end

      -- Modern Neovim 0.11+ LSP configuration using vim.lsp.config
      for server_name, config in pairs(servers) do
        local server_config = vim.tbl_deep_extend("force", {
          on_attach = handlers.on_attach,
          capabilities = handlers.capabilities,
        }, config)
        
        -- Use native vim.lsp.config instead of lspconfig
        vim.lsp.config[server_name] = server_config
      end

      -- Auto-start LSP servers for configured filetypes
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local bufnr = args.buf
          local ft = vim.bo[bufnr].filetype
          
          -- Map filetypes to LSP servers
          local filetype_to_server = {
            typescript = "ts_ls",
            javascript = "ts_ls",
            typescriptreact = "ts_ls",
            javascriptreact = "ts_ls",
            python = "pyright",
            lua = "lua_ls",
            sh = "bashls",
            bash = "bashls",
            dockerfile = "dockerls",
            markdown = "marksman",
            json = "jsonls",
            jsonc = "jsonls",
            yaml = "yamlls",
          }
          
          local server_name = filetype_to_server[ft]
          if server_name and vim.lsp.config[server_name] then
            vim.lsp.enable(server_name, { bufnr = bufnr })
          end
        end,
      })
      
      -- Note: Optional formatting available in plugins.lsp.formatting
    end
  },
}
