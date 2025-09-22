-- Centralized LSP handlers and capabilities for native Neovim 0.11+ LSP
local M = {}

-- Enhanced capabilities using native LSP and completion
M.capabilities = vim.tbl_deep_extend("force", 
  vim.lsp.protocol.make_client_capabilities(),
  require('cmp_nvim_lsp').default_capabilities()
)

-- Enable additional capabilities
M.capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true
}

M.capabilities.workspace.fileOperations = {
  didCreate = true,
  didRename = true,
  didDelete = true,
  willCreate = true,
  willRename = true,
  willDelete = true,
}

M.on_attach = function(client, bufnr)
  -- Disable LSP formatting for specific servers (use conform.nvim instead)
  if client.name == "ts_ls" or client.name == "pyright" or client.name == "lua_ls" then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end
  
  -- Load LSP keymaps
  require('plugins.lsp.config.keymaps').setup(bufnr)
  
  -- Enable inlay hints if supported (Neovim 0.10+)
  if client.supports_method and client.supports_method('textDocument/inlayHint') then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
  
  -- Enable document highlighting if supported
  if client.server_capabilities.documentHighlightProvider then
    local group = vim.api.nvim_create_augroup("LSPDocumentHighlight", { clear = false })
    vim.api.nvim_create_autocmd("CursorHold", {
      group = group,
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      group = group,
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
  
  -- Enable semantic tokens if supported
  if client.server_capabilities.semanticTokensProvider then
    client.server_capabilities.semanticTokensProvider.full = true
  end
end

-- Diagnostic config (global)
vim.diagnostic.config({
  virtual_text = { prefix = '●' },
  float = { border = 'rounded', source = 'always' },
  severity_sort = true,
  update_in_insert = false,
})

return M
