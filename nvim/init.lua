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
require('opts')
require('keys')
require('lsp')
-- require('theme')
--require("daps")
require("tmux")


vim.o.background = "light" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])

-- require('telescope').setup {
--   defaults = {
--     file_ignore_patterns = {
--       "node_modules"
--     }
--   },
--   -- this requires installing vimgrep using `brew install ripgrep` ---
--   vimgrep_arguments = {
--     'rg',
--     '--no-heading',
--     '--with-filename',
--     '--line-number',
--     '--column',
--     '--smart-case'
--   },
--   extensions = {
--     fzf = {
--       fuzzy = true,                   -- false will only do exact matching
--       override_generic_sorter = true, -- override the generic sorter
--       override_file_sorter = true,    -- override the file sorter
--       case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
--       -- the default case_mode is "smart_case"
--     }
--   }
-- }

-- require("dir-telescope").setup({
-- 	hidden = true,
-- 	no_ignore = false,
-- 	show_preview = true
-- })

-- require('telescope').load_extension('lazygit')
-- require("telescope").load_extension("dir")
-- require('nvim-web-devicons').get_icons()

-- -- dims inactive vim windows
-- require('shade').setup({
--   overlay_opacity = 50,
--   opacity_step = 1,
-- })

-- -- dims unused keywords
-- require('dim').setup({})

-- -- for code folding
-- require('ufo').setup({
--   provider_selector = function(bufnr, filetype, buftype)
--     return {'treesitter', 'indent'}
--   end
-- })

-- -- identline setup
-- require("ibl").setup()
