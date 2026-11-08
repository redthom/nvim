-- formatting --
local set = vim.opt_local

set.shiftwidth = 4
set.number = true
set.relativenumber = true

-- jdtls, debugging and JUnit tests: see lua/java/init.lua
require('java').attach()
