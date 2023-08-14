{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.desktop.lightdm;
  configDir = config.dotfiles.configDir;

in {
  options.modules.desktop.lightdm = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      xserver = {
        enable = true;
        displayManager = {
          lightdm.enable = true;
          lightdm.greeters.mini = {
            enable = true;
            user = config.user.name;
          };
        };
      };
    };
  };
}
