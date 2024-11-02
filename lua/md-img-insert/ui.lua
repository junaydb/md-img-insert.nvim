local imgf = require('md-img-insert.imagefetcher')

local M = {}

function M.create_tooltip_window(config)
  local images = {}
  local locked_and_loading = true
  local fetch_job = nil
  local original_win = vim.api.nvim_get_current_win()
  local tooltip_buf = vim.api.nvim_create_buf(false, true)
  local tooltip_win = vim.api.nvim_open_win(tooltip_buf, true, {
    style = 'minimal',
    relative = 'cursor',
    width = 1,
    height = 1,
    row = 0,
    col = 1,
    border = config.window.border,
    title = ' Markdown Image Insert ',
  })
  vim.api.nvim_set_option_value('cursorline', true, { win = tooltip_win })

  local function insert_at_cursor()
    if locked_and_loading then
      return
    end

    local selected = vim.api.nvim_win_get_cursor(tooltip_win)[1]
    if images[selected] then
      local img = images[selected]

      local markdown = string.format('![%s](%s)', img.name:gsub('%.%w+$', ''), img.url)

      vim.api.nvim_win_close(tooltip_win, true)
      vim.api.nvim_set_current_win(original_win)
      vim.api.nvim_set_current_line(markdown)
    end
  end

  local function insert_multiple_at_cursor()
    vim.api.nvim_set_option_value('modifiable', true, { buf = tooltip_buf })

    if locked_and_loading then
      return
    end

    -- Getting lines in visual mode isn't at straightforward
    local _, start_line, _ = unpack(vim.fn.getpos('v'))
    local _, end_line, _ = unpack(vim.fn.getpos('.'))

    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end

    local lines = {}
    for i = start_line, end_line do
      local img = images[i]
      table.insert(lines, string.format('![%s](%s)', img.name:gsub('%.%w+$', ''), img.url))
    end

    vim.api.nvim_win_close(tooltip_win, true)
    vim.api.nvim_set_current_win(original_win)
    vim.api.nvim_paste(table.concat(lines, '\n'), true, -1)
  end

  local function set_buffer_lines_and_fit(lines)
    local max_width = 0
    for _, line in ipairs(lines) do
      max_width = math.max(max_width, #line)
    end

    vim.api.nvim_set_option_value('modifiable', true, { buf = tooltip_buf })
    vim.api.nvim_buf_set_lines(tooltip_buf, 0, -1, false, lines)
    vim.api.nvim_win_set_width(tooltip_win, max_width)
    vim.api.nvim_win_set_height(tooltip_win, math.min(#lines, 20))
    vim.api.nvim_set_option_value('modifiable', false, { buf = tooltip_buf })
  end

  local function show_loading()
    local lines = { 'Fetching, please wait...' }
    vim.api.nvim_set_option_value('modifiable', true, { buf = tooltip_buf })
    set_buffer_lines_and_fit(lines)
    vim.api.nvim_set_option_value('modifiable', false, { buf = tooltip_buf })
  end

  local function show_image_list()
    vim.api.nvim_set_option_value('modifiable', true, { buf = tooltip_buf })

    local max_width_name = 0
    for _, img in ipairs(images) do
      max_width_name = math.max(max_width_name, #img.name)
    end

    local max_width_markdown = 0
    local lines = {}
    for _, img in ipairs(images) do
      local path_offset = max_width_name - #img.name + 5

      local element = string.format('- %s%s(%s%s)', img.name, string.rep(' ', path_offset), config.base_url, img.filePath)

      table.insert(lines, element)
      max_width_markdown = math.max(max_width_markdown, #element)
    end

    vim.api.nvim_buf_set_lines(tooltip_buf, 0, -1, false, lines)
    vim.api.nvim_win_set_width(tooltip_win, max_width_markdown)
    vim.api.nvim_win_set_height(tooltip_win, math.min(#lines, 20))
    vim.api.nvim_set_option_value('modifiable', false, { buf = tooltip_buf })
  end

  local function success_cb(result)
    images = result
    locked_and_loading = false
    show_image_list()
  end

  local function error_cb(lines)
    set_buffer_lines_and_fit(lines)
  end

  local function close()
    if fetch_job then
      fetch_job:shutdown(0, 2)
      fetch_job = nil
      print('Fetch was cancelled (SIGINT)')
    end

    vim.api.nvim_win_close(tooltip_win, true)
  end

  local function set_job(job)
    fetch_job = job
  end

  local km_opts = { noremap = true, silent = true, buffer = tooltip_buf }
  vim.keymap.set('n', 'q', close, km_opts)
  vim.keymap.set('n', '<Esc>', close, km_opts)
  vim.keymap.set('n', '<CR>', insert_at_cursor, km_opts)
  vim.keymap.set('v', '<CR>', insert_multiple_at_cursor, km_opts)
  vim.keymap.set('n', 'r', function()
    locked_and_loading = true
    show_loading()
    images = imgf.fetch(false, config, success_cb, error_cb, set_job)
  end, km_opts)

  vim.api.nvim_create_autocmd('WinLeave', {
    buffer = tooltip_buf,
    callback = function()
      vim.api.nvim_win_close(tooltip_win, true)
    end,
    once = true,
  })

  show_loading()
  images = imgf.fetch(true, config, success_cb, error_cb, set_job)
end

return M
