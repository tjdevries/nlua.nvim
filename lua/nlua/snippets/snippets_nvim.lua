vim.api.nvim_err_writeln("Hey, you should be doing `require('nlua.snippets')` now, instead of `require('nlua.snippets.snippets_nvim')`")

return require('nlua.snippets')
