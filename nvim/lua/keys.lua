-- [[ keys.lua ]]
local builtin = require('telescope.builtin')

vim.api.nvim_set_keymap('t', '<C-t>', '<C-\\><C-n>CR>', { noremap = true, silent = true })

local wk = require("which-key")
wk.register({
  ["<leader>"] = {
    name = "leader",
    f = {
      name = "+telescope",
      f = { builtin.find_files, "find files" },
      g = { builtin.live_grep, "live grep" },
      b = { builtin.buffers, "buffers" },
      h = { builtin.help_tags, "telescope help" },
      t = {
        name = "+floaterm",
        p = { [[:FloatermNew python3<CR>]], "python" },
        j = { [[:FloatermNew node<CR>]], "javascript" },
        l = { [[:FloatermNew lazygit<CR>]], "lazygit" },
        n = { [[:FloatermNew<CR>]], "new terminal" },
        t = { [[:FloatermToggle<CR>]], "toggle terminal" },
        m = { [[:FloatermNew --height=0.2 --wintype=split --position=bottom<CR>]], "mini term at bottom" },
        r = { [[:FloatermNew --width=0.45 --wintype=vsplit<CR>]], "mini term at right half" }
      },
    },
    e = { vim.diagnostic.open_float, "open diagnostics" },
    u = { [[:DBUIToggle<CR>]], "toggle dbui" },
    n = { [[:NvimTreeToggle<CR>]], "toggle nvim tree" },
    p = { [[:PackerSync<CR>]], "sync packer" },
    d = {
      b = { function() require('dap').toggle_breakpoint() end, "toggle breakpoints" },
      s = { function() require('dap').step_over() end, "step over" },
      u = { function() require("dapui").toggle() end, "toggle ui" }
    }
  },
  g = {
    b = { [[:GitBlameToggle<CR>]], "toggle git blame" },
    d = { vim.lsp.buf.definition, "go to definition" },
    D = { vim.lsp.buf.declaration, "go to declaration" },
    r = { vim.lsp.buf.references, "go to references" },
    R = { vim.lsp.buf.rename, "rename" },
    i = { vim.lsp.buf.implementation, "go to implementation" },
    s = { vim.lsp.buf.signature_help, "signature help" },
    t = { vim.lsp.buf.type_definition, "go to type definition" },
    f = { vim.lsp.buf.formatting, "format" },
    F = { vim.lsp.buf.formatting_sync, "format sync" },
    a = { vim.lsp.buf.code_action, "code action" },
    A = { vim.lsp.buf.range_code_action, "range code action" },
    e = { vim.lsp.diagnostic.show_line_diagnostics, "show line diagnostics" },
    E = { vim.lsp.diagnostic.set_loclist, "set loclist" },
    p = { vim.lsp.diagnostic.goto_prev, "go to previous diagnostic" },
    n = { vim.lsp.diagnostic.goto_next, "go to next diagnostic" },
    q = { vim.lsp.diagnostic.set_qflist, "set qflist" },
    l = { vim.lsp.diagnostic.show_line_diagnostics, "show line diagnostics" },
  }
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
    vim.lsp.buf.format { async = true }
    --end, opts)
  end,
})
