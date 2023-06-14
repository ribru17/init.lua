-- specify different tab widths on certain files
vim.api.nvim_create_augroup('setIndent', { clear = true })
vim.api.nvim_create_autocmd('Filetype', {
  group = 'setIndent',
  pattern = { 'xml', 'html', 'xhtml', 'css', 'scss', 'javascript', 'typescript',
    'yaml', 'javascriptreact', 'typescriptreact', 'markdown', 'lua',
  },
  command = 'setlocal shiftwidth=2 tabstop=2 softtabstop=2',
})

-- where applicable, reset cursor to blinking I-beam after closing Neovim
-- https://github.com/neovim/neovim/issues/4867
vim.api.nvim_create_augroup('resetCursor', { clear = true })
vim.api.nvim_create_autocmd('VimLeave', {
  group = 'resetCursor',
  pattern = '*',
  command = 'set guicursor=a:ver10-blinkon1',
})

-- prevent comment from being inserted when entering new line in existing comment
vim.api.nvim_create_autocmd('BufEnter',
  {
    callback = function()
      vim.opt.formatoptions = vim.opt.formatoptions -
          { 'c', 'r', 'o' }
    end,
  })

local lsp_formatting = function()
  vim.lsp.buf.format {
    filter = function(client)
      -- disable formatters that are already covered by null-ls to prevent conflicts
      local disabled_formatters = { 'clangd', 'tsserver', 'html' }

      for k = 1, #disabled_formatters do
        local v = disabled_formatters[k]
        if client.name == v then
          return false
        end
      end

      return true
    end,
  }
end

-- Explicitly format on save: passing this through null-ls failed with
-- unsupported formatters, e.g. html-lsp
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function()
    lsp_formatting()
  end,
})

-- lazy load keymaps and user-defined commands
vim.api.nvim_create_autocmd('User', {
  group = vim.api.nvim_create_augroup('LoadBinds', { clear = true }),
  pattern = 'VeryLazy',
  callback = function()
    require('bindings')
  end,
})

-- load EZ-Semicolon upon entering insert mode
vim.api.nvim_create_autocmd('InsertEnter', {
  group = vim.api.nvim_create_augroup('LoadEZSemicolon', { clear = true }),
  callback = function()
    require('ezsemicolon')
    vim.api.nvim_clear_autocmds { group = 'LoadEZSemicolon' }
  end,
})

-- open dashboard when in a directory
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    if vim.fn.isdirectory(vim.fn.expand('%')) == 1 then
      require('alpha')
      vim.cmd.Alpha()
    end
  end,
})

-- prevent weird snippet jumping behavior
-- https://github.com/L3MON4D3/LuaSnip/issues/258
vim.api.nvim_create_autocmd('ModeChanged', {
  pattern = '*',
  callback = function()
    if ((vim.v.event.old_mode == 's' and vim.v.event.new_mode == 'n') or vim.v.event.old_mode == 'i')
        and require('luasnip').session.current_nodes[vim.api.nvim_get_current_buf()]
        and not require('luasnip').session.jump_active
    then
      require('luasnip').unlink_current()
    end
  end,
})

-- delete buffers that are hidden/remain opened when closing a tab
-- allows file tree and fuzzy finder to have updated/correct information
-- on which buffers are still in use
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*',
  callback = function()
    vim.opt_local.bufhidden = 'delete'
  end,
})

-- close nvim tree if last buffer if tab/window
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('NvimTreeClose', { clear = true }),
  pattern = 'NvimTree_*',
  callback = function()
    local layout = vim.api.nvim_call_function('winlayout', {})
    if layout[1] == 'leaf' and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), 'filetype') == 'NvimTree' and layout[3] == nil then
      vim.cmd('confirm quit')
    end
  end,
})

-- TODO: make it so that this autocmd only runs when an alpha window is loaded
-- -- super cool and awesome dashboard title fade
-- vim.api.nvim_create_autocmd('ColorScheme', {
--   group = vim.api.nvim_create_augroup('AlphaFade', { clear = true }),
--   callback = function()
--     require('utils').color_fade()
--     -- this causes the autocmd to only run once
--     vim.api.nvim_clear_autocmds { group = 'AlphaFade' }
--   end,
-- })

-- -- clean up super cool and awesome dashboard title fade
-- -- NOTE: I don't actually know if this is necessary, I think closing is only
-- -- needed for timers that will only be used sometimes (this timer is used
-- -- globally, always) but better safe than sorry
-- vim.api.nvim_create_autocmd('VimLeave', {
--   pattern = '*',
--   callback = function()
--     require('utils').color_fade_stop()
--   end,
-- })
