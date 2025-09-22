-- Tmux navigation integration
return {
  {
    "christoomey/vim-tmux-navigator",
    optional = true,
    config = function()
      -- Only set up tmux navigation if we're inside tmux
      if vim.env.TMUX then
        local function tmux_or_split_switch(wincmd, tmuxdir)
          local previous_winnr = vim.fn.winnr()
          vim.cmd('wincmd ' .. wincmd)
          if previous_winnr == vim.fn.winnr() then
            vim.fn.system('tmux select-pane -' .. tmuxdir)
            vim.cmd('redraw!')
          end
        end

        -- Set up keymaps for seamless tmux/vim navigation
        vim.keymap.set('n', '<C-h>', function() tmux_or_split_switch('h', 'L') end, { silent = true })
        vim.keymap.set('n', '<C-j>', function() tmux_or_split_switch('j', 'D') end, { silent = true })
        vim.keymap.set('n', '<C-k>', function() tmux_or_split_switch('k', 'U') end, { silent = true })
        vim.keymap.set('n', '<C-l>', function() tmux_or_split_switch('l', 'R') end, { silent = true })
      end
    end
  }
}
