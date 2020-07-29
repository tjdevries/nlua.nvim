local _currently_used_lsp = nil

local nlua_lsp = {}

nlua_lsp.set_lsp = function(mod)
  _currently_used_lsp = mod
end

nlua_lsp.hover = function()
  if not _currently_used_lsp then
    return
  end

  _currently_used_lsp.hover()
end

return nlua_lsp
