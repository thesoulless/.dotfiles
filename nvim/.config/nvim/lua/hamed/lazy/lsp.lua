return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
        "ray-x/lsp_signature.nvim",
    },

    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        local replace_termcodes = function(str)
            return vim.api.nvim_replace_termcodes(str, true, true, true)
        end

        local function check_backspace()
            local col = vim.fn.col('.') - 1
            return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s')
        end

        local tab_complete = function(fallback)
            local copilot_accept = vim.fn['copilot#Accept']
            local copilot_keys = ''
            if copilot_accept then
                local ok, copilot_keys_ = pcall(copilot_accept)
                if ok then
                    copilot_keys = copilot_keys_
                end
            end
            local has_avante, avante_api = pcall(require, 'avante.api')
            local avante_suggestion = nil
            if has_avante then
                avante_suggestion = avante_api.get_suggestion()
            end
            local has_copilot_lua, copilot_lua_suggestion = pcall(require, 'copilot.suggestion')

            local buf = vim.api.nvim_get_current_buf()
            local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
            if buftype == '' then
                if copilot_keys ~= '' then
                    vim.api.nvim_feedkeys(copilot_keys, 'i', true)
                elseif avante_suggestion and avante_suggestion:is_visible() then
                    avante_suggestion:accept()
                elseif has_copilot_lua and copilot_lua_suggestion.is_visible() then
                    copilot_lua_suggestion.accept_line()
                elseif cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                    vim.fn.feedkeys(replace_termcodes('<Plug>luasnip-expand-or-jump'), '')
                elseif check_backspace() then
                    vim.fn.feedkeys(replace_termcodes('<Tab>'), 'n')
                else
                    if fallback then
                        fallback()
                    end
                end
            else
                if fallback then
                    fallback()
                end
            end
        end

        require("conform").setup({
            formatters_by_ft = {
                lua = { "stylua" },
                go = { "gofumpt" },
                rust = { "rustfmt" },
                javascript = { "biome" },
                typescript = { "biome" },
                json = { "biome" },
                python = { "ruff_format", "black" },
                ["_"] = { "trim_whitespace" }
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
        })
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        local signature_setup = {
            bind = true,
            hint_enable = true,
            hint_prefix = "🐼 ",
            handler_opts = {
                border = "rounded"
            },
            floating_window = true,
            max_width = 80,
        }

        local function on_attach(_, bufnr)
            require("lsp_signature").on_attach(signature_setup, bufnr)
        end

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                -- "gopls",
                "templ",
                -- "delve"
                -- "eslint",
                -- "pyright",
                -- "golangci_lint_ls",
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities,
                        opts = {
                            inlay_hints = {
                                enabled = true,
                                show_parameter_hints = true,
                                parameter_hints_prefix = " ",
                                other_hints_prefix = " ",
                            },
                        },
                    }
                end,

                zls = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.zls.setup({
                        root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
                        settings = {
                            zls = {
                                enable_inlay_hints = true,
                                enable_snippets = true,
                                warn_style = true,
                            },
                        },
                    })
                    vim.g.zig_fmt_parse_errors = 0
                    vim.g.zig_fmt_autosave = 0
                end,
                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                runtime = { version = "Lua 5.1" },
                                diagnostics = {
                                    globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,
                ["dprint"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.dprint.setup {
                        capabilities = capabilities,
                    }
                end,
                ["gopls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.gopls.setup {
                        capabilities = capabilities,
                        settings = {
                            gopls = {
                                codelenses = {
                                    gc_details = false,
                                    generate = true,
                                    regenerate_cgo = true,
                                    run_govulncheck = true,
                                    test = true,
                                    tidy = true,
                                    upgrade_dependency = true, -- do I really want this?
                                    vendor = true,
                                },
                                hints = {
                                    assignVariableTypes = true,
                                    compositeLiteralFields = true,
                                    compositeLiteralTypes = true,
                                    constantValues = true,
                                    functionTypeParameters = true,
                                    parameterNames = true,
                                    rangeVariableTypes = true,
                                },
                                analyses = {
                                    nilness = true,
                                    unusedparams = true,
                                    shadow = true,
                                    unusedwrite = true,
                                    useany = true,
                                    modernize = true,
                                },
                                gofumpt = true,
                                staticcheck = true,
                                usePlaceholders = true,
                                completeUnimported = true,
                                directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules", "-_data", "-.direnv", "-.devenv" },
                                semanticTokens = true,
                            },
                        },
                        on_attach = on_attach,
                    }
                end,
                ruff = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.ruff.setup {}
                end
            }
        })

        local lspconfig = require("lspconfig")
        lspconfig.dprint.setup {
            single_file_support = true,
        }

        lspconfig.biome.setup {
            single_file_support = true,
            -- on_attach = function(client, bufnr)
            --  client.server_capabilities.documentFormatProvider = true
            --  vim.api.nvim_create_autocmd("BufWritePre", {
            --  buffer = bufnr,
            --  callback = function()
            --  vim.lsp.buf.format({ async = false })
            --  end,
            --  })
            -- end,
        }

        lspconfig.gopls.setup {
            capabilities = capabilities,
            settings = {
                gopls = {
                    codelenses = {
                        gc_details = false,
                        generate = true,
                        regenerate_cgo = true,
                        run_govulncheck = true,
                        test = true,
                        tidy = true,
                        upgrade_dependency = true, -- do I really want this?
                        vendor = true,
                    },
                    hints = {
                        assignVariableTypes = true,
                        compositeLiteralFields = true,
                        compositeLiteralTypes = true,
                        constantValues = true,
                        functionTypeParameters = true,
                        parameterNames = true,
                        rangeVariableTypes = true,
                    },
                    analyses = {
                        nilness = true,
                        unusedparams = true,
                        shadow = true,
                        unusedwrite = true,
                        useany = true,
                        modernize = true,
                    },
                    gofumpt = true,
                    staticcheck = true,
                    usePlaceholders = true,
                    completeUnimported = true,
                    directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules", "-_data", "-.direnv", "-.devenv" },
                    semanticTokens = true,
                },
            },
            on_attach = on_attach,
        }

        require('lspconfig').nixd.setup {}

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            preselect = cmp.PreselectMode.None,
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                -- `Enter` key to confirm completion
                ['<CR>'] = cmp.mapping.confirm({ select = false }),

                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
                ['<Tab>'] = tab_complete,
            }),
            sources = cmp.config.sources({
                { name = "copilot", group_index = 2 },
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
                { name = "path" },
                { name = "calc" },
                { name = "emoji" }, -- load for writing only
            }, {
                { name = 'path' },
                { name = 'buffer' },
            }),
            completion = {
                completeopt = 'menu,menuone,noinsert',
            },
            window = {
                completion = cmp.config.window.bordered()
            },
            formatting = {
                fields = { 'kind', 'abbr', 'menu' },
                format = function(_, vim_item)
                    vim_item.menu = vim_item.kind
                    return vim_item
                end,
            },
        })

        vim.diagnostic.config({
            virtual_test = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
