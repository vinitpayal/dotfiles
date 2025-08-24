
-- Automatically format JSON & YAML files
local jqx = vim.api.nvim_create_augroup("Jqx", {})

vim.api.nvim_clear_autocmds({ group = jqx })
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = { "*.json", "*.yaml" },
  desc = "preview json and yaml files on open",
  group = jqx,
  callback = function()
  vim.cmd.JqxList()
end,
})

-- vim.api.nvim_create_autocmd("VimEnter", {
--   pattern = "*",
--   desc = "Open NERDTree on VimEnter",
--   callback = function()
--     vim.cmd("NERDTree")
--   end,
-- })

