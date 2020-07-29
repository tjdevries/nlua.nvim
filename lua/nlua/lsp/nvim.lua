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

nlua_nvim_lsp.setup = function(nvim_lsp, config)
  -- Sets currently active lsp
  require('nlua.lsp').set_lsp(nlua_nvim_lsp)

  nvim_lsp.sumneko_lua.setup({
    -- Lua LSP configuration
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",

          -- TODO: Figure out how to get plugins here.
          path = vim.split(package.path, ';'),
          -- path = {package.path},
        },
        diagnostics = {
          enable = true,
          globals = vim.list_extend({
              -- Neovim
              "vim",
              -- Busted
              "describe", "it", "before_each", "after_each"
            }, config.globals or {}
          ),
        },

        workspace = {
          library = vim.list_extend({
              -- This loads the `lua` files from nvim into the runtime.
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,

              -- TODO: Figure out how to get these to work...
              --  Maybe we need to ship these instead of putting them in `src`?...
              [vim.fn.expand("~/build/neovim/src/nvim/lua")] = true,
            }, config.library or {}
          ),
        },
      }
    },

    -- Runtime configurations
    filetypes = {"lua"},

    cmd = sumneko_command(),

    on_attach = config.on_attach
  })
end

nlua_nvim_lsp.hover = function()
  vim.lsp.buf.hover()
end

return nlua_nvim_lsp
