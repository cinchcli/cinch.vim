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

| Action | Result |
|--------|--------|
| `yy`, `yw`, `y$` … | Auto-push yanked text to relay |
| `:CinchPull` | Pull latest clip from relay into `"` register |
| `:CinchPush` | Manually push `"` register to relay |
| `:CinchToggle` | Toggle auto-push on/off |

## Configuration

```vim
" Disable auto-push on yank (default: 1)
let g:cinch_auto_push = 0

" Register to watch (default: unnamed '"')
let g:cinch_push_register = '+'

" Custom binary path (default: 'cinch')
let g:cinch_binary = '/usr/local/bin/cinch'
```

## License

MIT
