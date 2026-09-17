require("hamed.remap")
require("hamed.set")
require("hamed.lazy_init")

local augroup = vim.api.nvim_create_augroup
local HamedGroup = augroup('hamed', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
    require("plenary.reload").reload_module(name)
end

vim.filetype.add({
    extension = {
        templ = 'templ',
    }
})

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.hl.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

-- autocmd("BufRead", {
--     group = HamedGroup,
--     pattern = "*",
--     command = [[load_breakpoints()]],
-- })

autocmd({ "BufWritePre" }, {
    group = HamedGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

-- Organize Go imports through gopls before conform formats the buffer (gofumpt via gopls).
autocmd("BufWritePre", {
    group = HamedGroup,
    pattern = "*.go",
    callback = function(ev)
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = ev.buf, name = "gopls" })) do
            local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
            params.context = { only = { "source.organizeImports" } }
            -- 1000ms timeout; bump it if imports only land on the second :w in big repos.
            local result = client:request_sync("textDocument/codeAction", params, 1000, ev.buf)
            for _, action in pairs(result and result.result or {}) do
                if action.edit then
                    vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
                end
            end
        end
    end
})

autocmd('BufEnter', {
    group = HamedGroup,
    callback = function()
        -- if vim.bo.filetype == "zig" then
        --     vim.cmd.colorscheme("tokyonight-night")
        -- else
        --     vim.cmd.colorscheme("rose-pine-moon")
        -- end
    end
})

autocmd('LspAttach', {
    group = HamedGroup,
    callback = function(e)
        local opts = { buffer = e.buf, remap = false }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

        -- Inlay hints (gopls/rust-analyzer/zls are configured to provide them); <leader>th toggles.
        local client = vim.lsp.get_client_by_id(e.data.client_id)
        if client and client:supports_method("textDocument/inlayHint", e.buf) then
            vim.lsp.inlay_hint.enable(true, { bufnr = e.buf })
            vim.keymap.set("n", "<leader>th", function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = e.buf }), { bufnr = e.buf })
            end, { buffer = e.buf, desc = "Toggle inlay hints" })
        end
    end
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
