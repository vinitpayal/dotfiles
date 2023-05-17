-- [[ plug.lua ]]

return require('packer').startup(function(use)
  use { -- filesystem navigation
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-tree.lua',
    'nvim-tree/nvim-web-devicons',
    'nvim-treesitter/nvim-treesitter',
    'mhinz/vim-startify',
    'danilamihailov/beacon.nvim',
    'nvim-lualine/lualine.nvim',
    'Mofiqul/dracula.nvim',
    'nvim-telescope/telescope.nvim', tag = '0.1.1',
    'voldikss/vim-floaterm',
    'lukas-reineke/indent-blankline.nvim',
    'BurntSushi/ripgrep',
    'sharkdp/fd',
    'nvim-telescope/telescope-fzf-native.nvim', run =
  'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
    'jnurmine/Zenburn',
    'kdheepak/lazygit.nvim',
    'tpope/vim-dadbod',
    'kristijanhusak/vim-dadbod-ui',
    'folke/todo-comments.nvim',
    'f-person/git-blame.nvim',

    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-lint",
    "github/copilot.vim",

    --- THEMES -> Start -------
    'phha/zenburn.nvim',
    'projekt0n/github-nvim-theme', --- good one
    -- 'navarasu/onedark.nvim',
    'EdenEast/nightfox.nvim',
    'mfussenegger/nvim-dap',
    'rcarriga/nvim-dap-ui',
    'mxsdev/nvim-dap-vscode-js',
    'christoomey/vim-tmux-navigator',
    --'embark-theme/vim', as = 'embark'
    --    'marko-cerovac/material.nvim'
    --'ellisonleao/gruvbox.nvim'
    --- THEMES -> End -------

  }

  --- dependencies for auto suggestion ----
  use {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-vsnip',
    'hrsh7th/vim-vsnip'
  }

  use {
    "microsoft/vscode-js-debug",
    opt = true,
    run = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out"
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
