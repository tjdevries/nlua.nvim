local nlua_nvim_lsp = {}

local sumneko_command = function()
  local cache_location = vim.fn.stdpath('cache')

  -- TODO: Need to figure out where these paths are & how to detect max os... please, bug reports
  local bin_location = jit.os

  return {
    string.format(
      "%s/nvim_lsp/sumneko_lua/lua-language-server/bin/%s/lua-language-server",
      cache_location,
      bin_location
    ),
    "-E",
    string.format(
      "%s/nvim/nvim_lsp/sumneko_lua/lua-language-server/main.lua",
      cache_location
    ),
  }
end

local function get_lua_runtime()
    local result = {};
    for _, path in pairs(vim.api.nvim_list_runtime_paths()) do
        local lua_path = path .. "/lua/";
        if vim.fn.isdirectory(lua_path) then
            result[lua_path] = true
        end
    end

    -- This loads the `lua` files from nvim into the runtime.
    result[vim.fn.expand("$VIMRUNTIME/lua")] = true

    -- TODO: Figure out how to get these to work...
    --  Maybe we need to ship these instead of putting them in `src`?...
    result[vim.fn.expand("~/build/neovim/src/nvim/lua")] = true

    return result;
end

nlua_nvim_lsp.setup = function(nvim_lsp, config)
  nvim_lsp.sumneko_lua.setup({
    -- Lua LSP configuration
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",

          -- TODO: Figure out how to get plugins here.
          -- path = vim.split(package.path, ';'),
          -- path = {package.path},
        },

        completion = {
          -- You should use real snippets
          keywordSnippet = "Disable",
        },

        diagnostics = {
          enable = true,
          disable = config.disabled_diagnostics or {
            "trailing-space",
          },
          globals = vim.list_extend({
              -- Neovim
              "vim",
              -- Busted
              "describe", "it", "before_each", "after_each", "teardown", "pending"
            }, config.globals or {}
          ),
        },

        workspace = {
          library = vim.list_extend(get_lua_runtime(), config.library or {}),
          maxPreload = 1000,
          preloadFileSize = 1000,
        },
      }
    },

    -- Runtime configurations
    filetypes = {"lua"},

    cmd = sumneko_command(),

    on_attach = config.on_attach,

    callbacks = config.callbacks
  })
end

nlua_nvim_lsp.hover = function()
  vim.lsp.buf.hover()
end

return nlua_nvim_lsp
