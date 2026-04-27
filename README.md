# cinch.vim

Vim/Neovim plugin for [Cinch](https://cinch.jinmu.me) — remote clipboard for developers.

Yank in Vim → available on any machine running Cinch.

## Requirements

- Vim 8.0+ or Neovim 0.5+
- [cinch CLI](https://cinch.jinmu.me/docs/quick-start) installed and authenticated

## Installation

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
