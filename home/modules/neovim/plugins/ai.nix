{ config, pkgs, ... }:

{
  programs.neovim = {
    extraPackages = [ pkgs.curl ];

    plugins = with pkgs.vimPlugins; [
      {
        plugin = minuet-ai-nvim;
        type = "lua";
        config = ''
          local modelo = "qwen2.5-coder:3b-base"

          require("minuet").setup({
            provider = "openai_fim_compatible",
            n_completions = 1,
            context_window = 6000,
            throttle = 400,
            debounce = 250,
            request_timeout = 3,
            notify = "error",
            provider_options = {
              openai_fim_compatible = {
                api_key = "TERM",
                name = "Ollama",
                end_point = "http://127.0.0.1:11434/v1/completions",
                model = modelo,
                stream = true,
                optional = {
                  max_tokens = 64,
                  top_p = 0.9,
                },
              },
            },
            virtualtext = {
              auto_trigger_ft = {},
              show_on_completion_menu = false,
              keymap = {
                accept = "<A-a>",
                accept_line = "<A-l>",
                next = "<A-]>",
                prev = "<A-[>",
                dismiss = "<A-e>",
              },
            },
          })

          vim.g.ia_autocompletado = true

          _G.estado_ia = function()
            return vim.g.ia_autocompletado and "IA: on" or "IA: off"
          end

          local function aplicar(buf)
            if vim.bo[buf].buftype == "" then
              vim.b[buf].minuet_virtual_text_auto_trigger = vim.g.ia_autocompletado
            end
          end

          vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
            group = vim.api.nvim_create_augroup("IaAutocompletado", { clear = true }),
            callback = function(ev)
              aplicar(ev.buf)
            end,
          })

          local function alternar()
            vim.g.ia_autocompletado = not vim.g.ia_autocompletado
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(buf) then
                aplicar(buf)
              end
            end
            if not vim.g.ia_autocompletado then
              pcall(require("minuet.virtualtext").action.dismiss)
              vim.system({
                "curl", "-s", "http://127.0.0.1:11434/api/generate",
                "-d", vim.json.encode({ model = modelo, keep_alive = 0 }),
              })
            end
            vim.notify("Autocompletado IA: " .. (vim.g.ia_autocompletado and "encendido" or "apagado"))
            pcall(function()
              require("lualine").refresh()
            end)
          end

          vim.keymap.set("n", "<leader>ai", alternar, { desc = "Encender/apagar autocompletado IA" })
          vim.keymap.set({ "n", "i" }, "<A-i>", alternar, { desc = "Encender/apagar autocompletado IA" })

          pcall(function()
            require("which-key").add({
              { "<leader>a", group = "IA" },
              { "<leader>ai", desc = "Encender/apagar autocompletado" },
            })
          end)
          vim.api.nvim_create_user_command("IA", alternar, {})
        '';
      }
    ];
  };
}
