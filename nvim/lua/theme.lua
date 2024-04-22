-- Default options:
require("gruvbox").setup({
  terminal_colors = true, -- add neovim terminal colors
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = false,
    emphasis = true,
    comments = true,
    operators = false,
    folds = true,
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  inverse = true, -- invert background for search, diffs, statuslines and errors
  contrast = "", -- can be "hard", "soft" or empty string
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = false,
})

vim.o.background = "light"
vim.cmd("colorscheme gruvbox")

-- Dayfox color palette

--local nightfox = require('nightfox')

-- set the dayfox theme
--nightfox.setup({
--  fox = "dayfox"
--})
-- configure the dayfox theme
--vim.cmd [[colorscheme dayfox]]


--require('nightfox').setup({
--  fox = "dayfox",
--  options = {
--    styles = {
--      comments = "italic", -- Value is any valid attr-list value `:help attr-list`
--      strings = "italic",
--      functions = "italic,bold",
--      --    keywords = "NONE",
--      --    numbers = "NONE",
--      --    operators = "NONE",
--      --    conditionals = "NONE",
--      constants = "underdotted",
--      --    types = "NONE",
--      --    variables = "NONE",
--    },
--    --transparent = true,
--    spec = { all = { syntax = { operator = "orange", keyword = "black" } } }
--  }
--})



-- Load the Zenburn colorscheme
--require('zenburn').setup()
--vim.cmd('colorscheme zenburn')
--zenburn is good but syntax highlighting is not good


--vim.g.nightfox_style = "light"

--vim.g.nightfox_function = '#a9a1e1'
--

-- setup must be called before loading the colorscheme
-- Default options:

------------------ Github theme is good overall but a bit too dark
--require('github-theme').setup({
--  options = {
--    styles = {
--      comments = "italic",
--      functions = "bold",
--      keywords = "italic,bold",
--      variables = "NONE"
--    }
--  },
--})
--vim.cmd('colorscheme github_light')

--require('onedark').load()
--vim.cmd('colorscheme onedark')
--require('onedark').setup {
--    style = 'warmer'
--}
