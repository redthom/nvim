-- formatting --
local set = vim.opt_local

set.shiftwidth = 4
set.number = true
set.relativenumber = true

-- jdtls (via nvim-jdtls) --

-- skip unnamed/scratch and non-file (jdt://) buffers
local fname = vim.api.nvim_buf_get_name(0)
if fname == '' or not vim.uv.fs_stat(fname) then return end

-- project root = parent of the nearest `src` directory
local src = vim.fs.find('src', { upward = true, type = 'directory', path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) })[1]
if not src then return end
local root = vim.fs.dirname(src)

-- java-debug extension, needed for nvim-dap debugging
local java_debug = vim.fn.expand('~/.local/share/java-debug')
local bundles = vim.fn.glob(java_debug .. '/com.microsoft.java.debug.plugin-*.jar', true, true)
if #bundles == 0 and not vim.g.java_debug_warned then
  vim.g.java_debug_warned = true
  vim.notify('java-debug jar not found in ' .. java_debug .. ' (debugging disabled)', vim.log.levels.WARN)
end

-- one jdtls workspace per project
local workspace = vim.fn.stdpath('cache') .. '/jdtls/workspace/' .. vim.fn.fnamemodify(root, ':p:h:t')

require('jdtls').start_or_attach({
  cmd = { vim.fn.expand('~/.local/share/jdtls/bin/jdtls'), '-data', workspace },
  root_dir = root,
  init_options = { bundles = bundles },
  settings = {
    java = {
      project = { sourcePaths = { 'src' } },
      import = { generatesMetadataFilesAtProjectRoot = false },
    },
  },
})
