{ config, pkgs, ... }:

{
  programs.neovim = {
    withPython3 = true;
    
    extraPython3Packages = ps: with ps; [
      pynvim
      jupyter-client
      ipython
      ipykernel
    ];

    plugins = with pkgs.vimPlugins; [
      {
        plugin = molten-nvim;
        type = "lua";
        config = ''
          vim.g.molten_auto_open_output = false
          vim.g.molten_image_provider = "none" 
          vim.g.molten_wrap_output = true
          vim.g.molten_virt_text_output = true
          vim.g.molten_virt_lines_off_by_1 = true

          -- Keymaps para Jupyter/Molten
          local map = vim.keymap.set
          local opts = { noremap = true, silent = true }

          -- Inicializar kernel de Jupyter para el buffer actual
          map("n", "<leader>mi", ":MoltenInit<CR>", opts)
          
          -- Evaluar código
          map("n", "<leader>ml", ":MoltenEvaluateLine<CR>", opts) 
          map("v", "<leader>me", ":<C-u>MoltenEvaluateVisual<CR>gv", opts) 
          
          -- Manejo de ventanas de output
          map("n", "<leader>mo", ":MoltenShowOutput<CR>", opts)
          map("n", "<leader>mh", ":MoltenHideOutput<CR>", opts)
          map("n", "<leader>md", ":MoltenDelete<CR>", opts)
        '';
      }
    ];
  };
}
