local breakpoints = require('hamed.lazy.utils.session-breakpoints')

return {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
        vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
        vim.keymap.set("n", "<leader>sr", "<cmd>SessionSearch<CR>", { desc = "Session search" })
        vim.keymap.set("n", "<leader>ss", "<cmd>SessionSave<CR>", { desc = "Session save" })
        vim.keymap.set("n", "<leader>sa", "<cmd>SessionToggleAutoSave<CR>", { desc = "Toggle autosave" })

        ---@module "auto-session"
        ---@type AutoSession.Config
        local opts = {
            suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
            log_level = 'error',

            post_save_cmds = { breakpoints.save_session_breakpoints },
            post_restore_cmds = { breakpoints.restore_session_breakpoints },
            pre_delete_cmds = { breakpoints.delete_session_breakpoints },

            session_lens = {
                -- If load_on_setup is false, make sure you use `:SessionSearch` to open the picker as it will initialize everything first
                load_on_setup = true,
                previewer = false,
                mappings = {
                    -- Mode can be a string or a table, e.g. {"i", "n"} for both insert and normal mode
                    delete_session = { "i", "<C-D>" },
                    alternate_session = { "i", "<C-S>" },
                    copy_session = { "i", "<C-Y>" },
                },
                -- Can also set some Telescope picker options
                theme_conf = {
                    border = true,
                },
            },
        }
        require('auto-session').setup(opts)
    end
}
