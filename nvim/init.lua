-- LEADER
-- These keybindings need to be defined before the first /
-- is called; otherwise, it will default to "\"
vim.g.mapleader = ","
vim.g.localleader = "\\"
vim.g.gitblame_enabled = 0
vim.g.gitblame_date_format = '%d/%b/%Y'
vim.g.gitblame_message_template = '<author> • <date> • <summary>'

table.insert(vim._so_trails, "/?.dylib")

-- import ---
require('dependencies')
require('core.options')
require('core.keymaps')
require('plugins.lsp')
require('core.autocmds')

vim.o.background = "light" -- or "light" for light mode
--vim.cmd([[colorscheme gruvbox]])

