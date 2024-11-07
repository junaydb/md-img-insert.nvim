**md-img-insert.nvim**: insert images in markdown syntax with ease.

- Fetches markdown images (currently just works with imagekit)
- Image paths are displayed in a floating window at the cursor
- Select an image (or multiple in visual mode) and it gets inserted in markdown syntax
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

## Usage

- Open picker window: `<Leader>mi`
  - Multiple entries can be inserted at once using visual mode.
- Refresh cache: `r`
  - This keymap is local to the picker.
