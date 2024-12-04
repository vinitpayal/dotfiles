vim.g.copilot_node_command = '~/.nvm/versions/node/v23.1.0/bin/node'

return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy"
    },
    { 'nvim-tree/nvim-web-devicons' },
    { 'nvim-lua/plenary.nvim' },
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
          require("nvim-tree").setup({})
        end
    },
    { 'nvim-treesitter/nvim-treesitter' },
    { 'danilamihailov/beacon.nvim' },
    { 'nvim-lualine/lualine.nvim' ,
      opts = {
        theme = 'rose-pine'
      }
    },
    { 'nvim-telescope/telescope.nvim' },
    { 'voldikss/vim-floaterm' },
    --{ 'lukas-reineke/indent-blankline.nvim' },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        ---@module "ibl"
        ---@type ibl.config
        opts = {},
    },
    { 'BurntSushi/ripgrep' },
    { 'sharkdp/fd' },
    { 'kdheepak/lazygit.nvim' },
    { 'f-person/git-blame.nvim' },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "neovim/nvim-lspconfig" },
    { "sunjon/shade.nvim" },
    { "L3MON4D3/LuaSnip" },
    { 'princejoogie/dir-telescope.nvim' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/nvim-cmp' },
    { 'saadparwaiz1/cmp_luasnip' },
    { "0oAstro/dim.lua" },
    { "AckslD/nvim-neoclip.lua" },
    { "github/copilot.vim" },
    {
      "gennaro-tedesco/nvim-jqx",
      event = {"BufReadPost"},
      ft = { "json", "yaml" },
    },
    {
      "rachartier/tiny-inline-diagnostic.nvim",
      event = "VeryLazy", -- Or `LspAttach`
      priority = 1000, -- needs to be loaded in first
      config = function()
          require('tiny-inline-diagnostic').setup()
      end
    }
}
