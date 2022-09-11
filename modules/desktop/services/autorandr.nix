{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.desktop.services.autorandr;
  configDir = config.dotfiles.configDir;
in {
  options.modules.desktop.services.autorandr = {enable = mkBoolOpt false;};

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [autorandr];

    home.configFile = {
      "autorandr" = {
        source = "${configDir}/autorandr";
        recursive = true;
      };
    };
  };
}
