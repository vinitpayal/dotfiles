return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      theme = 'rose-pine',
      icons_enabled = true,
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
      disabled_filetypes = {
        statusline = {},
        winbar = {},
      },
      ignore_focus = {},
      always_divide_middle = true,
      always_show_tabline = true,
      globalstatus = true,
      refresh = {
        statusline = 100,
        tabline = 100,
        winbar = 100,
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {
          {
            'filename',
            file_status = true,
            path = 1,
            symbols = {
              modified = '[+]',
              readonly = '[-]',
              unnamed = '[No Name]',
              newfile = '[New]',
            }
          }
        },
        lualine_c = {'branch', { 'diff', colored = true, symbols = {added = '+', modified = '~', removed = '-'}}, { 'diagnostics', sources = { 'ale', 'nvim_diagnostic' } }},
        lualine_x = {
          {
            'buffers',
            show_filename_only = true,   -- Shows shortened relative path when set to false.
            hide_filename_extension = false,   -- Hide filename extension when set to true.
            show_modified_status = true, -- Shows indicator when the buffer is modified.
            mode = 0, -- 0: Shows buffer name
                      -- 1: Shows buffer index
                      -- 2: Shows buffer name + buffer index
                      -- 3: Shows buffer number
                      -- 4: Shows buffer name + buffer number
            max_length = vim.o.columns * 2 / 3,
            filetype_names = {
              TelescopePrompt = 'Telescope',
              dashboard = 'Dashboard',
              packer = 'Packer',
              fzf = 'FZF',
              alpha = 'Alpha'
            },
            use_mode_colors = false,
            buffers_color = {
              -- Ensure these are valid highlight group names
              active = 'lualine_x_normal',     -- Color for active buffer.
              inactive = 'lualine_x_inactive', -- Color for inactive buffer.
            },
            symbols = {
              modified = ' ●',      -- Text to show when the buffer is modified
              alternate_file = '#', -- Text to show to identify the alternate file
              directory =  '',     -- Text to show when the buffer is a directory
            },
          }
        },
        lualine_y = {'progress'},
        lualine_z = {
          {
            'searchcount',
            maxcount = 999,
            timeout = 50,
          },
          {
            'datetime'
          }
        }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {{ 'filename', path = 1 }},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = { 'datetime' }
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {}
    }
}
