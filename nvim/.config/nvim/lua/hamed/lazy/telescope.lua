return {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    cmd = "Telescope",
    event = "VeryLazy",

    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-fzy-native.nvim",
        { "nvim-telescope/telescope-ui-select.nvim", event = "VeryLazy" }
    },

    config = function()
        require("telescope").setup({
            defaults = {
                prompt_prefix = "   ",
                selection_caret = "  ",
                entry_prefix = "  ",
                initial_mode = "insert",
                selection_strategy = "reset",
                sorting_strategy = "ascending",
                layout_strategy = "horizontal",
                layout_config = {
                    horizontal = {
                        prompt_position = "top",
                        preview_width = 0.55,
                        results_width = 0.8,
                    },
                    width = 0.87,
                    height = 0.80,
                    preview_cutoff = 120,
                },
                path_display = { "truncate" },
                mappings = {
                    i = {
                        ["<C-h>"] = "which_key"
                    }
                }
            },
            pickers = {
                find_files = {
                    find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
                },
            },
            extensions = {
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown()
                },
            },
        })

        require("telescope").load_extension("git_worktree")
        require("telescope").load_extension("fzy_native")
        require("telescope").load_extension("ui-select")

        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>pf", builtin.find_files, { desc = "Find files" })
        vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
        vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "Git files" })
        vim.keymap.set("n", "<leader>pws", function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end, { desc = "Find current word" })
        vim.keymap.set("n", "<leader>pWs", function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end, { desc = "Find current WORD" })
        vim.keymap.set("n", "<leader>pa", function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end, { desc = "Grep string" })
        vim.keymap.set("n", "<leader>vh", builtin.help_tags, { desc = "Help tags" })
        vim.keymap.set("n", "<leader>pb", builtin.buffers, { desc = "Find buffers" })
        vim.keymap.set("n", "<leader>pr", builtin.oldfiles, { desc = "Recent files" })
        vim.keymap.set("n", "<leader>ps", function()
            builtin.live_grep({
                glob_pattern = "!**/.git/*",
                additional_args = { "--hidden" }
            })
        end, { desc = "Search all files (with hidden)" })
    end
}
