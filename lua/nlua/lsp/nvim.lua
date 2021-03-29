-- OS and filesystem
local hizz = os.getenv("HOME")
local cache_location = vim.fn.stdpath('cache')

-- TODO: not sure how/where/when to implement this without a creating a global option. specifically, i am having
-- a chicken or egg problem with specifying the location of the sumenko clone. the problem is
-- completely avoided if the user specifies a proper sumenko command in their lsp config, but that
-- kinda sorta cuts against the purpose of this plugin
local neko_repo = hizz .. "/gits"
local neko
if vim.fn.filereadable(neko_repo) then
  neko = neko_repo .. "/lua-language-server"
else
  neko = cache_location .. "/nlua/sumenko_lua/lua-language-server"
end

local bin_folder
if vim.loop.os_uname().sysname == "Darwin" then
  bin_folder = '/macOS/bin'
else
  bin_folder = '/Linux/bin'
end


local nlua_nvim_lsp = {
  base_directory = neko,
  bin_location = neko .. bin_folder .. "/lua-language-server"
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

-- ADDED: 1.) extra (perhaps unecessary) $VIMRUNTIME and 2.) config.nvim_repo/build_foo gets passed during setup below
local function get_lua_runtime(foo)
  local result = {};
  for _, path in pairs(vim.api.nvim_list_runtime_paths()) do
    local lua_path = path .. "/lua/";
    if vim.fn.isdirectory(lua_path) then
      result[lua_path] = true
    end
  end

  -- This loads the `lua` files from nvim into the runtime.
  result[vim.fn.expand("$VIMRUNTIME/lua")] = true
  result[vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
  result[foo .. "/src/nvim/lua"] = true

  return result;
end

--[[ ADDED:
1. optional config specifications:
   - config.cmd = sumneko_command
   - capabilities
   - config.nvim_repo
   - config.on_init
2. disable telemetry
--]]

nlua_nvim_lsp.setup = function(nvim_lsp, config)
  local cmd = config.cmd or sumneko_command()
  local capabilities = config.capabilities or vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  local build_foo = config.nvim_repo or hizz .. '/build/neovim'
  -- local rt_foo = config.nvim_rt or hizz .. '/.local/share/nvim/runtime'
  -- if homebrew_install then
  -- rt_foo = '/usr/local/share/nvim/runtime'

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
    capabilities = capabilities,

    -- Lua LSP configuration
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
          path = vim.split(package.path, ';'),
        },
        diagnostics = {
          enable = true,
          disable = config.disabled_diagnostics or "trailing-space",
          globals = vim.list_extend({
            -- Neovim
            "vim",
            -- Busted
            "describe", "it", "before_each", "after_each", "teardown", "pending"
          }, config.globals or {}
          ),
        },
        telemetry = {
          enable = false
        },

        workspace = {
          library = vim.list_extend(get_lua_runtime(build_foo), config.library or {}),
          maxPreload = 2000,
          preloadFileSize = 1000,
        },
      }
    },

    -- Runtime configurations
    filetypes = {"lua"},

    on_attach = config.on_attach,
    on_init = config.on_init,
    handlers = config.handlers,
  })
end

nlua_nvim_lsp.hover = function()
  vim.lsp.buf.hover()
end

return nlua_nvim_lsp
