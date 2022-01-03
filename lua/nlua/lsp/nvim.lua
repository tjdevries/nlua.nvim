local cache_location = vim.fn.stdpath('cache')

local system_name
if vim.fn.has("mac") == 1 then
  system_name = "macOS"
elseif vim.fn.has("unix") == 1 then
  system_name = "Linux"
elseif vim.fn.has('win32') == 1 then
  system_name = "Windows"
else
  print("Unsupported system for nlua.nvim/sumneko")
end

local nlua_nvim_lsp = {
  base_directory = string.format(
    "%s/nlua/sumneko_lua/lua-language-server/",
    cache_location
  ),

  bin_location = string.format(
    "%s/nlua/sumneko_lua/lua-language-server/bin/%s/lua-language-server",
    cache_location,
    system_name
  ),
}

local sumneko_command = function()
  return {
    nlua_nvim_lsp.bin_location,
    "-E",
    string.format(
      "%s/main.lua",
      nlua_nvim_lsp.base_directory
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

  -- This loads the `lsp` files into the runtime
  result[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true

  return result;
end

nlua_nvim_lsp.setup = function(nvim_lsp, config)
  local cmd = config.cmd or sumneko_command()
  local executable = cmd[1]

  if vim.fn.executable(executable) == 0 then
    print("Could not find sumneko executable:", executable)
    return
  end

  if vim.fn.filereadable(cmd[3]) == 0 then
    print("Could not find resulting build files", cmd[3])
    return
  end

  nvim_lsp.sumneko_lua.setup({
    cmd = cmd,

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

          -- I can use builtin vim for this. Please stop :)
          showWord = "Disable",
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
              "describe", "it", "before_each", "after_each", "teardown", "pending", "clear",
            }, config.globals or {}
          ),
        },

        workspace = {
          library = vim.list_extend(get_lua_runtime(), config.library or {}),
          maxPreload = 10000,
          preloadFileSize = 10000,
        },
      }
    },

    -- Runtime configurations
    filetypes = {"lua"},

    on_attach = config.on_attach,
    handlers = config.handlers,
    capabilities = config.capabilities,
  })
end

nlua_nvim_lsp.hover = function()
  vim.lsp.buf.hover()
end

return nlua_nvim_lsp
