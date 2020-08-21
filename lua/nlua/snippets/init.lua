local _currently_use_snippet_manager = nil

local M = {}

M.set_snippets = function(module)
  _currently_use_snippet_manager = module
end

return M
