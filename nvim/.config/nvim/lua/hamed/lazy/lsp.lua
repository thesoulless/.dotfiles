return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
        "mason-org/mason.nvim",
        "mason-org/mason-lspconfig.nvim",
        "j-hui/fidget.nvim",
        {
            -- Completion. Replaces nvim-cmp + cmp-nvim-lsp/buffer/path/cmdline + cmp_luasnip.
            "saghen/blink.cmp",
            version = "1.*", -- release tags ship a prebuilt fuzzy matcher; `main` is v2 (breaking)
            dependencies = { "L3MON4D3/LuaSnip", "rafamadriz/friendly-snippets" },
        },
    },

    config = function()
        ------------------------------------------------------------------
        -- Formatting
        ------------------------------------------------------------------
        require("conform").setup({
            formatters_by_ft = {
                lua = { "stylua" },
                -- gopls formats Go (gofumpt = true below); imports are organized by the
                -- *.go BufWritePre autocmd in hamed/init.lua.
                go = { lsp_format = "prefer" },
                rust = { "rustfmt" },
                -- javascript = { "biome" },
                -- typescript = { "biome" },
                -- json = { "biome" },
                javascript = { "eslint" },
                typescript = { "eslint" },
                json = { "eslint" },
                python = { "ruff_format" },
                ["_"] = { "trim_whitespace" }
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_format = "fallback",
            },
        })

        require("fidget").setup({})

        ------------------------------------------------------------------
        -- Completion (blink.cmp)
        ------------------------------------------------------------------
        require("blink.cmp").setup({
            keymap = {
                -- default preset: <C-y> accept (selects first item if none is selected),
                -- <C-n>/<C-p> next/prev, <C-space> open menu / toggle docs, <C-e> hide
                preset = "default",
                ["<CR>"] = { "accept", "fallback" }, -- only accepts an explicitly selected item
                ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
            },
            snippets = { preset = "luasnip" },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
            completion = {
                list = { selection = { preselect = false, auto_insert = false } },
                menu = { border = "rounded" },
                documentation = { auto_show = true, window = { border = "rounded" } },
            },
            fuzzy = { implementation = "prefer_rust_with_warning" },
        })

        ------------------------------------------------------------------
        -- LSP servers (vim.lsp.config / vim.lsp.enable, Neovim 0.11+).
        -- nvim-lspconfig only supplies the per-server defaults in its lsp/ dir;
        -- everything below is merged on top of those.
        ------------------------------------------------------------------
        vim.lsp.config("*", {
            capabilities = require("blink.cmp").get_lsp_capabilities(),
        })

        vim.lsp.config("gopls", {
            settings = {
                gopls = {
                    codelenses = {
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
                    },
                    gofumpt = true,
                    staticcheck = true,
                    usePlaceholders = true,
                    completeUnimported = true,
                    directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules", "-_data", "-.direnv", "-.devenv" },
                    semanticTokens = true,
                },
            },
        })

        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    diagnostics = {
                        globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                    },
                },
            },
        })

        vim.lsp.config("zls", {
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

        require("mason").setup()
        -- automatic_enable (default) runs vim.lsp.enable() for every mason-installed server.
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "templ",
                -- "pyright", -- Install per project instead
            },
        })

        -- Servers that are installed outside mason (globally or per project via
        -- devenv/uv). Only enable the ones that are actually on PATH.
        for _, server in ipairs({ "gopls", "nixd", "eslint", "ruff", "dprint", "zls" }) do
            local cmd = vim.lsp.config[server] and vim.lsp.config[server].cmd
            -- eslint's cmd is a function (it resolves the server from node_modules), so
            -- there is nothing to probe; lspconfig only starts it when a project uses eslint.
            if type(cmd) ~= "table" or vim.fn.executable(cmd[1]) == 1 then
                vim.lsp.enable(server)
            end
        end

        vim.diagnostic.config({
            virtual_text = true,
            virtual_lines = { current_line = true },
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = true,
                header = "",
                prefix = "",
            },
        })
    end
}
