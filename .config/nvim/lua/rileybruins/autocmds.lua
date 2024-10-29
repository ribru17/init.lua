local SETTINGS = require('rileybruins.settings')
local create_autocmd = vim.api.nvim_create_autocmd

-- specify different tab widths on certain files
create_autocmd('FileType', {
  pattern = SETTINGS.two_space_indents,
  callback = function()
    local setlocal = vim.opt_local
    setlocal.shiftwidth = 2
    setlocal.softtabstop = 2
  end,
})

-- settings for help files
create_autocmd('BufWinEnter', {
  pattern = '*',
  callback = function(ev)
    if vim.bo[ev.buf].ft ~= 'help' or vim.env.MERGETOOL then
      return
    end
    -- open help buffers in new tabs by default
    vim.cmd.wincmd('T')
  end,
})

---> filetype configuration for miniindentscope
-- bottom whitespace trimming
create_autocmd('FileType', {
  pattern = SETTINGS.mini_indent_scope.ignore_bottom_whitespace,
  callback = function()
    vim.b.miniindentscope_config = {
      options = {
        border = 'top',
      },
    }
  end,
})
-- disabling
create_autocmd('FileType', {
  pattern = SETTINGS.mini_indent_scope.disabled,
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
})

-->> "RUN ONCE" ON FILE OPEN COMMANDS <<--
-- prevent comment from being inserted when entering new line in existing comment
create_autocmd('BufWinEnter', {
  callback = function()
    vim.opt_local.formatoptions:remove { 'r', 'o' }
  end,
})

local function populate_spellfile()
  local spell_files =
    vim.fn.glob(vim.fn.stdpath('config') .. '/spell/*.add', true, true)

  for _, add_file in ipairs(spell_files) do
    local spl_file = add_file .. '.spl'
    if
      vim.fn.filereadable(add_file)
      and (
        not vim.fn.filereadable(spl_file)
        or vim.fn.getftime(add_file) > vim.fn.getftime(spl_file)
      )
    then
      vim.cmd.mkspell {
        vim.fn.fnameescape(add_file),
        bang = true,
        mods = { silent = true },
      }
    end
  end
end

-- lazy load keymaps and user-defined commands
create_autocmd('User', {
  pattern = 'VeryLazy',
  once = true,
  callback = function()
    require('rileybruins.bindings')
    populate_spellfile()
  end,
})

-- load EZ-Semicolon upon entering insert mode
create_autocmd('InsertEnter', {
  pattern = '*',
  once = true,
  callback = function()
    require('rileybruins.ezsemicolon')
  end,
})

-- handle dashboard animation starting and stopping
create_autocmd({ 'FileType', 'BufEnter' }, {
  pattern = '*',
  callback = function()
    local ft = vim.bo.filetype
    if ft == 'alpha' then
      require('rileybruins.utils').color_fade_start()
    else
      require('rileybruins.utils').color_fade_stop()
    end
  end,
})

-- prevent weird snippet jumping behavior
-- https://github.com/L3MON4D3/LuaSnip/issues/258
create_autocmd('ModeChanged', {
  pattern = { 's:n', 'i:*' },
  callback = function()
    local ls = require('luasnip')
    if
      ls.session.current_nodes[vim.api.nvim_get_current_buf()]
      and not ls.session.jump_active
    then
      ls.unlink_current()
    end
  end,
})

-- update foldcolumn ribbon colors
create_autocmd('ColorScheme', {
  callback = function()
    local util = require('rileybruins.utils')
    for i = 1, 8, 1 do
      vim.api.nvim_set_hl(0, 'FoldCol' .. i, {
        bg = util.blend(
          string.format(
            '#%06x',
            vim.api.nvim_get_hl(0, { name = 'Normal' }).fg or 0
          ),
          string.format(
            '#%06x',
            vim.api.nvim_get_hl(0, { name = 'Normal' }).bg or 0
          ),
          0.125 * i
        ),
        fg = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg or 0,
      })
    end
  end,
})

-- nicer cmp docs highlights for Nvim 0.10
create_autocmd('FileType', {
  pattern = 'cmp_docs',
  callback = function(ev)
    vim.treesitter.start(ev.buf, 'markdown')
  end,
})

-- hide foldcolumn for certain filetypes
create_autocmd('FileType', {
  pattern = SETTINGS.hide_foldcolumn,
  callback = function()
    vim.opt_local.foldcolumn = '0'
  end,
})

-- cool yank highlighting
create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank { higroup = 'Search' }
  end,
})

-- javascript-family files nvim-surround setup
create_autocmd('FileType', {
  pattern = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
  callback = function()
    local config = require('nvim-surround.config')
    ---@diagnostic disable-next-line: missing-fields
    require('nvim-surround').buffer_setup {
      surrounds = {
        ---@diagnostic disable-next-line: missing-fields
        F = {
          add = function()
            local result = require('nvim-surround.config').get_input(
              'Enter the function name: '
            )
            if result then
              if result == '' then
                return {
                  { '() => {' },
                  { '}' },
                }
              else
                return {
                  { 'function ' .. result .. '() {' },
                  { '}' },
                }
              end
            end
          end,
          find = function()
            return require('nvim-surround.config').get_selection {
              query = { capture = '@function.outer', type = 'textobjects' },
            }
          end,
          ---@param char string
          delete = function(char)
            local match = config.get_selections {
              char = char,
              --> INJECT: luap
              pattern = '^(function%s+[%w_]-%s-%(.-%).-{)().-(})()$',
            }
            if not match then
              match = config.get_selections {
                char = char,
                --> INJECT: luap
                pattern = '^(%(.-%)%s-=>%s-{)().-(})()$',
              }
            end
            return match
          end,
        },
      },
    }
  end,
})

-- automatically regenerate spell file after editing dictionary
create_autocmd('BufWritePost', {
  pattern = '*/spell/*.add',
  callback = function()
    vim.cmd.mkspell { '%', bang = true, mods = { silent = true } }
  end,
})

-- sane terminal options
create_autocmd('TermOpen', {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
    vim.opt_local.foldcolumn = '0'
    vim.b.miniindentscope_disable = true
  end,
})

-- allow regular CR function in cmdline windows
create_autocmd('CmdwinEnter', {
  callback = function(ev)
    vim.keymap.set('n', '<CR>', '<CR>', { remap = false, buffer = ev.buf })
  end,
})

-- -- NOTE: Keep disabled when using transparent terminal background.
-- remove terminal padding around Neovim instance
-- create_autocmd({ 'UIEnter', 'ColorScheme' }, {
--   callback = function()
--     local normal = vim.api.nvim_get_hl(0, { name = 'Normal' })
--     if not normal.bg then
--       return
--     end
--     io.write(string.format('\027]11;#%06x\027\\', normal.bg))
--   end,
-- })
-- create_autocmd('UILeave', {
--   callback = function()
--     io.write('\027]111\027\\')
--   end,
-- })

-- only set the foldexpr where necessary
-- also enable syntax if there is no treesitter highlighting
create_autocmd('FileType', {
  callback = function(ev)
    local ft = vim.bo[ev.buf].ft
    local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].ft) --[[@as string]]
    if vim.treesitter.get_parser(ev.buf, ft, { error = false }) then
      if vim.treesitter.query.get(lang, 'folds') then
        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      end
    else
      vim.bo[ev.buf].syntax = 'ON'
    end
  end,
})

-- enable syntax highlighting for filetypes with treesitter highlights disabled
create_autocmd('FileType', {
  pattern = SETTINGS.disabled_highlighting_fts,
  callback = function(ev)
    vim.bo[ev.buf].syntax = 'ON'
  end,
})

create_autocmd('FileType', {
  pattern = 'query',
  callback = function(ev)
    if vim.bo[ev.buf].buftype == 'nofile' then
      return
    end
    vim.lsp.start {
      name = 'ts_query_ls',
      cmd = {
        vim.fs.joinpath(
          vim.env.HOME,
          'Documents/CodeProjects/ts_query_ls/target/release/ts_query_ls'
        ),
      },
      root_dir = vim.fs.root(0, { 'queries' }),
      settings = {
        parser_install_directories = {
          -- If using nvim-treesitter with lazy.nvim
          vim.fs.joinpath(
            vim.fn.stdpath('data') --[[@as string]],
            '/lazy/nvim-treesitter/parser/'
          ),
        },
        parser_aliases = {
          ecma = 'javascript',
          jsx = 'javascript',
          php_only = 'php',
        },
        language_retrieval_patterns = {
          'languages/src/([^/]+)/[^/]+\\.scm$',
        },
      },
    }
  end,
})

create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.wo.conceallevel = 2
    vim.wo.concealcursor = 'nc'
    -- Allow block comments to be continued when hitting enter.
    vim.opt.formatoptions:append('qcro')
    vim.b.matchup_matchparen_enabled = false

    -- Allow bullets.vim and nvim-autopairs to coexist.
    vim.schedule(function()
      vim.keymap.set('i', '<CR>', function()
        local pair = require('nvim-autopairs').completion_confirm()
        if
          vim.bo.ft == 'markdown'
          and pair
            == vim.api.nvim_replace_termcodes('<CR>', true, false, true)
        then
          vim.cmd.InsertNewBullet()
        else
          vim.api.nvim_feedkeys(pair, 'n', false)
        end
      end, {
        buffer = 0,
      })
    end)

    local config = require('nvim-surround.config')
    local in_latex_zone = require('rileybruins.utils').in_latex_zone
    ---@diagnostic disable-next-line: missing-fields
    require('nvim-surround').buffer_setup {
      aliases = {
        ['b'] = { '{', '[', '(', '<', 'b' },
      },
      surrounds = {
        ---@diagnostic disable-next-line: missing-fields
        ['b'] = {
          add = { '**', '**' },
          --> INJECT: luap
          find = '%*%*.-%*%*',
          --> INJECT: luap
          delete = '^(%*%*)().-(%*%*)()$',
        },
        -- recognize latex-style functions when in latex snippets
        ['f'] = {
          add = function()
            local result = config.get_input('Enter the function name: ')
            if result then
              if in_latex_zone() then
                return { { '\\' .. result .. '{' }, { '}' } }
              end
              return { { result .. '(' }, { ')' } }
            end
          end,
          find = function()
            if in_latex_zone() then
              return config.get_selection {
                --> INJECT: luap
                pattern = '\\[%w_]+{.-}',
              }
            end
            if vim.g.loaded_nvim_treesitter then
              local selection = config.get_selection {
                query = { capture = '@call.outer', type = 'textobjects' },
              }
              if selection then
                return selection
              end
            end
            return config.get_selection {
              --> INJECT: luap
              pattern = '[^=%s%(%){}]+%b()',
            }
          end,
          ---@param char string
          delete = function(char)
            local match
            if in_latex_zone() then
              match = config.get_selections {
                char = char,
                --> INJECT: luap
                pattern = '^(\\[%w_]+{)().-(})()$',
              }
            else
              match = config.get_selections {
                char = char,
                --> INJECT: luap
                pattern = '^(.-%()().-(%))()$',
              }
            end
            return match
          end,
          change = {
            ---@param char string
            target = function(char)
              if in_latex_zone() then
                return config.get_selections {
                  char = char,
                  --> INJECT: luap
                  pattern = '^.-\\([%w_]+)(){.-}()()$',
                }
              else
                return config.get_selections {
                  char = char,
                  --> INJECT: luap
                  pattern = '^.-([%w_]+)()%(.-%)()()$',
                }
              end
            end,
            replacement = function()
              local result = config.get_input('Enter the function name: ')
              if result then
                return { { result }, { '' } }
              end
            end,
          },
        },
      },
    }
  end,
})
