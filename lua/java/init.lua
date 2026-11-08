-- Java support: starts jdtls (via nvim-jdtls) with debugging and JUnit test bundles.
-- Called from after/ftplugin/java.lua for every Java buffer.
-- All external tools are installed by hand (no Mason); see java_debugging.md.
local M = {}

local data = vim.fn.expand('~/.local/share')
local jdtls_bin = data .. '/jdtls/bin/jdtls'
local java_debug_dir = data .. '/java-debug'
local java_test_dir = data .. '/vscode-java-test/extension/server'

-- These jars are used by the test runner itself and must not be loaded by jdtls.
local excluded_test_jars = {
  ['com.microsoft.java.test.runner-jar-with-dependencies.jar'] = true,
  ['jacocoagent.jar'] = true,
}

local build_markers = {
  'pom.xml', 'mvnw',
  'build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts', 'gradlew',
}
local plain_markers = { 'src', 'test', '.git' }

local warned = {}
local function warn_once(key, msg)
  if warned[key] then return end
  warned[key] = true
  vim.notify(msg, vim.log.levels.WARN)
end

--- Find the project root.
--- @return string|nil root, boolean is_build_project
function M.find_root(buf)
  local root = vim.fs.root(buf, build_markers)
  if root then return root, true end
  root = vim.fs.root(buf, plain_markers)
  return root, false
end

local function bundles()
  local result = vim.fn.glob(java_debug_dir .. '/com.microsoft.java.debug.plugin-*.jar', true, true)
  if #result == 0 then
    warn_once('debug', 'java-debug jar not found in ' .. java_debug_dir .. ' (debugging and tests disabled)')
  end

  local test_jars = vim.tbl_filter(function(jar)
    return not excluded_test_jars[vim.fs.basename(jar)]
  end, vim.fn.glob(java_test_dir .. '/*.jar', true, true))
  if #test_jars == 0 then
    warn_once('test', 'vscode-java-test jars not found in ' .. java_test_dir .. ' (running tests disabled)')
  end

  vim.list_extend(result, test_jars)
  return result
end

local function settings(root, is_build_project)
  local java = {
    import = { generatesMetadataFilesAtProjectRoot = false },
  }
  if not is_build_project then
    -- Plain project: src/ and test/ are source folders, jars in lib/ are on the classpath.
    local source_paths = vim.tbl_filter(function(dir)
      return vim.fn.isdirectory(root .. '/' .. dir) == 1
    end, { 'src', 'test' })
    java.project = {
      sourcePaths = #source_paths > 0 and source_paths or { 'src' },
      referencedLibraries = { 'lib/**/*.jar' },
      outputPath = 'bin',
    }
  end
  return { java = java }
end

local function on_attach(_, buf)
  local function map(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { buffer = buf, desc = desc })
  end
  map('<leader>tc', function() require('jdtls').test_class() end, 'Java: test class')
  map('<leader>tm', function() require('jdtls').test_nearest_method() end, 'Java: test nearest method')
  map('<leader>tp', function() require('jdtls').pick_test() end, 'Java: pick test to run')
  map('<leader>ts', function() require('jdtls.tests').goto_subjects() end, 'Java: jump between test and subject')
  map('<leader>tg', function() require('jdtls.tests').generate() end, 'Java: generate tests')
end

function M.attach(buf)
  buf = buf or vim.api.nvim_get_current_buf()

  -- skip unnamed/scratch and non-file (jdt://) buffers
  local fname = vim.api.nvim_buf_get_name(buf)
  if fname == '' or not vim.uv.fs_stat(fname) then return end

  local root, is_build_project = M.find_root(buf)
  if not root then return end

  -- one jdtls workspace per project; the hash keeps same-named projects apart
  local name = vim.fs.basename(root) .. '-' .. vim.fn.sha256(root):sub(1, 8)
  local workspace = vim.fn.stdpath('cache') .. '/jdtls/workspace/' .. name

  require('jdtls').start_or_attach({
    cmd = { jdtls_bin, '-data', workspace },
    root_dir = root,
    init_options = { bundles = bundles() },
    settings = settings(root, is_build_project),
    on_attach = on_attach,
  }, nil, { bufnr = buf })
end

return M
