vim.opt.compatible = false
vim.opt.encoding = 'utf-8'
vim.opt.filetype = 'on'
vim.opt.signcolumn = 'yes:2'
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 5
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.completeopt = { 'menu', 'menuone', 'preview', 'noselect', 'noinsert' }
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.mouse = ''
vim.opt.pumheight = 10
vim.opt.relativenumber = true
vim.opt.colorcolumn = '80'
vim.opt.textwidth = 80
vim.opt.splitright = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = 'number'
vim.opt.foldenable = true
vim.opt.foldmethod = 'expr'
vim.o.foldcolumn = '1'
vim.o.fillchars = [[eob: ,fold: ,foldopen:▽,foldsep: ,foldclose:▷]]
vim.opt.list = true
vim.opt.listchars = { tab = '<->', nbsp = '␣' }
vim.opt.indentkeys:append('!0<Tab>')
-- Ufo can't recognize zR on startup sadly.
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99

vim.g.mapleader = ' '
vim.g.mkdp_echo_preview_url = 1
vim.g.mkdp_theme = 'dark'
vim.g.mkdp_preview_options = {
  maid = {
    theme = 'dark',
  },
}
vim.g.rustfmt_autosave = 1
vim.g.bullets_outline_levels = { 'ROM', 'ABC', 'rom', 'abc', 'std-' }
vim.g.bullets_checkbox_markers = ' x'
