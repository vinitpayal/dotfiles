return {
  'kevinhwang91/nvim-ufo',
  dependencies = { { "kevinhwang91/promise-async", lazy = true } },
  opts = {
    provider_selector = function(bufnr, filetype, buftype)
          return {'treesitter', 'indent'}
    end
  }
}
