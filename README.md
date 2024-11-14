![md-img-insert-ss](https://github.com/user-attachments/assets/1a76257f-e629-4036-911e-531b7198d845)

**md-img-insert.nvim**: Quickly insert markdown formatted image links with Neovim.

- Fetches image links from an endpoint (currently just works with ImageKit)
- Image paths are displayed in a floating window at the cursor
- Select an image (or multiple in visual mode) to insert it in markdown syntax
- Fetch results are cached and can be refreshed with `r`

## Install

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'junaydb/md-img-insert.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  ft = 'markdown',
  opts = {},
}
```

## Setup

This plugin currently only works with [ImageKit](https://imagekit.io/).

Set the following environment variables:

- `MD_IMG_INSERT_BASE_URL`: Your ImageKit endpoint's base URL
- `MD_IMG_INSERT_API_KEY`: Your ImageKit private API key

## Usage

- Open picker window: `<Leader>mi`
  - Multiple entries can be inserted at once using visual mode.
- Refresh cache: `r`
  - This keymap is local to the picker.
