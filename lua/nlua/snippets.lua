local indent = require('snippets.utils').match_indentation

local M = {}

-- TODO: Decide if we actually want to do that.
M.get_snip_metatable = function(obj)
  return setmetatable(obj or {}, {
  })
end


M.get_lua_snippets = function()
  return {
    func      = [[function${1|vim.trim(S.v):gsub("^%S"," %0")}(${2|vim.trim(S.v)})$0 end]],
    req       = [[local ${2:${1|S.v:match"%w+$"}} = require('$1')]],
    ["local"] = [[local ${2:${1|S.v:match"[^.]+$"}} = ${1}]],

    -- TODO: It would be cool to do a more complicated if/elseif/else setup... seems hard
    ["if"] = indent "if $1 then\n  $0\nend",

    -- Neovim specific.
    cmd = "vim.cmd [[$0]]",

    -- Busted helpers
    describe = indent "describe('$1', function()\n  $0\nend)",
    it       = indent "it('$1', function()\n  $0\nend)",
  }
end

return M
