{ config, pkgs, ... }:

{
  programs.neovim.extraLuaConfig = ''
    -- Options
    vim.g.mapleader = ","
    vim.g.maplocalleader = ","

    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.smartindent = true
    vim.opt.expandtab = true
    vim.opt.hlsearch = true
    vim.opt.incsearch = true
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.opt.hidden = true
    vim.opt.termguicolors = true
    vim.opt.cursorline = true
    vim.opt.scrolloff = 8
    vim.opt.signcolumn = "yes"
    vim.opt.updatetime = 250
    vim.opt.undofile = true
    vim.opt.splitright = true
    vim.opt.splitbelow = true

    -- Keymaps
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- General
    map('n', '<leader>w', '<cmd>w<cr>', opts)
    map('n', '<leader>q', '<cmd>q<cr>', opts)
    map('n', '<leader>x', '<cmd>x<cr>', opts)
    map('n', '<Esc>', '<cmd>nohlsearch<cr>', opts)

    -- Window navigation
    map('n', '<C-h>', '<C-w>h', opts)
    map('n', '<C-j>', '<C-w>j', opts)
    map('n', '<C-k>', '<C-w>k', opts)
    map('n', '<C-l>', '<C-w>l', opts)

    -- Buffer navigation
    map('n', '<leader>bn', '<cmd>bnext<cr>', opts)
    map('n', '<leader>bp', '<cmd>bprevious<cr>', opts)
    map('n', '<leader>bd', '<cmd>bdelete<cr>', opts)

    -- Move lines
    map('v', 'J', ":m '>+1<cr>gv=gv", opts)
    map('v', 'K', ":m '<-2<cr>gv=gv", opts)

    -- Better indenting
    map('v', '<', '<gv', opts)
    map('v', '>', '>gv', opts)

    -- Telescope
    map('n', '<leader>ff', '<cmd>Telescope find_files<cr>', opts)
    map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', opts)
    map('n', '<leader>fb', '<cmd>Telescope buffers<cr>', opts)
    map('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', opts)
    map('n', '<leader>fr', '<cmd>Telescope oldfiles<cr>', opts)
    map('n', '<leader>gs', '<cmd>Telescope git_status<cr>', opts)
    map('n', '<leader>gc', '<cmd>Telescope git_commits<cr>', opts)
    map('n', '<leader>gb', '<cmd>Telescope git_branches<cr>', opts)

    -- Oil 
    map('n', '<leader>e', '<cmd>Oil<cr>', opts)
    map('n', '-', '<cmd>Oil<cr>', opts)

    -- Diagnostics
    map('n', '<leader>d', vim.diagnostic.open_float, opts)
    map('n', '[d', vim.diagnostic.goto_prev, opts)
    map('n', ']d', vim.diagnostic.goto_next, opts)
  '';
}
