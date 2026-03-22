-- :ASK <prompt> — ask Claude a question
vim.api.nvim_create_user_command("ASK", function(opts)
    require("ask").query(opts.args)
end, { nargs = "+" })

-- :'<,'>ASKV <prompt> — ask about the selected code
vim.api.nvim_create_user_command("ASKV", function(opts)
    require("ask").query_visual(opts.args, opts.line1, opts.line2)
end, { nargs = "+", range = true })

-- :ASKH — browse session history
vim.api.nvim_create_user_command("ASKH", function(opts)
    require("ask").show_history(tonumber(opts.fargs[1]))
end, { nargs = "?" })
