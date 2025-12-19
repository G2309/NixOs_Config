{ config, pkgs, ... }:

{
  programs.neovim = {
    extraPackages = with pkgs; [
      ripgrep
      fd
    ];

    plugins = with pkgs.vimPlugins; [
      plenary-nvim
      telescope-fzf-native-nvim

      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          local telescope = require("telescope")
          local actions = require("telescope.actions")

          telescope.setup({
            defaults = {
              prompt_prefix = "   ",
              selection_caret = "  ",
              path_display = { "truncate" },
              sorting_strategy = "ascending",
              layout_config = {
                horizontal = {
                  prompt_position = "top",
                  preview_width = 0.55,
                },
                width = 0.87,
                height = 0.80,
              },
              mappings = {
                i = {
                  ["<C-n>"] = actions.move_selection_next,
                  ["<C-p>"] = actions.move_selection_previous,
                  ["<C-j>"] = actions.move_selection_next,
                  ["<C-k>"] = actions.move_selection_previous,
                  ["<Esc>"] = actions.close,
                },
              },
            },
            pickers = {
              find_files = {
                hidden = true,
                file_ignore_patterns = { ".git/", "node_modules/" },
              },
            },
            extensions = {
              fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = "smart_case",
              },
            },
          })

          telescope.load_extension("fzf")
        '';
      }
    ];
  };
}
