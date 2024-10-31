local ui = require('md-img-insert.ui')

local M = {}

M.config = {
  base_url_name = 'MD_IMG_INSERT_BASE_URL',
  api_key_name = 'MD_IMG_INSERT_API_KEY',
  cache_path = vim.fn.stdpath('data') .. '/markdown_images_cache.json',
  window = {
    border = 'single',
  },
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  M.config.base_url = os.getenv(M.config.base_url_name)
  M.config.api_key = os.getenv(M.config.api_key_name)

  vim.api.nvim_create_user_command('InsertMarkdownImage', function()
    ui.create_tooltip_window(M.config)
  end, {})

  vim.keymap.set('n', '<Leader>mi', ':InsertMarkdownImage<CR>', { noremap = true, desc = 'Insert [m]arkdown [i]mage' })
end

return M
