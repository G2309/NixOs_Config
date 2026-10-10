{ config, lib, pkgs, ... }:
let
  connector = "DP-2";
  timezone = "America/Guatemala";
  minWriteGapMs = 300;

  schedule = {
    day = "06:00";
    night = "18:00";
  };

  limits = {
    brightness = {
      min = 0;
      max = 100;
      step = 5;
    };
    contrast = {
      min = 30;
      max = 100;
      step = 5;
    };
    sharpness = {
      min = 0;
      max = 100;
      step = 25;
    };
  };

  presetCodes = {
    "5000K" = "04";
    "6500K" = "05";
    "7500K" = "06";
    "9300K" = "08";
    user = "0b";
  };

  gammaCodes = {
    "1.8" = "50";
    "2.0" = "64";
    "2.2" = "78";
    "2.4" = "8c";
    "2.6" = "a0";
    "2.8" = "b4";
  };

  profiles = {
    day = {
      brightness = 70;
      contrast = 75;
      sharpness = 50;
      colorPreset = "6500K";
      gamma = "2.2";
    };
    night = {
      brightness = 25;
      contrast = 70;
      sharpness = 50;
      colorPreset = "user";
      gamma = "2.4";
      gains = {
        red = 100;
        green = 95;
        blue = 86;
      };
    };
  };

  profileValues = lib.mapAttrs (_: p: {
    inherit (p) brightness contrast sharpness;
    colorPreset = presetCodes.${p.colorPreset} or "";
    gamma = gammaCodes.${p.gamma} or "";
    gainRed = toString (p.gains.red or "");
    gainGreen = toString (p.gains.green or "");
    gainBlue = toString (p.gains.blue or "");
  }) profiles;

  invalidColor = lib.concatLists (
    lib.mapAttrsToList (
      pname: p:
      lib.optional (!(presetCodes ? ${p.colorPreset})) "${pname}.colorPreset = ${p.colorPreset} (permitido: ${lib.concatStringsSep ", " (lib.attrNames presetCodes)})"
      ++ lib.optional (!(gammaCodes ? ${p.gamma})) "${pname}.gamma = ${p.gamma} (permitido: ${lib.concatStringsSep ", " (lib.attrNames gammaCodes)})"
      ++ lib.optional (p ? gains && p.colorPreset != "user") "${pname}.gains solo aplica con colorPreset = \"user\""
      ++ lib.concatLists (
        lib.mapAttrsToList (
          c: v: lib.optional (v < 60 || v > 100) "${pname}.gains.${c} = ${toString v} (permitido: 60-100)"
        ) (p.gains or { })
      )
    ) profiles
  );

  caseLines =
    attrs:
    lib.concatStrings (
      lib.mapAttrsToList (
        name: values:
        lib.concatStrings (
          lib.mapAttrsToList (
            key: value: "    ${name}:${key}) echo ${lib.escapeShellArg (toString value)} ;;\n"
          ) values
        )
      ) attrs
    );

  invalidSettings = lib.concatLists (
    lib.mapAttrsToList (
      pname: p:
      lib.concatLists (
        lib.mapAttrsToList (
          feature: l:
          let
            v = p.${feature};
          in
          lib.optional (v < l.min || v > l.max || lib.mod v l.step != 0) "${pname}.${feature} = ${toString v} (permitido: ${toString l.min}-${toString l.max} en pasos de ${toString l.step})"
        ) limits
      )
    ) profiles
  );

  monitor-ctl = pkgs.writeShellApplication {
    name = "monitor-ctl";
    runtimeInputs = with pkgs; [
      ddcutil
      jq
      util-linux
      coreutils
      gawk
      gnused
    ];
    text = ''
      export TZ=${lib.escapeShellArg timezone}
      CONNECTOR=${lib.escapeShellArg connector}
      DAY_START=${lib.escapeShellArg schedule.day}
      NIGHT_START=${lib.escapeShellArg schedule.night}
      MIN_WRITE_GAP_MS=${toString minWriteGapMs}
      LIMITS_JSON=${lib.escapeShellArg (builtins.toJSON limits)}

      profile_get() {
        case "$1:$2" in
      ${caseLines profileValues}    *) echo "" ;;
        esac
      }

      limit_get() {
        case "$1:$2" in
      ${caseLines limits}    *) echo 1 ;;
        esac
      }

    ''
    + builtins.readFile ./monitor-ctl.sh;
  };
in
{
  assertions = [
    {
      assertion = invalidSettings ++ invalidColor == [ ];
      message = "monitor: valores fuera de lo que admite el monitor:\n  " + lib.concatStringsSep "\n  " (invalidSettings ++ invalidColor);
    }
  ];

  home.packages = [ monitor-ctl ];

  systemd.user.services.monitor-profile-auto = {
    Unit.Description = "Perfil del monitor segun la hora de Guatemala";
    Service = {
      Type = "oneshot";
      ExecStart = "${monitor-ctl}/bin/monitor-ctl auto";
    };
  };

  systemd.user.timers.monitor-profile-auto = {
    Unit.Description = "Cambio de perfil dia/noche del monitor";
    Timer = {
      OnCalendar = [
        "*-*-* ${schedule.day}:00 ${timezone}"
        "*-*-* ${schedule.night}:00 ${timezone}"
      ];
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  wayland.windowManager.sway.config.startup = [
    { command = "monitor-ctl auto"; }
  ];
}
