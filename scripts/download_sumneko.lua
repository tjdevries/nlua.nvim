local Job = require('plenary.job')
local log = require('plenary.log')

local GITHUB_URL = "https://github.com/sumneko/lua-language-server/"

local directory = require('nlua.lsp.nvim').base_directory

local run = function(input)
  local args = {}
  for _, v in ipairs(input) do
    table.insert(args, v)
  end

  local command = table.remove(args, 1)

  Job:new {
    command = command,
    args = args,

    cwd = input.cwd,

    on_stdout = vim.schedule_wrap(function(_, data)
      print(command, ":", data)
    end),
  }:sync(10000, nil, true)
end

local function download()
  if 0 == vim.fn.isdirectory(directory) then
    run {
      "git",
      "clone",
      GITHUB_URL,
      directory
    }
  else
    run {
      "git", "pull",
      cwd = directory,
    }
  end

  run {
    "git", "submodule", "update", "--init", "--recursive",
    cwd = directory
  }
end

local function build()
  run {
    "ninja", "-f", string.format("ninja/%s.ninja", jit.os == "OSX" and "macOS" or string.lower(jit.os)),
    cwd = directory .. "/3rd/luamake",
  }

  run {
    "./3rd/luamake/luamake", "rebuild",
    cwd = directory,
  }
end

download()
build()
