return {
  {
    'navarasu/onedark.nvim',
    keys = { '<leader>fc' },
    config = function()
      require('onedark').setup {
        style = 'warmer',
        highlights = {
          -- make pop up windows blend better with the background
          ['FloatBorder'] = { bg = '$bg0' },
          ['NormalFloat'] = { bg = '$bg0' },
          ['NvimTreeNormal'] = { bg = '$bg0' },
          ['NvimTreeEndOfBuffer'] = { bg = '$bg0', fg = '$bg0' },
          -- prevent Lua constructor tables from being bolded
          ['@constructor.lua'] = { fg = '$yellow', fmt = 'none' },
          ['@function.builtin'] = { fg = '$orange' },
          -- italicize parameters and conditionals
          ['@parameter'] = { fmt = 'italic' },
          ['@conditional'] = { fmt = 'italic' },
          -- make comments stand out
          ['@comment'] = { fg = '$bg_yellow', fmt = 'italic' },
          -- change bracket color so that it doesn't conflict with string color
          ['TSRainbowGreen'] = { fg = '$fg' },
          -- markdown latex highlighting
          ['@text.math'] = { fg = '$blue' },
          -- markdown text modifier highlights
          ['@text.strong.markdown_inline'] = { fg = '$purple', fmt = 'bold' },
          ['@text.emphasis.markdown_inline'] = {
            fg = '$purple',
            fmt = 'italic',
          },
          -- better match paren highlights
          ['MatchParen'] = { fg = '$orange', fmt = 'bold' },
          -- better dashboard styling
          ['@alpha.title'] = { fg = '$green' },
          ['@alpha.header'] = { fg = '$yellow', fmt = 'bold' },
          ['@alpha.footer'] = { fg = '$red', fmt = 'italic' },
        },
        diagnostics = {
          darker = false,
          -- for undercurl on wezterm:
          -- https://wezfurlong.org/wezterm/faq.html?highlight=undercur#how-do-i-enable-undercurl-curly-underlines
        },
      }
    end,
  },
  {
    'ribru17/bamboo.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('bamboo').setup {
        toggle_style_key = '<leader><leader>',
        highlights = {
          ['@alpha.title'] = { fg = '$green' },
          ['@alpha.header'] = { fg = '$yellow', fmt = 'bold' },
          ['@alpha.footer'] = { fg = '$orange', fmt = 'italic' },
        },
        diagnostics = {
          undercurl = false,
        },
      }
      require('bamboo').load()
    end,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    keys = { '<leader>fc' },
    config = function()
      require('catppuccin').setup {
        integrations = {
          indent_blankline = {
            enabled = true,
            colored_indent_levels = true,
          },
        },
        custom_highlights = function(colors)
          return {
            -- make cmp item text matching easier to spot
            ['CmpItemAbbr'] = { ctermbg = 0, fg = colors.text },
            ['CmpItemAbbrMatch'] = { ctermbg = 0, fg = colors.blue },
            ['CmpItemAbbrMatchFuzzy'] = {
              ctermbg = 0,
              fg = colors.blue,
              underline = true,
            },
            -- make popup windows blend with the background better
            ['NormalFloat'] = { ctermbg = 0, bg = colors.base },
            -- better dashboard styling
            ['@alpha.title'] = { fg = colors.green },
            ['@alpha.header'] = { fg = colors.yellow, style = { 'bold' } },
            ['@alpha.footer'] = { fg = colors.peach, style = { 'italic' } },
          }
        end,
      }
    end,
  },
  {
    'folke/tokyonight.nvim',
    keys = { '<leader>fc' },
  },
  {
    'akinsho/bufferline.nvim',
    event = { 'VeryLazy' },
    config = function()
      require('bufferline').setup {
        options = {
          mode = 'tabs',
          separator_style = 'slant',
          color_icons = true,
          show_close_icon = false,
          show_buffer_close_icons = false,
          modified_icon = '●',
          diagnostics = 'nvim_lsp',
          diagnostics_indicator = function(count, level)
            local icon = level:match('error') and '' or ''
            return icon .. ' ' .. count
          end,
        },
      }
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    event = { 'VeryLazy' },
    config = function()
      -- Custom statusline that shows total line number with current
      local function line_total()
        local curs = vim.api.nvim_win_get_cursor(0)
        return curs[1]
          .. '/'
          .. vim.api.nvim_buf_line_count(vim.fn.winbufnr(0))
          .. ','
          .. curs[2]
      end

      require('lualine').setup {
        sections = {
          lualine_z = { line_total },
        },
        options = {
          disabled_filetypes = {
            'alpha',
          },
          section_separators = { left = '', right = '' },
          -- never could decide on any of these
          -- component_separators = { left = '·', right = '·' },
          -- component_separators = { left = '', right = '' },
          -- component_separators = { left = '┊', right = '┊' },
        },
        extensions = {
          'nvim-tree',
        },
      }
    end,
  },
  {
    'kyazdani42/nvim-web-devicons',
    lazy = true,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local CHAR = '🭰'
      require('indent_blankline').setup {
        -- reduce indentation clutter
        -- https://www.reddit.com/r/neovim/comments/yiodnb/proper_configuration_for_indentblankline/
        max_indent_increase = 1,
        char = CHAR, -- comment this out to center align indent indicator
        context_char = CHAR, -- this is only needed if `show_current_context` is set to `true`
        --> Uncomment to get colored indent lines
        -- char_highlight_list = {
        --   'IndentBlanklineIndent1',
        --   'IndentBlanklineIndent2',
        --   'IndentBlanklineIndent3',
        --   'IndentBlanklineIndent4',
        --   'IndentBlanklineIndent5',
        --   'IndentBlanklineIndent6',
        -- },
      }
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('gitsigns').setup {
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- next/prev git changes
          map({ 'n', 'x' }, '<leader>gj', function()
            if vim.wo.diff then
              return ']c'
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return '<Ignore>'
          end, { expr = true })

          map({ 'n', 'x' }, '<leader>gk', function()
            if vim.wo.diff then
              return '[c'
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return '<Ignore>'
          end, { expr = true })

          -- git preview
          map('n', '<leader>gp', gs.preview_hunk)
          -- git blame
          map('n', '<leader>gb', function()
            gs.blame_line { full = true }
          end)
          -- undo git change
          map('n', '<leader>gu', gs.reset_hunk)
          -- undo all git changes
          map('n', '<leader>gr', gs.reset_buffer)
        end,
        sign_priority = 0,
        preview_config = {
          border = 'rounded',
        },
      }
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    keys = {
      { '<leader>ff' },
      { '<leader>fs' },
      { '<leader>fg' },
      { '<leader>fw' },
      { '<leader>fc' },
    },
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    },
    config = function()
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')

      -- open selected buffers in new tabs
      local function multi_tab(prompt_bufnr)
        local picker = action_state.get_current_picker(prompt_bufnr)
        local multi_selection = picker:get_multi_selection()

        if #multi_selection > 1 then
          require('telescope.pickers').on_close_prompt(prompt_bufnr)
          pcall(vim.api.nvim_set_current_win, picker.original_win_id)

          for _, entry in ipairs(multi_selection) do
            local filename, row, col

            if entry.path or entry.filename then
              filename = entry.path or entry.filename

              row = entry.row or entry.lnum
              col = vim.F.if_nil(entry.col, 1)
            elseif not entry.bufnr then
              local value = entry.value
              if not value then
                return
              end

              if type(value) == 'table' then
                value = entry.display
              end

              local sections = vim.split(value, ':')

              filename = sections[1]
              row = tonumber(sections[2])
              col = tonumber(sections[3])
            end

            local entry_bufnr = entry.bufnr

            if entry_bufnr then
              if not vim.api.nvim_buf_get_option(entry_bufnr, 'buflisted') then
                vim.api.nvim_buf_set_option(entry_bufnr, 'buflisted', true)
              end
              pcall(vim.cmd.sbuffer, {
                filename,
                mods = {
                  tab = 1,
                },
              })
            else
              filename = require('plenary.path')
                :new(vim.fn.fnameescape(filename))
                :normalize(vim.loop.cwd())
              pcall(vim.cmd.tabedit, filename)
            end

            if row and col then
              pcall(vim.api.nvim_win_set_cursor, 0, { row, col - 1 })
            end
          end
        else
          actions.select_tab(prompt_bufnr)
        end
      end

      local putils = require('telescope.previewers.utils')
      local telescope = require('telescope')

      telescope.setup {
        defaults = {
          preview = {
            filetype_hook = function(_, bufnr, opts)
              -- don't display jank pdf previews
              if opts.ft == 'pdf' then
                putils.set_preview_message(
                  bufnr,
                  opts.winid,
                  'Not displaying ' .. opts.ft
                )
                return false
              end
              return true
            end,
          },
          layout_config = {
            horizontal = {
              preview_cutoff = 0,
            },
          },
          prompt_prefix = '  ',
          initial_mode = 'normal',
          mappings = {
            n = {
              ['<Tab>'] = multi_tab, -- <Tab> to open as tab
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-j>'] = actions.move_selection_next,
              ['<Space>'] = {
                actions.toggle_selection + actions.move_selection_previous,
                type = 'action',
                opts = { nowait = true, silent = true, noremap = true },
              },
              ['q'] = {
                actions.close,
                type = 'action',
                opts = { nowait = true, silent = true, noremap = true },
              },
              ['<C-l>'] = actions.preview_scrolling_right,
              ['<C-h>'] = actions.preview_scrolling_left,
            },
            i = {
              ['<Tab>'] = multi_tab, -- <Tab> to open as tab
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-j>'] = actions.move_selection_next,
              ['<C-Space>'] = {
                actions.toggle_selection + actions.move_selection_previous,
                type = 'action',
                opts = { nowait = true, silent = true, noremap = true },
              },
              ['<C-l>'] = false, -- override telescope's default
              ['<M-BS>'] = { '<C-s-w>', type = 'command' },
            },
          },
        },
      }

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', function()
        -- ignore opened buffers if not in dashboard or directory
        if
          vim.fn.isdirectory(vim.fn.expand('%')) == 1
          or vim.bo.filetype == 'alpha'
        then
          builtin.find_files()
        else
          local function literalize(str)
            return str:gsub('[%(%)%.%%%+%-%*%?%[%]%^%$]', function(c)
              return '%' .. c
            end)
          end

          local function get_open_buffers()
            local buffers = {}
            local len = 0
            local vim_fn = vim.fn
            local buflisted = vim_fn.buflisted

            for buffer = 1, vim_fn.bufnr('$') do
              if buflisted(buffer) == 1 then
                len = len + 1
                -- get relative name of buffer without leading slash
                buffers[len] = '^'
                  .. literalize(
                    string
                      .gsub(
                        vim.api.nvim_buf_get_name(buffer),
                        literalize(vim.loop.cwd()),
                        ''
                      )
                      :sub(2)
                  )
                  .. '$'
              end
            end

            return buffers
          end

          builtin.find_files {
            file_ignore_patterns = get_open_buffers(),
          }
        end
      end, {})
      vim.keymap.set('n', '<leader>fg', function()
        builtin.grep_string { search = vim.fn.input('Grep > ') }
      end, {})
      vim.keymap.set('n', '<leader>fs', function()
        builtin.live_grep { initial_mode = 'insert' }
      end, {})
      vim.keymap.set('n', '<leader>fw', builtin.git_files, {})
      vim.keymap.set('n', '<leader>fc', function()
        builtin.colorscheme { enable_preview = true }
      end, {})

      telescope.load_extension('fzf')
    end,
  },
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    opts = function()
      local dashboard = require('alpha.themes.dashboard')
      local logo = [[
      ███████████   ████ █████      ██
     ████████████  ████   █████ 
     ████  ███  ████     ████████ ███   ███████████
    ██████████   █████████  ████████ █████ ██████████████
   ████  ███  ████ ███   ███████ █████ █████ ████ █████
 ██████ ███  ████ ████████████ █████ █████ ████ █████
██████ ███████████████ ███n████ █████ █████ ████ ██████
      ]]

      dashboard.section.header.val = vim.split(logo, '\n')
      dashboard.section.header.opts.hl = '@alpha.title'
      dashboard.section.buttons.val = {
        {
          type = 'text',
          val = ' ',
          opts = {
            position = 'center',
          },
        },
        { type = 'padding', val = 2 },
        dashboard.button(
          'f',
          ' ' .. ' Open file',
          ":lua require('telescope.builtin').find_files()<CR>"
        ),
        dashboard.button(
          'r',
          ' ' .. ' Open recent',
          ":lua require('telescope.builtin').oldfiles()<CR>"
        ),
        dashboard.button('t', ' ' .. ' File tree', ':NvimTreeToggle <CR>'),
        dashboard.button(
          's',
          ' ' .. ' Search for text',
          ":lua require('telescope.builtin').live_grep({initial_mode = 'insert'})<CR>"
        ),
        dashboard.button('l', ' ' .. " LSP's", ':Mason<CR>'),
        dashboard.button('p', ' ' .. ' Plugins', ':Lazy<CR>'),
        dashboard.button('q', ' ' .. ' Quit', ':qa<CR>'),
      }
      dashboard.opts.layout[1].val = 4
      dashboard.opts.layout[3].val = 0
      dashboard.section.footer.val =
        'Now I will have less distraction.\n- Leonhard Euler'
      dashboard.section.footer.opts.hl = '@alpha.footer'
      table.insert(dashboard.config.layout, 5, {
        type = 'padding',
        val = 1,
      })
      return dashboard
    end,
    config = function(_, dashboard)
      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == 'lazy' then
        vim.cmd.close()
        vim.api.nvim_create_autocmd('User', {
          pattern = 'AlphaReady',
          callback = function()
            require('lazy').show()
          end,
        })
      end

      require('alpha').setup(dashboard.opts)

      vim.api.nvim_create_autocmd('User', {
        pattern = 'LazyVimStarted',
        callback = function()
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.buttons.val[1].val = '󱐋 Loaded '
            .. stats.count
            .. ' plugins in '
            .. ms
            .. 'ms'
          dashboard.section.buttons.val[1].opts.hl = '@alpha.header'
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
    keys = {
      { '<leader>t', '<Cmd>NvimTreeFindFile<CR>' },
    },
    cmd = { 'NvimTreeFindFileToggle', 'NvimTreeToggle' },
    config = function()
      local HEIGHT_RATIO = 0.75
      local WIDTH_RATIO = 0.5
      local FLOAT_ENABLED = true

      local function on_attach(bufnr)
        local api = require('nvim-tree.api')

        local function opts(desc)
          return {
            desc = 'nvim-tree: ' .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true,
          }
        end

        local map = vim.keymap.set
        -- BEGIN_DEFAULT_ON_ATTACH
        map('n', '<C-]>', api.tree.change_root_to_node, opts('CD'))
        map(
          'n',
          '<C-e>',
          api.node.open.replace_tree_buffer,
          opts('Open: In Place')
        )
        map('n', '<C-k>', api.node.show_info_popup, opts('Info'))
        map('n', '<C-r>', api.fs.rename_sub, opts('Rename: Omit Filename'))
        map('n', '<C-t>', api.node.open.tab, opts('Open: New Tab'))
        map('n', '<C-v>', api.node.open.vertical, opts('Open: Vertical Split'))
        map(
          'n',
          '<C-x>',
          api.node.open.horizontal,
          opts('Open: Horizontal Split')
        )
        map(
          'n',
          '<BS>',
          api.node.navigate.parent_close,
          opts('Close Directory')
        )
        map('n', '<CR>', api.node.open.edit, opts('Open'))
        map('n', '<Tab>', api.node.open.preview, opts('Open Preview'))
        map('n', '>', api.node.navigate.sibling.next, opts('Next Sibling'))
        map('n', '<', api.node.navigate.sibling.prev, opts('Previous Sibling'))
        map('n', '.', api.node.run.cmd, opts('Run Command'))
        map('n', '-', api.tree.change_root_to_parent, opts('Up'))
        map('n', 'a', api.fs.create, opts('Create'))
        map('n', 'bmv', api.marks.bulk.move, opts('Move Bookmarked'))
        map(
          'n',
          'B',
          api.tree.toggle_no_buffer_filter,
          opts('Toggle No Buffer')
        )
        map('n', 'c', api.fs.copy.node, opts('Copy'))
        map(
          'n',
          'C',
          api.tree.toggle_git_clean_filter,
          opts('Toggle Git Clean')
        )
        map('n', '[c', api.node.navigate.git.prev, opts('Prev Git'))
        map('n', ']c', api.node.navigate.git.next, opts('Next Git'))
        map('n', 'd', api.fs.remove, opts('Delete'))
        map('n', 'D', api.fs.trash, opts('Trash'))
        map('n', 'E', api.tree.expand_all, opts('Expand All'))
        map('n', 'e', api.fs.rename_basename, opts('Rename: Basename'))
        map(
          'n',
          ']e',
          api.node.navigate.diagnostics.next,
          opts('Next Diagnostic')
        )
        map(
          'n',
          '[e',
          api.node.navigate.diagnostics.prev,
          opts('Prev Diagnostic')
        )
        map('n', 'F', api.live_filter.clear, opts('Clean Filter'))
        map('n', 'f', api.live_filter.start, opts('Filter'))
        map('n', 'g?', api.tree.toggle_help, opts('Help'))
        map('n', 'gy', api.fs.copy.absolute_path, opts('Copy Absolute Path'))
        map('n', 'H', api.tree.toggle_hidden_filter, opts('Toggle Dotfiles'))
        map(
          'n',
          'I',
          api.tree.toggle_gitignore_filter,
          opts('Toggle Git Ignore')
        )
        map('n', 'J', api.node.navigate.sibling.last, opts('Last Sibling'))
        map('n', 'K', api.node.navigate.sibling.first, opts('First Sibling'))
        map('n', 'm', api.marks.toggle, opts('Toggle Bookmark'))
        map('n', 'o', api.node.open.edit, opts('Open'))
        map(
          'n',
          'O',
          api.node.open.no_window_picker,
          opts('Open: No Window Picker')
        )
        map('n', 'p', api.fs.paste, opts('Paste'))
        map('n', 'P', api.node.navigate.parent, opts('Parent Directory'))
        map('n', 'q', api.tree.close, opts('Close'))
        map('n', 'r', api.fs.rename, opts('Rename'))
        map('n', 'R', api.tree.reload, opts('Refresh'))
        map('n', 's', api.node.run.system, opts('Run System'))
        map('n', 'S', api.tree.search_node, opts('Search'))
        map('n', 'U', api.tree.toggle_custom_filter, opts('Toggle Hidden'))
        map('n', 'W', api.tree.collapse_all, opts('Collapse'))
        map('n', 'x', api.fs.cut, opts('Cut'))
        map('n', 'y', api.fs.copy.filename, opts('Copy Name'))
        map('n', 'Y', api.fs.copy.relative_path, opts('Copy Relative Path'))
        map('n', '<2-LeftMouse>', api.node.open.edit, opts('Open'))
        map('n', '<2-RightMouse>', api.tree.change_root_to_node, opts('CD'))
        -- END_DEFAULT_ON_ATTACH

        local function tab_with_close()
          if not FLOAT_ENABLED then
            vim.api.nvim_command('wincmd h')
          end
          local marks = api.marks.list()
          if #marks == 0 then
            api.node.open.tab()
          else
            for _, node in pairs(api.marks.list()) do
              api.node.open.tab(node)
            end
            api.marks.clear()
          end
        end

        map('n', '.', api.tree.toggle_hidden_filter, opts('Toggle Dotfiles'))
        map('n', 'n', api.fs.create, opts('Create'))
        map('n', 'r', api.fs.rename_sub, opts('Rename: Omit Filename'))
        map('n', 'a', api.tree.change_root_to_node, opts('CD'))
        map('n', '<C-r>', api.tree.reload, opts('Refresh'))
        map('n', '<Tab>', tab_with_close, opts('Open: New Tab'))
        map('n', 'd', api.fs.trash, opts('Trash'))
        map('n', 'D', api.fs.remove, opts('Trash'))
        map('n', '<Esc>', api.tree.close, opts('Close'))
        map('n', 'z', api.node.navigate.parent_close, opts('Close Directory'))
        map('n', '<leader>t', '<C-w>h', opts('Close'))
        map('n', '<Space>', api.marks.toggle, opts('Toggle Bookmark'))
      end

      require('nvim-tree').setup {
        on_attach = on_attach,
        hijack_cursor = true,
        update_focused_file = {
          enable = true,
        },
        view = {
          side = 'right',
          relativenumber = true,
          number = true,
          float = {
            enable = FLOAT_ENABLED,
            open_win_config = function()
              -- center the window
              local screen_w = vim.opt.columns:get()
              local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
              local window_w = screen_w * WIDTH_RATIO
              local window_h = screen_h * HEIGHT_RATIO
              local window_w_int = math.floor(window_w)
              local window_h_int = math.floor(window_h)
              local center_x = (screen_w - window_w) / 2
              local center_y = ((vim.opt.lines:get() - window_h) / 2)
                - vim.opt.cmdheight:get()

              return {
                relative = 'editor',
                border = 'rounded',
                row = center_y,
                col = center_x,
                width = window_w_int,
                height = window_h_int,
              }
            end,
          },
        },
        renderer = {
          -- add a '/' at the end of a folder
          add_trailing = true,
          icons = {
            show = {
              -- remove annoying icons in front of file names
              modified = false,
              git = false,
            },
          },
          -- don't highlight special files, only opened ones
          highlight_opened_files = 'name',
          special_files = {},
        },
        -- synchronize the file tree across tabs (emulate VS Code style)
        -- not really necessary since we are using the float style view but
        -- going to keep it in just in case we want to switch back to the
        -- classic view
        tab = {
          sync = {
            open = true,
            close = true,
          },
        },
      }
    end,
  },
  {
    'Bekaboo/deadcolumn.nvim',
    event = { 'VeryLazy' },
    config = function()
      require('deadcolumn').setup {
        blending = {
          threshold = 0.75,
        },
        warning = {
          alpha = 0.2,
        },
      }
    end,
  },
}
