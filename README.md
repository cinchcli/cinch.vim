# cinch.vim

Vim/Neovim plugin for [Cinch](https://cinchcli.com) — Your clipboard. Across every machine.

Yank in Vim → available on every machine running Cinch.

## Requirements

- Vim 8.0+ or Neovim 0.5+
- `cinch` CLI installed and authenticated (see below)

## Install the `cinch` CLI

```sh
brew install cinchcli/tap/cinch    # macOS (Apple Silicon) / Linux (ARM)
cargo install cinch-cli            # any platform with a Rust toolchain
```

Other platforms: prebuilt binaries on the [releases page](https://github.com/cinchcli/cinch/releases). After install, run `cinch auth login` once. Full guide: [cinchcli.com/docs/quick-start](https://cinchcli.com/docs/quick-start/).

## Install the plugin

**Vim 8 / Neovim native packages**

Vim:
```sh
git clone https://github.com/cinchcli/cinch.vim \
  ~/.vim/pack/cinch/start/cinch.vim
vim -u NONE -c "helptags ~/.vim/pack/cinch/start/cinch.vim/doc" -c q
```

Neovim:
```sh
git clone https://github.com/cinchcli/cinch.vim \
  ~/.local/share/nvim/site/pack/cinch/start/cinch.vim
nvim -u NONE -c "helptags ~/.local/share/nvim/site/pack/cinch/start/cinch.vim/doc" -c q
```

**lazy.nvim**
```lua
{ "cinchcli/cinch.vim" }
```

**vim-plug**
```vim
Plug 'cinchcli/cinch.vim'
```

## Usage

You don't have to learn new keys. Any normal yank pushes automatically:

| Action | Result |
|--------|--------|
| `yy`, `yw`, `yiw`, `y$` … | Auto-push yanked text to the relay |
| `:CinchPull` | Pull latest clip from the relay into the `"` register |
| `:CinchPullFrom {device}` | Pull latest clip from a specific device (tab-completes) |
| `:CinchPush` | Manually push the `"` register to the relay |
| `:CinchToggle` | Toggle auto-push on/off for this session |
| `:CinchHistory[!]` | Browse and paste from history (`!` fetches 200 instead of 50) |
| `:CinchStatus` | Show auth, last push/pull, and auto-push state |

Want explicit "push this, don't push that" control instead of auto-push? See
[Opt-in `yc` mappings](#opt-in-yc-mappings) below.

## Configuration

All options are plain Vim globals — set them before the plugin loads in any plugin manager.

| Variable | Default | Purpose |
|---|---|---|
| `g:cinch_auto_push` | `1` | Push automatically on yank |
| `g:cinch_push_register` | `'"'` | Register that triggers auto-push |
| `g:cinch_binary` | `'cinch'` | Path to the CLI |
| `g:cinch_default_source` | `''` | If set, plain `:CinchPull` pulls `--from <src>` |
| `g:cinch_pull_exclude_self` | `0` | If `1`, plain `:CinchPull` adds `--exclude-self` |
| `g:cinch_default_mappings` | `0` | Set to `1` to install the `yc`/`ycc`/`yC` mappings (off by default — auto-push covers most cases) |
| `g:cinch_picker` | `'auto'` | `auto` \| `snacks` \| `fzf-lua` \| `telescope` \| `builtin` |
| `g:cinch_verbose` | `0` | `0` silent, `1` echo, `2` debug |

### lazy.nvim

```lua
{
  "cinchcli/cinch.vim",
  init = function()
    -- Optional: turn off auto-push and use the system clipboard register instead.
    -- vim.g.cinch_auto_push = 0
    -- vim.g.cinch_push_register = "+"
  end,
  cmd = { "CinchPush", "CinchPull", "CinchPullFrom", "CinchToggle", "CinchHistory", "CinchStatus" },
  keys = {
    { "<leader>cp", "<cmd>CinchPull<cr>",    desc = "Cinch pull" },
    { "<leader>cP", "<cmd>CinchPush<cr>",    desc = "Cinch push" },
    { "<leader>ct", "<cmd>CinchToggle<cr>",  desc = "Cinch toggle auto-push" },
    { "<leader>ch", "<cmd>CinchHistory<cr>", desc = "Cinch history" },
  },
}
```

### vim-plug

```vim
Plug 'cinchcli/cinch.vim'

" Optional: turn off auto-push and use the system clipboard register instead.
" let g:cinch_auto_push = 0
" let g:cinch_push_register = '+'

nnoremap <leader>cp <cmd>CinchPull<cr>
nnoremap <leader>cP <cmd>CinchPush<cr>
nnoremap <leader>ct <cmd>CinchToggle<cr>
nnoremap <leader>ch <cmd>CinchHistory<cr>
```

## Opt-in `yc` mappings

By default, cinch.vim does **not** install any new normal-mode keys — your
existing yank muscle memory (`yy`, `yw`, `yiw`, …) is enough, because auto-push
sends every yank to the relay.

If you'd rather push *explicitly* (one keystroke = one push, instead of every
yank silently going over the wire), opt in to the `yc` operator family:

```vim
let g:cinch_default_mappings = 1    " enables: yc{motion}, ycc, yC, visual yc
```

This pairs naturally with `let g:cinch_auto_push = 0` — yanks stay local, and
only `yc`-prefixed yanks push to the relay.

You can also bind individual actions to any key you like via `<Plug>` maps —
see `:help cinch-mappings` for the full list.

See `:help cinch` for the full list of commands, `<Plug>` mappings, and the Lua API.

## Beyond Vim

cinch.vim covers the editor-side workflow (push, pull, history). For everything
else — authentication, pairing new machines, pinning clips, full-text search,
device management, retention — use the `cinch` CLI directly:

```bash
cinch auth login | logout | status
cinch pair user@remotehost
cinch search "<query>"          # full-text search across all clips
cinch pin <clip-id> | unpin <clip-id> | pinned
cinch devices | nickname | revoke
```

Run `cinch --help` or see the [CLI docs](https://cinchcli.com/docs/cli/) for the
full surface.

> **Note on history search:** `:CinchHistory` loads the **last 50 clips**
> (or 200 with `:CinchHistory!`) and lets your picker fuzzy-filter that window.
> It does **not** call `cinch search`, so older clips won't appear. For
> full-history search, shell out to `:!cinch search "<query>"`.

## License

MIT
