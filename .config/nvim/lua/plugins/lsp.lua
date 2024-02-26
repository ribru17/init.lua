local BORDER_STYLE = require('rileybruins.settings').border
local SETTINGS = require('rileybruins.settings')

local diagnostic_ns = vim.api.nvim_create_namespace('hlyank')
local diagnostic_timer
local hl_cancel

local function goto_diagnostic_hl(dir)
  assert(dir == 'prev' or dir == 'next')
  local pos = vim.diagnostic['get_' .. dir]()
  if not pos then
    return
  end
  if diagnostic_timer then
    diagnostic_timer:close()
    hl_cancel()
  end
  vim.api.nvim_buf_set_extmark(0, diagnostic_ns, pos.lnum, pos.col, {
    end_row = pos.end_lnum,
    end_col = pos.end_col,
    hl_group = 'Visual',
  })
  hl_cancel = function()
    diagnostic_timer = nil
    hl_cancel = nil
    pcall(vim.api.nvim_buf_clear_namespace, 0, diagnostic_ns, 0, -1)
  end
  diagnostic_timer = vim.defer_fn(hl_cancel, 500)
  vim.diagnostic['goto_' .. dir]()
end

return {
  {
    'p00f/clangd_extensions.nvim',
    lazy = true,
  },
  {
    'williamboman/mason.nvim',
    cmd = { 'Mason' },
    opts = {
      registries = {
        'lua:mason.registry',
        'github:mason-org/mason-registry',
      },
      ui = {
        border = BORDER_STYLE,
      },
    },
  },
  {
    'williamboman/mason-lspconfig.nvim',
    lazy = true,
  },
  {
    'mrcjkb/haskell-tools.nvim',
    ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
    version = '^3',
  },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('mason').setup()
      local SETTINGS = require('rileybruins.settings')
      require('mason-lspconfig').setup {
        ensure_installed = SETTINGS.ensure_installed_lsps,
      }

      require('lspconfig.ui.windows').default_options.border = BORDER_STYLE

      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      require('mason-lspconfig').setup_handlers {
        -- The first entry (without a key) will be the default handler
        -- and will be called for each installed server that doesn't have
        -- a dedicated handler.
        function(server_name) -- default handler (optional)
          require('lspconfig')[server_name].setup {
            capabilities = capabilities,
          }
        end,
        ['clangd'] = function()
          local custom_capabilities =
            require('cmp_nvim_lsp').default_capabilities()
          custom_capabilities.offsetEncoding = { 'utf-16' }
          require('lspconfig').clangd.setup {
            on_attach = function()
              require('clangd_extensions.inlay_hints').setup_autocmd()
              require('clangd_extensions.inlay_hints').set_inlay_hints()
            end,
            capabilities = custom_capabilities,
            -- NOTE: to achieve LSP warnings on unused includes, add a `.clangd`
            -- file to the project directory containing:
            -- ```
            -- Diagnostics:
            -- UnusedIncludes: Strict
            -- MissingIncludes: Strict
            -- ```
            cmd = {
              'clangd',
              '--header-insertion-decorators=false',
              '--enable-config',
              '--completion-style=detailed',
              '--background-index',
              '--clang-tidy',
              '--include-cleaner-stdlib',
              '--header-insertion=iwyu',
              '--completion-style=detailed',
              '--function-arg-placeholders',
              '--fallback-style=llvm',
            },
            init_options = {
              usePlaceholders = true,
              completeUnimported = true,
              clangdFileStatus = true,
            },
          }
        end,
        ['denols'] = function()
          -- don't set up LSP, we only want formatting
        end,
        ['emmet_language_server'] = function()
          local emmet_fts =
            require('lspconfig').emmet_language_server.document_config.default_config.filetypes
          -- These are the default filetypes less the ones that are covered by
          -- `cssls`. The two (sort of) conflict, and `cssls` is better. I
          -- don't use Emmet CSS abbreviations anyway.
          local ignored_fts =
            require('lspconfig').cssls.document_config.default_config.filetypes
          local filtered_fts = vim.tbl_filter(function(value)
            return not vim.tbl_contains(ignored_fts, value)
          end, emmet_fts)
          require('lspconfig').emmet_language_server.setup {
            filetypes = filtered_fts,
            init_options = {
              preferences = {
                ['caniuse.enabled'] = false,
              },
            },
          }
        end,
        ['eslint'] = function()
          require('lspconfig').eslint.setup {
            capabilities = capabilities,
            on_attach = function(_, bufnr)
              vim.api.nvim_create_autocmd('BufWritePre', {
                buffer = bufnr,
                command = 'EslintFixAll',
              })
            end,
          }
        end,
        ['gopls'] = function()
          require('lspconfig').gopls.setup {
            capabilities = capabilities,
            settings = {
              gopls = {
                semanticTokens = true,
                analyses = {
                  unusedparams = true,
                },
                staticcheck = true,
              },
            },
          }
        end,
        ['hls'] = function()
          -- do nothing in case user installed lsp with Mason
          -- this prevents conflicts with the haskell tools plugin
        end,
        ['lua_ls'] = function()
          local library = {}

          local function add(lib)
            for _, p in pairs(vim.fn.expand(lib .. '/lua', false, true)) do
              p = vim.loop.fs_realpath(p)
              if p then
                library[p] = true
              end
            end
          end

          -- add runtime
          add('$VIMRUNTIME')

          -- add config
          add('~/.config/nvim')

          if SETTINGS.luals_load_plugins then
            -- add plugins
            if package.loaded['lazy'] then
              for _, plugin in ipairs(require('lazy').plugins()) do
                add(plugin.dir)
              end
            end
          end

          require('lspconfig').lua_ls.setup {
            capabilities = capabilities,
            settings = {
              Lua = {
                codeLens = { enable = true },
                doc = {
                  privateName = { '^_' },
                },
                diagnostics = {
                  disable = { 'redefined-local' },
                  unusedLocalExclude = { '_*' },
                  -- Uncomment to receive LSP formatting diagnostics.
                  -- neededFileStatus = { ['codestyle-check'] = 'Any' },
                },
                telemetry = { enable = false },
                runtime = {
                  version = 'LuaJIT',
                  path = {
                    '?.lua',
                    '?/init.lua',
                  },
                  pathStrict = true,
                },
                workspace = {
                  -- Make the server aware of Neovim runtime files
                  library = library,
                },
                -- see https://github.com/CppCXY/EmmyLuaCodeStyle/blob/master/docs/format_config_EN.md
                format = {
                  enable = false,
                  defaultConfig = {
                    indent_size = '2',
                    indent_style = 'space',
                    quote_style = 'single',
                    max_line_length = '80',
                    trailing_table_separator = 'smart',
                    -- NOTE: some options break some formatting properties? :(
                    -- in fact a lot of things are buggy (removing `quote_style`
                    -- property allows trailing table separators to be more
                    -- comprehensive) but... good enough :)
                    -- break_all_list_when_line_exceed = true, --breaks things sadly
                    call_arg_parentheses = 'remove_table_only',
                    -- align_call_args = true, -- breaks things sadly
                  },
                },
              },
            },
          }
        end,
        ['pylsp'] = function()
          require('lspconfig').pylsp.setup {
            capabilities = capabilities,
            on_attach = function(_, bufnr)
              -- https://vi.stackexchange.com/questions/39200/wrapping-comment-in-visual-mode-not-working-with-gq
              vim.bo[bufnr].formatexpr = nil
            end,
            settings = {
              pylsp = {
                plugins = {
                  pycodestyle = {
                    maxLineLength = 80,
                  },
                },
              },
            },
          }
        end,
        ['rust_analyzer'] = function()
          -- don't set up, this will be done by rustaceanvim
        end,
        ['tsserver'] = function()
          -- don't set up, conflicts with typescript-tools.nvim
        end,
      }

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        -- to disable qflist opening, see
        -- https://github.com/neovim/neovim/pull/19213
        callback = function(ev)
          local attached_client = vim.lsp.get_client_by_id(ev.data.client_id)
          if attached_client.server_capabilities.codeLensProvider then
            vim.lsp.codelens.refresh()
            vim.api.nvim_create_autocmd(SETTINGS.codelens_refresh_events, {
              buffer = ev.buf,
              group = vim.api.nvim_create_augroup(
                'CodelensRefresh',
                { clear = true }
              ),
              callback = vim.lsp.codelens.refresh,
            })
          end
          local map = vim.keymap.set
          local opts = { buffer = ev.buf, remap = false, silent = true }

          -- if action opens up qf list, open the first item and close the list
          local function choose_list_first(options)
            vim.fn.setqflist({}, ' ', options)
            vim.cmd.cfirst()
          end

          map('n', 'K', function()
            local winid = require('ufo').peekFoldedLinesUnderCursor()
            if not winid then
              vim.lsp.buf.hover()
            end
          end, opts)
          map('n', '<leader>e', vim.diagnostic.open_float, opts)
          -- go back with <C-o>, forth with <C-i>
          map('n', 'gd', function()
            vim.lsp.buf.definition { on_list = choose_list_first }
          end, opts)
          map('n', 'gD', function()
            vim.cmd.split { mods = { tab = vim.fn.tabpagenr() + 1 } }
            vim.lsp.buf.definition { on_list = choose_list_first }
          end, opts)
          map('n', '<leader>gd', vim.lsp.buf.declaration, opts)
          map(
            'n',
            '<leader>gD',
            '<cmd>tab split | lua vim.lsp.buf.declaration()<CR>',
            opts
          )
          map('n', 'gt', vim.lsp.buf.type_definition, opts)
          map(
            'n',
            'gT',
            '<cmd>tab split | lua vim.lsp.buf.type_definition()<CR>',
            opts
          )
          map('n', 'gi', function()
            vim.cmd.Telescope('lsp_implementations')
          end, opts)
          map('n', 'gI', function()
            vim.cmd.split { mods = { tab = vim.fn.tabpagenr() + 1 } }
            vim.lsp.buf.implementation { on_list = choose_list_first }
          end, opts)
          map('n', 'gr', function()
            vim.cmd.Telescope('lsp_references')
          end, opts)
          map('n', '<leader>dk', function()
            goto_diagnostic_hl('prev')
          end, opts)
          map('n', '<leader>dj', function()
            goto_diagnostic_hl('next')
          end, opts)
          -- rename symbol starting with empty prompt, highlight references
          map('n', '<leader>r', function()
            local bufnr = vim.api.nvim_get_current_buf()
            local params = vim.lsp.util.make_position_params()
            params.context = { includeDeclaration = true }
            local clients = vim.lsp.get_active_clients()
            local client = clients[1]
            for _, possible_client in pairs(clients) do
              if possible_client.server_capabilities.renameProvider then
                client = possible_client
                break
              end
            end
            local ns = vim.api.nvim_create_namespace('LspRenamespace')

            client.request(
              'textDocument/references',
              params,
              function(_, result)
                if not result or vim.tbl_isempty(result) then
                  vim.notify('Nothing to rename.')
                  return
                end

                for _, v in ipairs(result) do
                  if v.range then
                    local buf = vim.uri_to_bufnr(v.uri)
                    local line = v.range.start.line
                    local start_char = v.range.start.character
                    local end_char = v.range['end'].character
                    if buf == bufnr then
                      print(line, start_char, end_char)
                      vim.api.nvim_buf_add_highlight(
                        bufnr,
                        ns,
                        'LspReferenceWrite',
                        line,
                        start_char,
                        end_char
                      )
                    end
                  end
                end
                vim.cmd.redraw()
                local new_name = vim.fn.input { prompt = 'New name: ' }
                vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
                if #new_name == 0 then
                  return
                end
                vim.lsp.buf.rename(new_name)
              end,
              bufnr
            )
          end)
          -- show code actions, executing if only 1
          map('n', '<leader>ca', function()
            require('actions-preview').code_actions()
          end, opts)
          map('n', '<leader>cl', vim.lsp.codelens.run, opts)
        end,
      })

      vim.diagnostic.config {
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = { border = BORDER_STYLE },
      }

      vim.lsp.handlers['textDocument/hover'] =
        vim.lsp.with(vim.lsp.handlers.hover, {
          border = BORDER_STYLE,
        })
      vim.lsp.handlers['textDocument/signatureHelp'] =
        vim.lsp.with(vim.lsp.handlers.signature_help, {
          border = BORDER_STYLE,
        })

      local signs =
        { Error = ' ', Warn = ' ', Hint = '󰌶 ', Info = ' ' }
      for type, icon in pairs(signs) do
        local hl = 'DiagnosticSign' .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- Create a custom namespace. This will aggregate signs from all other
      -- namespaces and only show the one with the highest severity on a
      -- given line
      local ns = vim.api.nvim_create_namespace('my_namespace')
      -- Get a reference to the original signs handler
      local orig_signs_handler = vim.diagnostic.handlers.signs
      -- Override the built-in signs handler
      vim.diagnostic.handlers.signs = {
        show = function(_, bufnr, _, opts)
          -- Get all diagnostics from the whole buffer rather than just the
          -- diagnostics passed to the handler
          local diagnostics = vim.diagnostic.get(bufnr)
          -- Find the "worst" diagnostic per line
          local max_severity_per_line = {}
          for _, d in pairs(diagnostics) do
            local m = max_severity_per_line[d.lnum]
            if not m or d.severity < m.severity then
              max_severity_per_line[d.lnum] = d
            end
          end
          -- Pass the filtered diagnostics (with our custom namespace) to
          -- the original handler
          local filtered_diagnostics = vim.tbl_values(max_severity_per_line)
          orig_signs_handler.show(ns, bufnr, filtered_diagnostics, opts)
        end,
        hide = function(_, bufnr)
          orig_signs_handler.hide(ns, bufnr)
        end,
      }

      -- auto-install some packages that cannot be handled by `ensure_installed`
      local registry = require('mason-registry')
      local ensured_formatters = SETTINGS.ensure_installed_formatters
      registry.refresh(function()
        for _, pkg_name in ipairs(ensured_formatters) do
          local pkg = registry.get_package(pkg_name)
          if not pkg:is_installed() then
            pkg:install()
          end
        end
      end)
    end,
  },
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    opts = {
      settings = {
        tsserver_file_preferences = {
          -- NOTE: Should only really enable this if working in a Tree-sitter
          -- grammar
          disableSuggestions = false,
        },
      },
    },
  },
  {
    'aznhe21/actions-preview.nvim',
    lazy = true,
    config = function()
      local hl = require('actions-preview.highlight')
      require('actions-preview').setup {
        backend = { 'telescope' },
        telescope = SETTINGS.telescope_centered_picker,
        highlight_command = {
          hl.delta('delta --hunk-header-style omit --paging=always'),
        },
      }
    end,
  },
}
