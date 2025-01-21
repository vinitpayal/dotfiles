local cmp = require 'cmp'
local capabilities = require('cmp_nvim_lsp').default_capabilities()
--local luasnip = require 'luasnip'
local lspconfig = require('lspconfig')

--capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { "documentation", "detail", "additionalTextEdits" },
}

-- add folding for nvim-ufo
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}

require 'cmp'.setup {
  sources = {
    { name = 'nvim_lsp' },
    -- { name = "copilot", group_index = 2 }
  }
}

local languageServers = {
  "lua_ls",
  -- "tsserver",
  "ts_ls",
  "pylsp",
  -- "dockerls",
  -- "docker_compose_language_service",
  "marksman",
  --"sqlls",
  "bashls",
  "jsonls"
}

require("mason").setup {}
require("mason-lspconfig").setup {
  ensure_installed = vim.tbl_extend("force", {}, languageServers, { "pylsp" })
}

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
for _, lsp in ipairs(languageServers) do
  lspconfig[lsp].setup {
    capabilities = capabilities,
  }
end

-- lspconfig.pylsp.setup {
--   capabilities = capabilities,
--   settings = {
--     pylsp = {
--       plugins = {
--         pycodestyle = {
--           ignore = { 'E501' },
--         },
--       },
--     },
--   },
-- }

-- nvim-cmp setup
cmp.setup { 
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
  sources = {
    { name = 'path' },
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' }
  },
}
