vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")


vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "=ap", "ma=ap'a")

vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

vim.keymap.set({ "n", "v" }, "<C-A>", "<C-a>")

vim.keymap.set('n', '<leader>gws', ':Telescope git_worktree git_worktrees<CR>')
vim.keymap.set('n', '<leader>gwc', ':Telescope git_worktree create_git_worktree<CR>')

vim.keymap.set(
    "n",
    "<leader>ee",
    "oif err != nil {<CR>}<Esc>Oreturn err<Esc>"
)
vim.keymap.set("n", "<leader>y1", "<cmd>silent !afplay ~/.nvim/y1.mp3<CR>")
vim.keymap.set("n", "<leader>y2", "<cmd>silent !afplay ~/.nvim/y2.mp3<CR>")
vim.keymap.set("n", "<leader>y3", "<cmd>silent !afplay ~/.nvim/y3.mp3<CR>")

vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
vim.keymap.set('n', '<F8>', function() require('dap').step_back() end)

vim.keymap.set('n', '<Leader>q', function()
    require('dap').toggle_breakpoint()
    store_breakpoints(false)
end)
vim.keymap.set('n', '<Leader>Q',
    function()
        require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
        store_breakpoints(false)
    end)
vim.keymap.set('n', '<Leader>lp', function()
    require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
    store_breakpoints(false)
end)
vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)

vim.keymap.set('n', '<Leader>w', function() require('dapui').open() end)
vim.keymap.set('n', '<Leader>W', function() require('dapui').close() end)
vim.keymap.set('n', '<leader>?', function() require('dapui').eval(nil, { enter = true }) end)
vim.keymap.set("n", "<leader>gd", ":GoDoc<CR>");

local set = vim.opt_local

vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("custom-term-open", {}),
    callback = function()
        set.number = false
        set.relativenumber = false
        set.scrolloff = 0
    end,
})

vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>")

vim.keymap.set("n", "<leader>T", function()
    vim.cmd.new()
    vim.cmd.wincmd "J"
    vim.api.nvim_win_set_height(0, 12)
    vim.wo.winfixheight = true
    vim.cmd.term()
end)

vim.keymap.set("n", "<leader>m", function()
    -- go to the next split
    vim.cmd("wincmd w")
    -- get current win height
    local height = vim.api.nvim_win_get_height(0)
    -- set the height to 12 if it's not 12
    if height ~= 12 then
        vim.api.nvim_win_set_height(0, 12)
    else
        -- set the height to 1 if it's 12
        vim.api.nvim_win_set_height(0, 1)
    end
    -- go back to the previous split
    vim.cmd("wincmd w")
end)
