-- redthom --

-- lazy --

require("config.lazy")

-- lspconfig --

vim.lsp.enable({ "lua_ls", "jdtls", "clangd" })

-- Key Maps --

vim.keymap.set("n", "<space><space>x", "<cmd>source %<CR>")
vim.keymap.set("n", "<space>x", ":.lua<CR>")
vim.keymap.set("v", "<space>x", ":lua<CR>")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- general options --

---- variables ----

local option = vim.opt
local global = vim.g

---- appearance ----

global.have_nerd_font = true
option.showmode = false
option.list = true
option.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
option.termguicolors = true
option.cursorline = true

---- formating ----

option.number = true
option.relativenumber = true
option.shiftwidth = 2

---- work flow ----

option.clipboard = 'unnamedplus'
option.ignorecase = true
option.smartcase = true
option.inccommand = 'split'
option.confirm = true

-- highlight yanking --

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
