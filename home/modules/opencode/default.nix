{ ... }:

{
  xdg.configFile = {
    "opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      model = "opencode-go/mimo-v2.6-pro";
      small_model = "opencode-go/hy4-flash-free";
      permission = {
        bash = {
          "*" = "allow";
          "git commit*" = "deny";
          "git push*" = "deny";
          "sudo *" = "deny";
        };
        read = {
          "*" = "allow";
          "*.env" = "deny";
          "*.env.*" = "deny";
          "*.env.example" = "allow";
        };
      };
      mcp = {
        context7 = {
          type = "remote";
          url = "https://mcp.context7.com/mcp";
          enabled = true;
        };
        memory = {
          type = "local";
          command = [ "npx" "-y" "@modelcontextprotocol/server-memory" ];
          enabled = true;
        };
        fetch = {
          type = "local";
          command = [ "uvx" "mcp-server-fetch" ];
          enabled = true;
        };
        railway = {
          type = "remote";
          url = "https://mcp.railway.com";
          enabled = true;
        };
      };
    };
    "opencode/AGENTS.md".source = ./AGENTS.md;
    "opencode/agents" = {
      source = ./agents;
      recursive = true;
    };
    "opencode/commands" = {
      source = ./commands;
      recursive = true;
    };
  };
}
