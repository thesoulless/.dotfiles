return {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = { { "<leader>u", desc = "Toggle Undotree" } },
    config = function() 
        vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })
    end
}
