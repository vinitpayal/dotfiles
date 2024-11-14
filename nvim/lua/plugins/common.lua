return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy"
    },
    { 'nvim-lua/plenary.nvim' },
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
          "nvim-tree/nvim-web-devicons",
        },
        config = function()
          require("nvim-tree").setup {}
        end,
    },
    { 'nvim-tree/nvim-web-devicons' },
    { 'nvim-treesitter/nvim-treesitter' },
    { 'danilamihailov/beacon.nvim' },
    { 'nvim-lualine/lualine.nvim' },
    { 'nvim-telescope/telescope.nvim' },
    { 'voldikss/vim-floaterm' },
    { 'lukas-reineke/indent-blankline.nvim' },
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
}
