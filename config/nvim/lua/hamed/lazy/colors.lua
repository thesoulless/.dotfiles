return {
    "navarasu/onedark.nvim",
    lazy = false,
    config = function()
        require('onedark').setup({
            style = 'warmer',
            transparent = false,
        })

        require('onedark').load()
    end
}
