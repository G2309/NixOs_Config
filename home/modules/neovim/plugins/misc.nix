{ config, pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = oil-nvim;
      type = "lua";
      config = ''
        require("oil").setup({
          default_file_explorer = true,
          columns = {
            "icon",
            "size",
          },
          view_options = {
            show_hidden = true,
          },
          keymaps = {
            ["g?"] = "actions.show_help",
            ["<CR>"] = "actions.select",
            ["<C-v>"] = "actions.select_vsplit",
            ["<C-s>"] = "actions.select_split",
            ["<C-t>"] = "actions.select_tab",
            ["<C-p>"] = "actions.preview",
            ["<C-c>"] = "actions.close",
            ["<C-r>"] = "actions.refresh",
            ["-"] = "actions.parent",
            ["_"] = "actions.open_cwd",
            ["`"] = "actions.cd",
            ["~"] = "actions.tcd",
            ["gs"] = "actions.change_sort",
            ["gx"] = "actions.open_external",
            ["g."] = "actions.toggle_hidden",
          },
          float = {
            padding = 2,
            max_width = 90,
            max_height = 30,
            border = "rounded",
          },
        })
      '';
    }

    {
      plugin = neocord;
      type = "lua";
      config = ''
        require("neocord").setup({
          logo = "auto",
          main_image = "language",
          client_id = "1157438221865717891",
          debounce_timeout = 10,
          show_time = true,
          editing_text = "Editing %s",
          file_explorer_text = "Browsing %s",
          git_commit_text = "Committing changes",
          plugin_manager_text = "Managing plugins",
          reading_text = "Reading %s",
          workspace_text = "Working on %s",
          line_number_text = "Line %s out of %s",
          terminal_text = "Using Terminal",
        })
      '';
    }

    {
      plugin = gitsigns-nvim;
      type = "lua";
      config = ''
        require("gitsigns").setup({
          signs = {
            add = { text = "│" },
            change = { text = "│" },
            delete = { text = "󰍵" },
            topdelete = { text = "‾" },
            changedelete = { text = "~" },
          },
          on_attach = function(bufnr)
            local gs = package.loaded.gitsigns
            local map = vim.keymap.set

            map('n', ']c', gs.next_hunk, { buffer = bufnr })
            map('n', '[c', gs.prev_hunk, { buffer = bufnr })
            map('n', '<leader>hs', gs.stage_hunk, { buffer = bufnr })
            map('n', '<leader>hr', gs.reset_hunk, { buffer = bufnr })
            map('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr })
            map('n', '<leader>hb', gs.blame_line, { buffer = bufnr })
          end,
        })
      '';
    }

    {
      plugin = comment-nvim;
      type = "lua";
      config = ''
        require("Comment").setup()
      '';
    }

    {
      plugin = nvim-autopairs;
      type = "lua";
      config = ''
        require("nvim-autopairs").setup({
          check_ts = true,
        })
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        local cmp = require("cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      '';
    }

    vim-sleuth
    nvim-surround
    {
      plugin = nvim-surround;
      type = "lua";
      config = ''require("nvim-surround").setup()'';
    }

    {
      plugin = which-key-nvim;
      type = "lua";
      config = ''
        require("which-key").setup({
          delay = 500,
        })
      '';
    }
  ];
}
