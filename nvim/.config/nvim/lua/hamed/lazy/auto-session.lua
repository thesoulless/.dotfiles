local breakpoints = require('hamed.lazy.utils.session-breakpoints')

return {
    "rmagatti/auto-session",
    config = function()
        vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
        vim.keymap.set("n", "<leader>sr", "<cmd>SessionSearch<CR>", { desc = "Session search" })
        vim.keymap.set("n", "<leader>ss", "<cmd>SessionSave<CR>", { desc = "SessionToggleAutoSave" })
        vim.keymap.set("n", "<leader>sa", "<cmd>SessionToggleAutoSave<CR>", { desc = "Toggle autosave" })

        require('auto-session').setup({
            post_save_cmds = {
                breakpoints.save_session_breakpoints,
            },

            post_restore_cmds = {
                breakpoints.restore_session_breakpoints,
            },

            pre_delete_cmds = {
                breakpoints.delete_session_breakpoints
            },

            lazy = false,

            ---enables autocomplete for opts
            ---@module "auto-session"
            ---@type AutoSession.Config
            opts = {
                suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
                log_level = 'debug',

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
                    -- For all options, see: https://github.com/nvim-telescope/telescope.nvim/blob/master/doc/telescope.txt#L112
                    theme_conf = {
                        border = true,
                        -- layout_config = {
                        --   width = 0.8, -- Can set width and height as percent of window
                        --   height = 0.5,
                        -- },
                    },
                },
            },
        })
    end
}
