return {
    "fredrikaverpil/godoc.nvim",
    version = "*",
    dependencies = {
        { "nvim-telescope/telescope.nvim" }, -- optional
        { "folke/snacks.nvim" },             -- optional
        { "echasnovski/mini.pick" },         -- optional
        { "ibhagwan/fzf-lua" },              -- optional
        {
            "nvim-treesitter/nvim-treesitter",
            opts = {
                ensure_installed = { "go" },
            },
        },
    },
    build = "go install github.com/lotusirous/gostdsym/stdsym@latest",
    cmd = { "GoDoc" },
    adapters = {
        {
            name = "go",
            opts = {
                command = "GoDoc",
                get_syntax_info = function()
                    return {
                        filetype = "godoc",
                        language = "go",
                    }
                end,
            },
        },
    },
    opts = {
        picker = {
            type = "telescope",
        },
    },
}
