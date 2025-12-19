{ config, pkgs, ... }:

{
  programs.neovim = {
    extraPackages = with pkgs; [
      lua-language-server
      nil
      pyright
      rust-analyzer
      typescript-language-server
      nodePackages.vscode-langservers-extracted
      gopls
    ];

    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          local capabilities = require("cmp_nvim_lsp").default_capabilities()

          vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
            callback = function(ev)
              local map = vim.keymap.set
              local opts = { buffer = ev.buf, noremap = true, silent = true }

              map('n', 'gD', vim.lsp.buf.declaration, opts)
              map('n', 'gd', vim.lsp.buf.definition, opts)
              map('n', 'K', vim.lsp.buf.hover, opts)
              map('n', 'gi', vim.lsp.buf.implementation, opts)
              map('n', '<C-k>', vim.lsp.buf.signature_help, opts)
              map('n', '<leader>rn', vim.lsp.buf.rename, opts)
              map('n', '<leader>ca', vim.lsp.buf.code_action, opts)
              map('n', 'gr', vim.lsp.buf.references, opts)
              map('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, opts)
            end,
          })

          vim.lsp.config('*', {
            capabilities = capabilities,
          })

          vim.lsp.config('lua_ls', {
            settings = {
              Lua = {
                diagnostics = { globals = { 'vim' } },
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
              },
            },
          })

          vim.lsp.config('nil_ls', {})
          vim.lsp.config('pyright', {})
          vim.lsp.config('rust_analyzer', {})
          vim.lsp.config('ts_ls', {})
          vim.lsp.config('html', {})
          vim.lsp.config('cssls', {})
          vim.lsp.config('gopls', {})

          vim.lsp.enable({
            'lua_ls',
            'nil_ls',
            'pyright',
            'rust_analyzer',
            'ts_ls',
            'html',
            'cssls',
            'gopls',
          })

          vim.diagnostic.config({
            virtual_text = true,
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = {
              border = 'rounded',
              source = true,
            },
          })
        '';
      }
    ];
  };
}
