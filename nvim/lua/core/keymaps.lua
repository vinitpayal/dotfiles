-- [[ keys.lua ]]
-- Only require built-in or always-available modules at the top
-- Plugin-dependent keymaps should use string-based commands

vim.api.nvim_set_keymap('t', '<C-t>', '<C-\\><C-n>CR>', { noremap = true, silent = true })

local wk = require("which-key")

wk.add({
    { "<leader>", group = "<leader>" },
    { "<leader>c", group = "clipboard(neoclip)" },
    { "<leader>ch", ":lua require('telescope').extensions.neoclip.default()<CR>", desc = "search clipboard history" },

    { "<leader>f", group = "telescope" },
    { "<leader>ff", ":lua require('telescope.builtin').find_files()<CR>", desc = "search files" },
    { "<leader>fk", ":lua require('telescope.builtin').live_grep()<CR>", desc = "search keyword" },
    { "<leader>fm", ":lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<CR>", desc = "search methods" },
    { "<leader>fb", ":lua require('telescope.builtin').buffers()<CR>", desc = "search buffers" },
    { "<leader>ft", ":lua require('telescope.builtin').treesitter()<CR>", desc = "search treesitter" },

    { "<leader>fd", group = "dir" },
    { "<leader>fdf", ":lua require('telescope').extensions.dir.find_files()<CR>", desc = "search files in dir" },
    { "<leader>fdk", ":lua require('telescope').extensions.dir.live_grep()<CR>", desc = "search keyword in dir" },

    { "<leader>fg", group = "git" },
    { "<leader>fgb", ":lua require('telescope.builtin').git_branches()<CR>", desc = "git branches" },
    { "<leader>fgc", ":lua require('telescope.builtin').git_bcommits()<CR>", desc = "git current file commits" },
    { "<leader>fgs", ":lua require('telescope.builtin').git_status()<CR>", desc = "git status" },
    { "<leader>fh", ":lua require('telescope.builtin').resume()<CR>", desc = "search history" },
    { "<leader>fi", ":lua require('telescope.builtin').help_tags()<CR>", desc = "telescope help" },
    { "<leader>fld", ":lua require('telescope.builtin').lsp_definitions()<CR>", desc = "lsp definitions" },

    { "<leader>fl", group = "lsp" },
    { "<leader>fli", ":lua require('telescope.builtin').lsp_implementations()<CR>", desc = "lsp implementations" },
    { "<leader>flr", ":lua require('telescope.builtin').lsp_references()<CR>", desc = "lsp references" },

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
    { "gpd", ":lua require('goto-preview').goto_preview_definition()<CR>", desc = "goto_preview_definition" },
    { "gpi", ":lua require('goto-preview').goto_preview_implementation()<CR>", desc = "goto_preview_implementation" },
    { "gpr", ":lua require('goto-preview').goto_preview_references()<CR>", desc = "goto_preview_references" },
    { "gpt", ":lua require('goto-preview').goto_preview_type_definition()<CR>", desc = "goto_preview_type_definition" },
    { "gP", ":lua require('goto-preview').close_all_win()<CR>", desc = "close all previews" },

    { "v", group = "vcs" },
    { "vb", ":GitBlameToggle<CR>", desc = "toggle git blame" },

    { "z", group = "fold" },
    { "zM", ":lua require('ufo').closeAllFolds()<CR>", desc = "ufo-close folds" },
    { "zP", ":lua require('ufo').peekFoldedLinesUnderCursor()<CR>", desc = "Quick peek into folded area" },
    { "zR", ":lua require('ufo').openAllFolds()<CR>", desc = "ufo-open folds" },

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
