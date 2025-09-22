vim.g.copilot_node_command = '~/.nvm/versions/node/v23.1.0/bin/node'

return {
    { "catppuccin/nvim", name = "catppuccin", priority = 1000, config = function()
        vim.cmd.colorscheme "catppuccin"
    end },
    {
        "folke/which-key.nvim",
        event = "VeryLazy"
    },
    { 'nvim-tree/nvim-web-devicons' },
    { 'nvim-lua/plenary.nvim' },
    { 'rcarriga/nvim-notify' },
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
          require("nvim-tree").setup({})
        end
    },
    { 'nvim-treesitter/nvim-treesitter' },
    { 'danilamihailov/beacon.nvim' },
    {  "zbirenbaum/copilot.lua" },
    {
      "zbirenbaum/copilot.lua",
      requires = {
        "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
      },
      cmd = "Copilot",
      event = "InsertEnter",
      config = function()
        require("copilot").setup({})
      end,
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
    { 'kevinhwang91/nvim-ufo' },
    { 'kevinhwang91/promise-async' },
    { 'rmagatti/goto-preview' },
    { "0oAstro/dim.lua" },
    { "AckslD/nvim-neoclip.lua" },
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
