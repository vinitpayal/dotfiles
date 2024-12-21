local wk = require("which-key")

if vim.env.TMUX then
  local function tmux_or_split_switch(wincmd, tmuxdir)
    local previous_winnr = vim.fn.winnr()
    vim.cmd('wincmd ' .. wincmd)
    if previous_winnr == vim.fn.winnr() then
      vim.fn.system('tmux select-pane -' .. tmuxdir)
      vim.cmd('redraw!')
    end
  end

  --local previous_title = vim.fn.substitute(vim.fn.system('tmux display-message -p \'#{pane_title}\''), '\n', '', '')
  --vim.api.nvim_command('set t_ti=' .. '\27]2;vim\7')
  --vim.api.nvim_command('set t_te=' .. '\27]2;' .. previous_title .. '\7')

--  wk.add({
--    ["<C-h>"] = { ':lua tmux_or_split_switch("h", "L")<CR>', "Tmux Switch Left" },
--    ["<C-j>"] = { ':lua tmux_or_split_switch("j", "D")<CR>', "Tmux Switch Down" },
--    ["<C-k>"] = { ':lua tmux_or_split_switch("k", "U")<CR>', "Tmux Switch Up" },
--    ["<C-l>"] = { ':lua tmux_or_split_switch("l", "R")<CR>', "Tmux Switch Right" },
--  }, { prefix = "<C-w>" })
--else
--  wk.add({
--    ["<C-h>"] = { "<C-w>h", "Split Window Left" },
--    ["<C-j>"] = { "<C-w>j", "Split Window Down" },
--    ["<C-k>"] = { "<C-w>k", "Split Window Up" },
--    ["<C-l>"] = { "<C-w>l", "Split Window Right" },
--  }, { prefix = "<C-w>" })
end
