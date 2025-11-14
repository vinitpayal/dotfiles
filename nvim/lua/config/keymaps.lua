-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Copy relative file path with line number
vim.keymap.set("n", "<leader>cf", function()
  local filepath = vim.fn.expand("%:.")
  local line_number = vim.fn.line(".")
  local reference = filepath .. ":" .. line_number
  vim.fn.setreg("+", reference)
  vim.notify('Copied: ' .. reference, vim.log.levels.INFO)
end, { desc = "Copy file path with line number" })
