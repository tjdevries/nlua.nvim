-- TODO: Keep track of which lsp is loaded...?

-- Make into a global, so that we can use `v:lua` when we want
nlua = {
  include_expr = require('nlua.include_expr'),

  keyword_program = function(word)
    local original_iskeyword = vim.bo.iskeyword

    vim.bo.iskeyword = vim.bo.iskeyword .. ',.'
    word = word or vim.fn.expand("<cword>")

    vim.bo.iskeyword = original_iskeyword

    -- TODO: This is kind of a lame hack... since you could rename `vim.api` -> `a` or similar
    if string.find(word, 'vim.api') then
      local _, finish = string.find(word, 'vim.api.')
      local api_function = string.sub(word, finish + 1)

      vim.cmd(string.format('help %s', api_function))
      return
    elseif string.find(word, 'vim.fn') then
      local _, finish = string.find(word, 'vim.fn.')
      local api_function = string.sub(word, finish + 1) .. '()'

      vim.cmd(string.format('help %s', api_function))
      return
    else
      -- TODO: This should be exact match only. Not sure how to do that with `:help`
      -- TODO: Let users determine how magical they want the help finding to be
      local ok = pcall(vim.cmd, string.format('help %s', word))

      if not ok then
        local split_word = vim.split(word, '.', true)
        ok = pcall(vim.cmd, string.format('help %s', split_word[#split_word]))
      end

      if not ok then
        vim.lsp.buf.hover()
      end
    end
  end,

  -- TODO: We should use this...
  format_expr = function()
    local mode = vim.fn.mode()
    if mode == 'i' or mode == 'R' then
      return 1
    end

    return 0
  end,

  -- TODO: Figure out the "right" way to do the auto formatting here.
  -- TODO: Would be cool to use the lua format library directly in lua?
  -- TODO: Maybe we can do this with popen and read the results?
  --        I don't want to apply a bunch of edits though, because that will mess up the undo history?
  --        When we do that, we'd instead want to set them in one go.
  format_file = function(filename)
    filename = filename or vim.fn.expand('%:p')

    os.execute(string.format('lua-format -i %s', filename))
    vim.cmd [[e!]]
  end,

  async_format_file = function(filename, lua_format_file)
    filename = filename or vim.fn.expand('%:p')

    local results = {}
    local format_job = vim.fn.jobstart(string.format("lua-format"), {
      on_stdout = function(_, d, _)
        table.insert(results, d)
      end,
      on_stderr = function(_, d, _)
        table.insert(results, d)
      end,
    })

    if format_job <=0 then
      print("Failed to make the job...")
      return
    end

    vim.fn.chansend(format_job, vim.api.nvim_buf_get_lines(0, 0, -1, false))

    vim.wait(1000, function()
      return vim.fn.jobwait({format_job}, 0)[0] == 0
    end)

    print("Sending...")
    print(vim.inspect(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")))
    print("...Recvd")
    print(vim.inspect(results))
    if results then return end

    local system_args = {
      'lua-format',
      filename,
      '-i'
    }


    if lua_format_file then
      table.insert(system_args, '-c')
      table.insert(system_args, lua_format_file)
    else
      -- TODO: Find a lua_format.yaml file somewhere in your parent directories.

      -- The program will attempt to automatically use the current directory's
      -- .lua-format file if no config file is passed in the command line. On Linux
      -- it will use $XDG_CONFIG_HOME/luaformatter/config.yaml if .lua-format does
      -- not exist. In case there's no file, it will fallback to the default
      -- configuration. The program will give the top priority to the configuration
      -- values given in the command-line, then to the configuration files and
      -- finally to the hard-coded default values.
    end

    local result = vim.fn.systemlist(system_args)
    print(result)
  end
}

return nlua
