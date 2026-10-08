local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = "hamed.lazy",
    change_detection = { notify = false },
    -- No plugin here needs luarocks; plenary ships a rockspec which otherwise
    -- makes `:checkhealth lazy` demand a Lua 5.1 install.
    rocks = { enabled = false },
})
