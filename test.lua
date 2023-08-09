function lualine_tab_swap()
  local buffers_component = require('lualine.components.buffers')

  function get_buffer_index(bufnr)
    for i, v in ipairs(buffers_component.bufpos2nr) do
      if v == bufnr then
        return i
      end
    end
    return nil
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local buf_index = get_buffer_index(bufnr)

  print(buf_index)
  print(vim.inspect(buffers_component.bufpos2nr))

  return {
    next = function()
      if buf_index < #buffers_component.bufpos2nr then
        local n = buffers_component.bufpos2nr[buf_index]
        print(n)
        buffers_component.bufpos2nr[buf_index] = buffers_component.bufpos2nr[buf_index + 1]
        buffers_component.bufpos2nr[buf_index + 1] = n
        print(vim.inspect(buffers_component.bufpos2nr))
      end
    end,
    prev = function()
      if buf_index > 1 then
        local n = buffers_component.bufpos2nr[buf_index]
        print(n)
        buffers_component.bufpos2nr[buf_index] = buffers_component.bufpos2nr[buf_index - 1]
        buffers_component.bufpos2nr[buf_index - 1] = n
        print(vim.inspect(buffers_component.bufpos2nr))
      end
    end,
  }
end
