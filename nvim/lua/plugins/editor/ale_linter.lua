return {
  'dense-analysis/ale',
  config = function()
      -- Configuration goes here.
      local g = vim.g

      -- g.ale_ruby_rubocop_auto_correct_all = 1
      g.ale_fix_on_save = 1
      g.ale_sign_error = '❌'
      g.ale_sign_warning = '⚠️'

      g.ale_fixers = {
        javascript = { 'prettier' },
        python = { 'black' },
      }

      g.ale_linters = {
          ruby = {'rubocop', 'ruby'},
          lua = {'lua_language_server'},
          javascript= { 'prettier' },
          python = { 'flake8' },
      }
  end
}
