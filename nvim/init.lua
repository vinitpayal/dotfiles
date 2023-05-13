-- LEADER
-- These keybindings need to be defined before the first /
-- is called; otherwise, it will default to "\"
vim.g.mapleader = ","
vim.g.localleader = "\\"

vim.o.packpath = vim.o.packpath .. ',~/.config/nvim/site'
-- import ---
require('plug')
require('vars')
require('opts')
require('keys')
require('lsp')
require('theme')
require("daps")
require("auto_suggest")
require("tmux")

require("nvim-tree").setup({
  sort_by = "case_sensitive",
  renderer = {
    group_empty = true,
    add_trailing = true,
    highlight_git = true,
  },
  filters = {
    --dotfiles = true,
  },
})

vim.g.gitblame_enabled = 0
vim.g.gitblame_date_format = '%d/%b/%Y'
vim.g.gitblame_message_template = '<author> • <date> • <summary>'

require('lualine').setup({
  options = {
    theme = 'dayfox',
  },
  sections = {
    lualine_c = { { 'filename', path = 1 } }
  }
})

require('telescope').setup {
  defaults = {
    file_ignore_patterns = {
      "node_modules"
    }
  },
  -- this requires installing vimgrep using `brew install ripgrep` ---
  vimgrep_arguments = {
    'rg',
    '--no-heading',
    '--with-filename',
    '--line-number',
    '--column',
    '--smart-case'
  },
  extensions = {
    fzf = {
      fuzzy = true,                   -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true,    -- override the file sorter
      case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    }
  }
}

require('telescope').load_extension('lazygit')

require('nvim-web-devicons').get_icons()

vim.g.indent_blankline_use_treesitter = true
vim.g.indent_blankline_show_first_indent_level = true
require("indent_blankline").setup {
  --blankline_char = ".",
  space_char_blankline = " ",
  show_current_context = true,
  show_current_context_start = true,
}

require("todo-comments").setup {}
