-- [[ plug.lua ]]
return require('packer').startup(function(use)
  use { -- filesystem navigation
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-tree.lua',
    'nvim-tree/nvim-web-devicons',
    'nvim-treesitter/nvim-treesitter',
    'danilamihailov/beacon.nvim',
    'nvim-lualine/lualine.nvim',
    --'Mofiqul/dracula.nvim',
    'nvim-telescope/telescope.nvim', tag = '0.1.1',
    'voldikss/vim-floaterm',
    'lukas-reineke/indent-blankline.nvim',
    'BurntSushi/ripgrep',
    'sharkdp/fd',
    'nvim-telescope/telescope-fzf-native.nvim', run =
  'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
    'kdheepak/lazygit.nvim',
    'f-person/git-blame.nvim',

    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "sunjon/shade.nvim",
    --"mfussenegger/nvim-lint",
    "github/copilot.vim",

    --- THEMES -> Start -------
    "ellisonleao/gruvbox.nvim"

    --'phha/zenburn.nvim',
    --'projekt0n/github-nvim-theme', --- good one
    -- 'navarasu/onedark.nvim',
    --'EdenEast/nightfox.nvim',
    --'folke/neodev.nvim',
    --'mfussenegger/nvim-dap',
    --'rcarriga/nvim-dap-ui',
    --'christoomey/vim-tmux-navigator',
    --'embark-theme/vim', as = 'embark'
    --    'marko-cerovac/material.nvim'
    --'ellisonleao/gruvbox.nvim'
    --- THEMES -> End -------

  }

  use {
      "microsoft/vscode-js-debug",
      opt = true,
      run = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out" 
  }

  use({
    "L3MON4D3/LuaSnip",
    run = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" }, -- follow latest release.
  })

  -- for folding, maybe can be removed
  use {'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async'}

  use { 'princejoogie/dir-telescope.nvim' }

  use { "mxsdev/nvim-dap-vscode-js", requires = {"mfussenegger/nvim-dap"} }


  --- dependencies for auto suggestion ----
  use {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/nvim-cmp',
    'saadparwaiz1/cmp_luasnip',
    --'hrsh7th/cmp-buffer',
    --'hrsh7th/cmp-path',
    --'hrsh7th/cmp-cmdline',
    --'hrsh7th/cmp-vsnip',
    --'hrsh7th/vim-vsnip',
  }
  
  use {
      "AckslD/nvim-neoclip.lua",
      config = function()
        require('neoclip').setup({
          history = 1000,
          filter = nil,
          preview = true,
          prompt = nil,
          on_select = {
            move_to_front = false,
            close_telescope = true,
          },
          on_paste = {
            set_reg = false,
            move_to_front = false,
            close_telescope = true,
          },
          on_replay = {
            set_reg = false,
            move_to_front = false,
            close_telescope = true,
          },
          keys = {
            i = {
              select = "<cr>",
              paste = "<c-p>",
              paste_behind = "<c-k>",
              custom = {},
            },
            n = {
              select = "<cr>",
              paste = "p",
              paste_behind = "P",
              custom = {},
            },
          },
        })
      end,
  }


 use {
      "0oAstro/dim.lua",
      requires = { "nvim-treesitter/nvim-treesitter", "neovim/nvim-lspconfig" },
      config = function()
        require('dim').setup({})
      end
}

use {
    'Joakker/lua-json5',
    -- if you're on windows
    -- run = 'powershell ./install.ps1'
    run = './install.sh'
}


  use {
    "folke/which-key.nvim",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end
  }
  config = {
    package_root = vim.fn.stdpath('config') .. '/site/pack'
  }
end)
