{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.desktop.services.xcompmgr;
in {
  options.modules.desktop.services.xcompmgr = {enable = mkBoolOpt false;};

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.xcompmgr];

    systemd.user.services.xcompmgr = {
      description = "XCompmgr Compositor";
      wantedBy = ["graphical-session.target"];
      after = ["graphical-session-pre.target"];
      partOf = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${pkgs.xcompmgr}/bin/xcompmgr";
        ExecStop = "pkill xcompmgr";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
