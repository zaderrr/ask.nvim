# code-query

A Neovim plugin for brief one-line questions to a coding agent.
No file edits, no tool use, no piping your entire root directory as context — just a question and an answer in a floating window.

The addiction of being able to accept a 10,000 line change from an agent got too much.
I realised that they want you to accept the changes, even if not prompted to make changes, and if you have always accept enabled, they will just run wild.

Coding agents are great for helping you understand code or answering quick questions like "How do I read files in python".
This plugin limits interaction to exactly that.

## Requirements

- [Claude CLI](https://github.com/anthropics/claude-code) and/or [Codex CLI](https://github.com/openai/codex)
- Set your API key as an environment variable in your shell profile if needed (OAuth users will not need to):
  ```sh
  # ~/.zshrc or ~/.bashrc
  export ANTHROPIC_API_KEY="sk-..."   # for claude
  export OPENAI_API_KEY="sk-..."      # for codex
  ```

## Install

lazy.nvim:

```lua
{
    "zaderrr/code-query",
    config = function()
        require("code-query").setup({})
    end,
}
```

## Config

Defaults:

```lua
require("code-query").setup({
    provider = "claude",  -- "claude" or "codex"
    width = 0.6,
    height = 0.6,
})
```

If using Claude, you must set `auth`. See [Claude auth](#claude-auth) below.

### Claude auth

You must set `auth` in your setup. The plugin will not run without it.

If you're using an API key (via `ANTHROPIC_API_KEY`), set `auth = "api-key"`. This uses `--bare` mode for the leanest requests.

If you're authenticated via OAuth, set `auth = "oauth"`. This disables `--bare` and adds a default system prompt and `--tools ''` to prevent tool use.
This is because `--bare` is not available to oauth users. So a system prompt is prepended to the prompt. See below for configuring system prompt.

```lua
-- API key
require("code-query").setup({
    providers = { claude = { auth = "api-key" } }
})

-- OAuth
require("code-query").setup({
    providers = { claude = { auth = "oauth" } }
})
```

### Custom system prompt

A system prompt isn't by deafult, provided to codex.
Claude by default will have the following system prompt:  
`You are a helpful coding assistant. Answer only based on the code provided in the user message.`  
Setting the system prompt to `""` will allow claude to access outside of selections or use existing context for prompts when using OAuth.  
The spirit of this plugin is to limit the usage to quick questions, but you do you.  
Api key users can also supply a system prompt, but by default, one is not provided.

```lua
-- Works with either auth mode
require("code-query").setup({
    providers = {
        claude = {
            system_prompt = "Be concise. Answer in bullet points.",
        }
    }
})
```

With `api-key` auth: no system prompt is sent by default (bare mode). Setting one adds `--system-prompt` to the command.

With `oauth` auth: a default system prompt is used. Setting one overrides it.

### Using codex instead

```lua
require("code-query").setup({
    provider = "codex",
})
```

## Usage

```
:CQ How do I write a for loop in lua?
```

Select code in visual mode, then:

```
:'<,'>CQV What does this function do?
```

Press `q` to close the response window.

