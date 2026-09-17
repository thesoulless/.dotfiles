-- nvim-treesitter `main` (the `master` branch is frozen). Parsers are compiled with the
-- tree-sitter CLI (brew "tree-sitter-cli") into stdpath("data")/site/parser; highlighting
-- and indentation are wired through the built-in vim.treesitter API below.
return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-context",
    },
    config = function()
        local ts = require("nvim-treesitter")

        local ensure_installed = {
            "bash", "c", "css", "diff", "dockerfile", "git_config", "gitcommit", "gitignore", "go", "gomod",
            "gosum", "gotmpl", "gowork", "hcl", "html", "javascript", "jsdoc", "json", "lua", "make",
            "markdown", "markdown_inline", "nix", "nu", "python", "query", "regex", "rust", "sql",
            "ssh_config", "templ", "terraform", "toml", "tsx", "typescript", "vimdoc", "yaml", "zig",
        }
        local installed = ts.get_installed("parsers")
        local missing = vim.tbl_filter(function(lang)
            return not vim.tbl_contains(installed, lang)
        end, ensure_installed)
        if #missing > 0 then
            ts.install(missing)
        end

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("hamed_treesitter", { clear = true }),
            callback = function(ev)
                local lang = vim.treesitter.language.get_lang(ev.match)
                if not lang or lang == "html" then
                    return
                end

                local max_filesize = 100 * 1024 -- 100 KB
                local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
                if ok and stats and stats.size > max_filesize then
                    vim.notify("File larger than 100KB, treesitter disabled for performance",
                        vim.log.levels.WARN, { title = "Treesitter" })
                    return
                end

                -- Parser not installed (yet): fall back to regex syntax silently.
                if not pcall(vim.treesitter.start, ev.buf, lang) then
                    return
                end
                vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end
}
