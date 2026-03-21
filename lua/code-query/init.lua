local M = {}

M.config = {
    cmd = "claude",
    width = 0.6,
    height = 0.6,
}

function M.setup(opts)
    opts = opts or {}
    M.config = vim.tbl_deep_extend("force", M.config, opts)
end

--- Open a floating scratch buffer and return buf, win
local function open_float()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].filetype = "markdown"
    local width = math.floor(vim.o.columns * M.config.width)
    local height = math.floor(vim.o.lines * M.config.height)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
        style = "minimal",
        border = "rounded",
        title = " Code Query ",
        title_pos = "center",
    })

    vim.wo[win].wrap = true
    vim.wo[win].linebreak = true

    -- q to close
    vim.keymap.set("n", "q", function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end, { buffer = buf, nowait = true })

    return buf, win
end

--- Append text lines to buffer, scrolling to bottom
local function append_to_buf(buf, win, text)
    local lines = vim.split(text, "\n", { plain = true })
    -- Merge with last line (streaming partial lines)
    local last = vim.api.nvim_buf_line_count(buf)
    local last_line = vim.api.nvim_buf_get_lines(buf, last - 1, last, false)[1] or ""
    lines[1] = last_line .. lines[1]
    vim.api.nvim_buf_set_lines(buf, last - 1, last, false, lines)
    -- Scroll to bottom
    if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
    end
end

--- Send a prompt to Claude and stream the response into a float
function M.query(prompt, context)
    if not prompt or prompt == "" then
        vim.notify("code-query: no prompt provided", vim.log.levels.WARN)
        return
    end

    local full_prompt = prompt
    if context and context ~= "" then
        full_prompt = "Here is the relevant code:\n```\n" .. context .. "\n```\n\n" .. prompt
    end

    local buf, win = open_float()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Thinking..." })

    local got_content = false
    local partial_line = ""

    vim.fn.jobstart({ M.config.cmd, "-p", "--verbose", "--output-format", "stream-json", full_prompt }, {
        stdout_buffered = false,
        on_stdout = function(_, data)
            vim.schedule(function()
                if not vim.api.nvim_buf_is_valid(buf) then
                    return
                end
                for _, chunk in ipairs(data) do
                    partial_line = partial_line .. chunk
                    if partial_line == "" then
                        goto continue
                    end
                    local ok, event = pcall(vim.json.decode, partial_line)
                    if not ok then
                        goto continue
                    end
                    partial_line = ""
                    -- assistant messages contain the streamed text
                    if event.type == "assistant" and event.message then
                        local content = event.message.content
                        if content then
                            for _, block in ipairs(content) do
                                if block.type == "text" and block.text and block.text ~= "" then
                                    if not got_content then
                                        got_content = true
                                        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
                                    end
                                    append_to_buf(buf, win, block.text)
                                end
                            end
                        end
                    end
                    ::continue::
                end
            end)
        end,
        stderr_buffered = true,
        on_stderr = function(_, _) end,
        on_exit = function(_, code)
            vim.schedule(function()
                if not vim.api.nvim_buf_is_valid(buf) then
                    return
                end
                if code ~= 0 then
                    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Error: claude exited with code " .. code })
                elseif not got_content then
                    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "No response received." })
                end
            end)
        end,
    })
end

--- Get lines by range from current buffer
local function get_lines(line1, line2)
    local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)
    if #lines == 0 then
        return nil
    end
    return table.concat(lines, "\n")
end

--- Query with visual selection as context
function M.query_visual(prompt, line1, line2)
    local selection = get_lines(line1, line2)
    M.query(prompt, selection)
end

return M
