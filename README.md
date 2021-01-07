# nlua.nvim

Lua Development for Neovim

## Installation Guide

BREAKING:

With the removal of `LspInstall` I added something that should allow you to install sumneko lua.
Check out the `scripts/download_sumneko.lua` file. You should be able to run this (if you have plenary installed).

I will try and make this better later. Sorry if I messed up your configs with this change.

```vim
" Install this plugin.
Plug 'tjdevries/nlua.nvim'

" (OPTIONAL): If you want to use built-in LSP (requires Neovim HEAD)
"   Currently only supported LSP, but others could work in future if people send PRs :)
Plug 'neovim/nvim-lspconfig'

" (OPTIONAL): This is recommended to get better auto-completion UX experience for builtin LSP.
Plug 'nvim-lua/completion-nvim'

" (OPTIONAL): This is a suggested plugin to get better Lua syntax highlighting
"   but it's not currently required
Plug 'euclidianAce/BetterLua.vim'

" (OPTIONAL): If you wish to have fancy lua folds, you can check this out.
Plug 'tjdevries/manillua.nvim'
```


## Configuration

```lua

-- Your custom attach function for nvim-lspconfig goes here.
local custom_nvim_lspconfig_attach = function(...) end

-- To get builtin LSP running, do something like:
-- NOTE: This replaces the calls where you would have before done `require('nvim_lsp').sumneko_lua.setup()`
require('nlua.lsp.nvim').setup(require('lspconfig'), {
  on_attach = custom_nvim_lspconfig_attach,

  -- Include globals you want to tell the LSP are real :)
  globals = {
    -- Colorbuddy
    "Color", "c", "Group", "g", "s",
  }

  -- Optional command to run the sumneko lua language server
  -- cmd = {"lua-language-server", "-E", "~/build/lua-language-server/main.lua"}
})

```

## Example Completions

![ExampleCompletions](./media/example_completions.png)


## TODO:

https://github.com/bfredl/nvim-luadev

## Status:

- [x] `gf` should work with `require` and other items
- [x] Set `path` correctly for lua.
    - [ ] See if we can get `checkpath` to work.
        - It seems like it should, but not sure how to make that happen
        - I think this requires some understanding of `suffixesadd`
- [~] `K` should figure out if you're:
    - on a vim.fn style function
    - on a vim.api style function
    - on a vim.$something function
    - or on a lua built-in style function
    - Status:
        - It works when you write out the full names... but that doesn't seem super great
        - Kind of words when you type the whole name, but could have name clashes? Not clear.
- [ ] Add a `completion.nvim` source for currently available globals.
    - This won't be as good as something like sumneko, because that does actual analysis.
        But it could be good for finding all the things in `vim.api.*` etc.
- [ ] `include` should handle all the crazy ways you can make strings in lua.
- [ ] better text object support
    - Consider trying this out w/ tree sitter at some point...
- [ ] Add some "switch to test file" or other kind of thing
    - Could use projections, could use alternate.vim, ...?
- [ ] Set up for lua-formatter, cause that's really nice.
    - [x] Check if sumneko can do lua formatting...
        - Not currently supported as far as I can see
    - [ ] Add a "hack" for tempfile (opt-in) that formats the whole file, but we just replace the stuff we want to replace correctly. Could probably work... 90%ish time? We'd have to see.
- [ ] Include nvim-treesitter + nlua
