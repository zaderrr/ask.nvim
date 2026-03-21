-- :CQ <prompt> — ask Claude a question
vim.api.nvim_create_user_command("CQ", function(opts)
    require("code-query").query(opts.args)
end, { nargs = "+" })

-- :'<,'>CQV <prompt> — ask about the selected code
vim.api.nvim_create_user_command("CQV", function(opts)
    require("code-query").query_visual(opts.args, opts.line1, opts.line2)
end, { nargs = "+", range = true })

-- :CQH — browse session history
vim.api.nvim_create_user_command("CQH", function()
    require("code-query").show_history()
end, {})
