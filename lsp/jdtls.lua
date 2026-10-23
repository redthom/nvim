-- add jdtls to local PATH
vim.env.PATH = vim.fn.expand('~/.local/share/jdtls/bin') .. ':' .. vim.env.PATH

---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    for dir in vim.fs.parents(bufname) do
      if vim.fs.basename(dir) == 'src' then
        on_dir(vim.fs.dirname(dir))
        return
      end
    end
  end,
  settings = {
    java = {
      project = { sourcePaths = { 'src' } },
      import = { generatesMetadataFilesAtProjectRoot = false },
    },
  },
}
