{ config, lib, pkgs, ... }:
let
  accounts = [
    {
      name = "gmail";
      address = "gustavoacruzbar@gmail.com";
      flavor = "gmail.com";
      host = "imap.gmail.com";
      port = 993;
      auth = "password";
      primary = true;
    }
    {
      name = "usapro";
      address = "dev_usaproshop@usapro-shop.com";
      flavor = "plain";
      host = "mail.usapro-shop.com";
      port = 993;
      smtpPort = 465;
      auth = "password";
      primary = false;
    }
  ];

  secretLookup = a: "${pkgs.libsecret}/bin/secret-tool lookup service mail account ${a.address}";

  digestConfig = builtins.toJSON {
    model = "qwen3.5:4b";
    ollama = "http://127.0.0.1:11434";
    accounts = map (a: { inherit (a) name address host port auth; }) accounts;
  };

  digestPy = pkgs.writers.writePython3 "mail-digest.py" {
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./mail-digest.py);

  mail-digest = pkgs.writeShellScriptBin "mail-digest" ''
    export PATH=${lib.makeBinPath [ pkgs.libsecret pkgs.libnotify ]}:$PATH
    export MAIL_DIGEST_CONFIG=${lib.escapeShellArg digestConfig}
    exec ${digestPy} "$@"
  '';

  mail-password = pkgs.writeShellScriptBin "mail-password" ''
    set -eu
    ADDR="''${1:-}"
    if [ -z "$ADDR" ]; then
      echo "uso: mail-password <correo>" >&2
      exit 1
    fi
    ${pkgs.libsecret}/bin/secret-tool store --label="Correo $ADDR" service mail account "$ADDR"
  '';
in
{
  home.packages = [
    mail-digest
    mail-password
    pkgs.libsecret
  ];

  accounts.email.accounts = lib.listToAttrs (
    map (
      a:
      lib.nameValuePair a.name {
        inherit (a) address flavor primary;
        userName = a.address;
        realName = "Gustavo Cruz";
        passwordCommand = secretLookup a;
        imap = lib.mkIf (a.flavor == "plain") {
          inherit (a) host port;
          tls.enable = true;
        };
        smtp = lib.mkIf (a.flavor == "plain") {
          inherit (a) host;
          port = a.smtpPort;
          tls.enable = true;
        };
        folders =
          if a.flavor == "gmail.com" then
            { sent = null; }
          else
            {
              inbox = "INBOX";
              sent = "INBOX.Sent";
              drafts = "INBOX.Drafts";
              trash = "INBOX.Trash";
            };
        neomutt = {
          enable = true;
          mailboxType = "imap";
        };
      }
    ) accounts
  );

  programs.neomutt = {
    enable = true;
    package = pkgs.neomutt.override { withNotmuch = false; };
    vimKeys = true;
    sidebar.enable = true;
    sort = "reverse-date";
    settings = {
      imap_check_subscribed = "yes";
      imap_keepalive = "300";
      mail_check = "120";
      header_cache = "${config.xdg.cacheHome}/neomutt/headers";
      message_cachedir = "${config.xdg.cacheHome}/neomutt/bodies";
    };
  };
}
