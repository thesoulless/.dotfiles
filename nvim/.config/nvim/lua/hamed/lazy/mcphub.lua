return {
    "ravitemer/mcphub.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
    },
    -- cmd = "MCPHub", -- lazily start the hub when `MCPHub` is called
    build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
    config = function()
        local config = vim.fn.expand("~/mcpservers.json")
        local curr_config = vim.fn.expand("%:p:h") .. "/mcpservers.json"
        local git_root = vim.fn.system('git -C ' .. vim.fn.expand("%:p:h") .. ' rev-parse --show-toplevel'):gsub('\n', '')
        if vim.v.shell_error == 0 then
            curr_config = git_root .. "/mcpservers.json"
        end
        local final_config = vim.fn.filereadable(curr_config) == 1 and curr_config or config

        if vim.fn.filereadable(final_config) == 0 and vim.fn.filereadable(config) == 0 then
            vim.api.nvim_err_writeln("No mcpservers.json found in " .. config)
            return
        else
            vim.api.nvim_out_write("Using mcpservers.json from " .. final_config .. "\n")
        end

        require("mcphub").setup({
            -- Required options
            port = 4000,
            config = final_config,

            -- Optional options
            on_ready = function(hub)
                -- Called when hub is ready
                -- vim.api.nvim_out_write("MCPHub is ready\n")
                -- local log_file = vim.fn.stdpath("data") .. "/mcp_hub.log"
                -- vim.api.nvim_out_write("Log file: " .. log_file .. "\n")
            end,
            on_error = function(err)
                -- Called on errors
                -- vim.api.nvim_err_writeln("MCPHub error: " .. err)
            end,
            log = {
                level = vim.log.levels.WARN,
                -- level = vim.log.levels.INFO,
                to_file = false,
                -- to_file = true,
                -- file_path = vim.fn.stdpath("data") .. "/mcp_hub.log",
                file_path = nil,
                prefix = "MCPHub"
            },
        })
    end,
}
