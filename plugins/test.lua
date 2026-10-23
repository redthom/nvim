vim.api.nvim_create_autocmd('InsertEnter', {
  desc = 'figuring out how these auto comands work',
  group = vim.api.nvim_create_augroup('print_on_insert', { clear = true }),
  callback = function()
    vim.print("my autocmd worked!")
  end,
})
