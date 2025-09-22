-- Python-specific settings
vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.expandtab = true

vim.wo.spell = true

vim.keymap.set('n', '<leader>r', ':w<CR>:!python3 %<CR>', { buffer = true, desc = "Run current Python file" })
