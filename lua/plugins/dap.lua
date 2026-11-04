-- Language adapters are registered elsewhere:
--   Java: nvim-jdtls (lua/plugins/jdtls.lua, after/ftplugin/java.lua)
return {
  'mfussenegger/nvim-dap',
  -- Lazy-load: the plugin is only loaded the first time one of these keys is pressed
  keys = {
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'DAP toggle breakpoint' },
    { '<leader>dc', function() require('dap').continue() end,          desc = 'DAP continue / start' },
    { '<leader>do', function() require('dap').step_over() end,         desc = 'DAP step over' },
    { '<leader>di', function() require('dap').step_into() end,         desc = 'DAP step into' },
    { '<leader>dO', function() require('dap').step_out() end,          desc = 'DAP step out' },
    { '<leader>dr', function() require('dap').repl.open() end,         desc = 'DAP open REPL' },
    { '<leader>dt', function() require('dap').terminate() end,         desc = 'DAP terminate' },
  },
}
