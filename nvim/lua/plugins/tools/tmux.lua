-- Only load which-key after it's available (handled by Lazy)

if vim.env.TMUX then
  local function tmux_or_split_switch(wincmd, tmuxdir)
    local previous_winnr = vim.fn.winnr()
    vim.cmd('wincmd ' .. wincmd)
    if previous_winnr == vim.fn.winnr() then
      vim.fn.system('tmux select-pane -' .. tmuxdir)
      vim.cmd('redraw!')
    end
  end

  -- Keymaps for tmux navigation can be set up in a plugin config block
end
