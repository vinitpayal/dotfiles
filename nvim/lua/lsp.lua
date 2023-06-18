local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require('lspconfig')

require("luasnip.loaders.from_vscode").load({ include = { "python", "javascript", "typescript" } })

require("mason").setup()
require("mason-lspconfig").setup()

local languageServers = {
    "lua_ls",
    "tsserver",
    "pylsp",
    "dockerls",
    "docker_compose_language_service",
    "marksman",
    "sqlls",
    "bashls",
    "jsonls"
}


require("mason-lspconfig").setup {
  ensure_installed = languageServers
}

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
for _, lsp in ipairs(languageServers) do
  lspconfig[lsp].setup {
    capabilities = capabilities,
  }
end

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
    ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
    -- C-b (back) C-f (forward) for snippet placeholder navigation.
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

--cmp.setup({
--  snippet = {
--    -- REQUIRED - you must specify a snippet engine
--    expand = function(args)
--      require('luasnip').lsp_expand(args.body)
--    end,
--  },
--  window = {
--    completion = cmp.config.window.bordered(),
--    documentation = cmp.config.window.bordered(),
--  },
--  mapping = cmp.mapping.preset.insert({
--    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
--    ['<C-f>'] = cmp.mapping.scroll_docs(4),
--    ['<C-Space>'] = cmp.mapping.complete(),
--    ['<C-e>'] = cmp.mapping.abort(),
--    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
--  }),
--  sources = cmp.config.sources({
--    { name = 'luasnip' }
--  }, {
--    { name = 'buffer' },
--  })
--})

--require("lspconfig").lua_ls.setup { capabilities = capabilities }
----require("lspconfig").tsserver.setup { capabilities = capabilities }
--require("lspconfig").tsserver.setup { capabilities = capabilities }
--
--require("lspconfig").pylsp.setup { capabilities = capabilities }
--require("lspconfig").dockerls.setup { capabilities = capablities }
--require("lspconfig").docker_compose_language_service.setup { capabilities = capablities }
--require("lspconfig").marksman.setup { capabilities = capablities }
--require("lspconfig").sqlls.setup { capabilities = capablities }
--require("lspconfig").bashls.setup { capabilities = capablities }
--require("lspconfig").jsonls.setup { capabilities = capablities }

--require('lint').linters_by_ft = {
--  markdown = { 'vale' },
--  javascript = { 'eslint_d' },
--  typescript = { 'eslint_d' },
--  python = { 'pylint' },
--  sql = { 'sqlfluff' },
--  sh = { 'shellcheck' },
--  json = { 'jsonlint' },
--  yaml = { 'yamllint' },
--  dockerfile = { 'hadolint' },
--  dockercompose = { 'hadolint' },
--  lua = { 'luacheck' }
--}

--vim.api.nvim_create_autocmd({ "BufWritePost" }, {
--  callback = function()
--    require("lint").try_lint()
--  end,
--})
