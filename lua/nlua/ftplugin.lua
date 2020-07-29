-- TODO: This should get moved to `ftplugin/lua.lua` when neovim supports that.
--[[
function! s:matchfilter(list, pat) abort
  return filter(map(copy(a:list), 'matchstr(v:val, '.string(a:pat).')'), 'len(v:val)')
endfunction

if !exists('g:lua_path')
  let g:lua_path = split(system('lua -e "print(package.path)"')[0:-2], ';')
  if v:shell_error || empty(g:lua_path)
    let g:lua_path = ['./?.lua', './?/init.lua']
  endif
endif

call apathy#Prepend('path', s:matchfilter(g:lua_path, '^[^?]*[^?\/]'))
]]

-- Goal: /usr/local/share/lua/5.3,/usr/local/lib/lua/5.3,.,,
local function setup_path()
  local split_paths = vim.split(package.path, ";")

  local paths = {}
  for _, v in ipairs(split_paths) do
    table.insert(paths, vim.fn.fnamemodify(v, ":p:h"))
  end

  local concat_paths = table.concat(paths, ",")

  -- TODO: Make sure we don't put this in over and over and over...
  vim.bo.path = concat_paths .. "," .. vim.o.path
end

return function()
  -- Setup `gf` and include-style options.
  vim.bo.include = [[\v<((do|load)file|require)[^''"]*[''"]\zs[^''"]+]]
  vim.bo.includeexpr = 'v:lua.nlua.include_expr(v:fname)'

  -- TODO: Find a lua formatter that could actually support this.
  --        As well as equalprg and related.
  -- vim.bo.formatexpr = 'v:lua.nlua.format_expr()'

  setup_path()

  -- TODO: Document this:
  --    if vim.api.nvim_buf_get_option(0, 'filetype') ~= 'lua' then
  --      mapper('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
  --    end
  -- TODO: Customize keymap
  vim.api.nvim_buf_set_keymap(0, 'n', 'K', '<cmd>lua nlua.keyword_program()<CR>', {noremap = true, silent = true})
end
