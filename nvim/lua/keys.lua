-- [[ keys.lua ]]
local builtin = require('telescope.builtin')
local telescope_extensions = require('telescope').extensions

vim.api.nvim_set_keymap('t', '<C-t>', '<C-\\><C-n>CR>', { noremap = true, silent = true })
local wk = require("which-key")

wk.add({
    { "<leader>", group = "<leader>" },
    { "<leader>c", group = "clipboard(neoclip)" },
    { "<leader>ch", ":lua require('telescope').extensions.neoclip.default()<CR>", desc = "search clipboard history" },

    { "<leader>f", group = "telescope" },
    { "<leader>ff", builtin.find_files, desc = "search files" },
    { "<leader>fk", builtin.live_grep, desc = "search keyword" },
    { "<leader>fm", builtin.lsp_dynamic_workspace_symbols, desc = "search methods" },
    { "<leader>fb", builtin.buffers, desc = "search buffers" },
    { "<leader>ft", builtin.treesitter, desc = "search treesitter" },

    { "<leader>fd", group = "dir" },
    { "<leader>fdf", telescope_extensions.dir.find_files, desc = "search files in dir" },
    { "<leader>fdk", telescope_extensions.dir.live_grep, desc = "search keyword in dir" },

    { "<leader>fg", group = "git" },
    { "<leader>fgb", builtin.git_branches, desc = "git branches" },
    { "<leader>fgc", builtin.git_bcommits, desc = "git current file commits" },
    { "<leader>fgs", builtin.git_status, desc = "git status" },
    { "<leader>fh", builtin.resume, desc = "search history" },
    { "<leader>fi", builtin.help_tags, desc = "telescope help" },
    { "<leader>fld", builtin.lsp_definitions, desc = "lsp definitions" },

    { "<leader>fl", group = "lsp" },
    { "<leader>fli", builtin.lsp_implementations, desc = "lsp implementations" },
    { "<leader>flr", builtin.lsp_references, desc = "lsp references" },

    { "<leader>n", ":NvimTreeToggle<CR>", desc = "toggle nvim tree" },

    { "<leader>t", group = "floaterm" },
    { "<leader>tl", ":FloatermNew --height=0.98 --width=0.98 lazygit<CR>", desc = "lazygit" },
    { "<leader>tm", ":FloatermNew --height=0.2 --wintype=split --position=bottom<CR>", desc = "mini term at bottom" },
    { "<leader>tn", ":FloatermNew<CR>", desc = "new terminal" },
    { "<leader>tr", ":FloatermNew --width=0.45 --wintype=vsplit<CR>", desc = "mini term at right half" },
    { "<leader>tt", ":FloatermToggle<CR>", desc = "toggle terminal" },
    -- { "<leader>u", ":DBUIToggle<CR>", desc = "toggle dbui" },
    { "g", group = "goto" },
    { "gp", group = "preview-plugin" },
    { "gpd", require('goto-preview').goto_preview_definition, desc = "goto_preview_definition" },
    { "gpi", require('goto-preview').goto_preview_implementation, desc = "goto_preview_implementation" },
    { "gpr", require('goto-preview').goto_preview_references, desc = "goto_preview_references" },
    { "gpt", require('goto-preview').goto_preview_type_definition, desc = "goto_preview_type_definition" },
    { "gP", require('goto-preview').close_all_win, desc = "close all previews" },

    { "v", group = "vcs" },
    { "vb", ":GitBlameToggle<CR>", desc = "toggle git blame" },

    { "z", group = "fold" },
    { "zM", require('ufo').closeAllFolds, desc = "ufo-close folds" },
    { "zP", require('ufo').peekFoldedLinesUnderCursor, desc = "Quick peek into folded area" },
    { "zR", require('ufo').openAllFolds, desc = "ufo-open folds" },

    {"+", ':exe "vertical resize " . (winwidth(0) * 3/2)<CR>'},
    {"-", ':exe "vertical resize " . (winwidth(0) * 2/3)<CR>'},
    {"]", ':exe "resize " . (winheight(0) * 3/2)<CR>'},
    {"[", ':exe "resize " . (winheight(0) * 2/3)<CR>'}
  })

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    --vim.lsp.buf.format { async = true }
    --end, opts)
  end,
})
