package.loaded['nlua.include_expr'] = nil
local g = require('domain.global')

--[[
require("asdf")
require("wow")
require("hello.world")

vim.bo.includeexpr = 'v:lua.nlua.include_expr(v:fname)'

nnoremap <buffer> gf <cmd>:lua require('find_require').find_require()<CR>
--]]

return function(filename)
  local to_search

  if not filename then
    local line = vim.fn.getline('.')

    -- require('.*')
    local result = string.match(line, [[require%('(.*)'%)]])

    -- require'.*'
    if result == nil then
      result = string.match(line [[require'(.*)']])
    end

    -- require(".*")
    if result == nil then
      result = string.match(line, [[require%("(.*)"%))]])
    end

    -- require".*"
    if result == nil then
      result = string.match(line [[require(".*"%)]])
    end

    to_search = result
  else
    to_search = filename
  end

  local found_file = package.searchpath(to_search, g.foonv )

  if not found_file then
    found_file = package.searchpath(to_search, package.path)
  end

  if not found_file then
    found_file = package.searchpath(to_search, package.cpath)
  end

  -- TODO: What happens when it's nil?
  return found_file or ""
end
