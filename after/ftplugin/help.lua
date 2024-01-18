-- open help buffers in new tabs by default
vim.cmd.wincmd('T')
-- get highlighted code examples
vim.treesitter.start()
-- easier navigation
vim.opt_local.relativenumber = true
-- better mnemonic for tag jumping
vim.keymap.set('n', 'gd', '<C-]>', {
  buffer = true,
})
