{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.desktop.xmonad;
  configDir = config.dotfiles.configDir;

in {
  options.modules.desktop.xmonad = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      networkmanagerapplet
      maim
      pamixer
      pavucontrol
      pasystray
      git
      mpv
      wget
      brave
      firefox
      gnumake
      lxappearance
    ];

    sound.enable = true;
    hardware.pulseaudio.enable = true;

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
