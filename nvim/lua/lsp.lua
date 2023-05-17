local cmp = require 'cmp'

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'luasnip' }
  }, {
    { name = 'buffer' },
  })
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

require("mason").setup()
require("mason-lspconfig").setup()

require("mason-lspconfig").setup {
  ensure_installed = {
    "lua_ls",
    "tsserver",
    "pylsp",
    "dockerls",
    "docker_compose_language_service",
    "marksman",
    "sqlls",
    "bashls",
    "jsonls"
    -- "quick_lint_js"
  },
}

require("lspconfig").lua_ls.setup { capabilities = capabilities }
require("lspconfig").tsserver.setup { capabilities = capabilities }
--require("lspconfig").tsserver.setup {
--  capabilities = capabilities,
--  on_attach = function(client)
--    client.server_capabilities.documentFormattingProvider = false
--    client.server_capabilities.documentRangeFormattingProvider = false
--  end
--}
require("lspconfig").pylsp.setup { capabilities = capabilities }
require("lspconfig").dockerls.setup { capabilities = capablities }
require("lspconfig").docker_compose_language_service.setup { capabilities = capablities }
require("lspconfig").marksman.setup { capabilities = capablities }
require("lspconfig").sqlls.setup { capabilities = capablities }
require("lspconfig").bashls.setup { capabilities = capablities }
require("lspconfig").jsonls.setup { capabilities = capablities }

require('lint').linters_by_ft = {
  markdown = { 'vale' },
  javascript = { 'eslint_d' },
  typescript = { 'eslint_d' },
  python = { 'pylint' },
  sql = { 'sqlfluff' },
  sh = { 'shellcheck' },
  json = { 'jsonlint' },
  yaml = { 'yamllint' },
  dockerfile = { 'hadolint' },
  dockercompose = { 'hadolint' },
  lua = { 'luacheck' }
}

--vim.api.nvim_create_autocmd({ "BufWritePost" }, {
--  callback = function()
--    require("lint").try_lint()
--  end,
--})
