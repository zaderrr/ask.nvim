# ask.nvim

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
    "zaderrr/ask.nvim",
    config = function()
        require("ask").setup({})
    end,
}
```

## Config

Defaults:

```lua
require("ask").setup({
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
require("ask").setup({
    providers = { claude = { auth = "api-key" } }
})

-- OAuth
require("ask").setup({
    providers = { claude = { auth = "oauth" } }
})
```

### Custom system prompt

By default, no system prompt is provided to codex, and when authenticated with oauth Claude uses:  
`You are a helpful coding assistant. Answer only based on the code provided in the user message.`

Both providers support a custom system prompt:

```lua
-- Claude: works with either auth mode
require("ask").setup({
    providers = {
        claude = {
            system_prompt = "Be concise. Answer in bullet points.",
        }
    }
})

-- Codex: prepended to the user prompt
require("ask").setup({
    provider = "codex",
    providers = {
        codex = {
            system_prompt = "Be concise. Answer in bullet points.",
        }
    }
})
```

**Claude with `api-key` auth:** no system prompt is sent by default (bare mode). Setting one adds `--system-prompt` to the command.

**Claude with `oauth` auth:** a default system prompt is used. Setting one overrides it.
Setting the system prompt to `""` will allow Claude to access outside of selections or use existing context for prompts when using OAuth.

**Codex:** no system prompt by default. When set, it is prepended to the user prompt (Codex CLI has no dedicated system prompt flag).

The spirit of this plugin is to limit the usage to quick questions, but you do you.

### Model selection

By default, both providers use whatever model their CLI is configured with. You can override this per-provider:

```lua
-- Claude: accepts aliases ("sonnet", "opus") or full names ("claude-sonnet-4-6")
require("ask").setup({
    providers = {
        claude = {
            model = "sonnet",
        }
    }
})

-- Codex: accepts model names like "o3", "o4-mini"
require("ask").setup({
    provider = "codex",
    providers = {
        codex = {
            model = "o3",
        }
    }
})
```

### Using codex instead

```lua
require("ask").setup({
    provider = "codex",
})
```

## Usage

```
:ASK How do I write a for loop in lua?
```

Select code in visual mode, then:

```
:'<,'>ASKV What does this function do?
```

Browse previous queries and responses:

```
:ASKH
```

Select an entry with `<CR>` to view the full response. Press `q` to close any window.

