local cmp = require 'cmp'
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local luasnip = require 'luasnip'
local lspconfig = require('lspconfig')

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { "documentation", "detail", "additionalTextEdits" },
}

-- add folding for nvim-ufo
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}

require("luasnip.loaders.from_vscode").lazy_load { paths = vim.fn.stdpath "config" .. "/friendly-snippets" }

require 'cmp'.setup {
  sources = {
    { name = 'nvim_lsp' },
    { name = "copilot", group_index = 2 }
  }
}

local languageServers = {
  "lua_ls",
  -- "tsserver",
  "pylsp",
  "dockerls",
  "docker_compose_language_service",
  "marksman",
  --"sqlls",
  "bashls",
  "jsonls"
}

require("mason").setup {}
require("mason-lspconfig").setup {
  ensure_installed = languageServers
}

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
for _, lsp in ipairs(languageServers) do
  lspconfig[lsp].setup {
    capabilities = capabilities,
  }
end

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
    --["<Tab>"] = vim.schedule_wrap(function(fallback) -- required for copilot
    --  if cmp.visible() and has_words_before() then
    --    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
    --  else
    --    fallback()
    --  end
    --end),
  }),
  --mapping = {
  --  ["<CR>"] = cmp.mapping.confirm({ select = true }),
  --  ["<C-p>"] = cmp.mapping.select_prev_item(),
  --  ["<C-n>"] = cmp.mapping.select_next_item(),
  --  ["<C-d>"] = cmp.mapping.scroll_docs(-4),
  --  ["<C-f>"] = cmp.mapping.scroll_docs(4),
  --  ["<C-e>"] = cmp.mapping.close(),
  --  ["<Tab>"] = cmp.mapping(function(fallback)
  --    if cmp.visible() then
  --      cmp.select_next_item()
  --    elseif require("luasnip").expand_or_jumpable() then
  --      require("luasnip").expand_or_jump()
  --    --elseif has_words_before() then
  --    --  cmp.complete()
  --    else
  --      fallback()
  --    end
  --  end, { "i", "s" }),
  --  ["<S-Tab>"] = cmp.mapping(function(fallback)
  --    if cmp.visible() then
  --      cmp.select_prev_item()
  --    elseif require("luasnip").jumpable(-1) then
  --      require("luasnip").jump(-1)
  --    else
  --      fallback()
  --    end
  --  end, { "i", "s" }),
  --},
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  sources = {
    { name = 'path' },
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'nvim_lsp_signature_help' }
  },
}

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
