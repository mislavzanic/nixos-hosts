{
  config,
  options,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.desktop;
in {
  config = mkIf config.services.xserver.enable {
    assertions = [
      {
        assertion = (countAttrs (n: v: n == "enable" && value) cfg) < 2;
        message = "Can't have more than one desktop environment enabled at a time";
      }
      {
        assertion = let
          srv = config.services;
        in
          srv.xserver.enable
          || srv.sway.enable
          || !(anyAttrs
            (n: v:
              isAttrs v
              && anyAttrs (n: v: isAttrs v && v.enable))
            cfg);
        message = "Can't enable a desktop app without a desktop environment";
      }
    ];

    user.packages = with pkgs; [
      feh
      xclip
      xdotool
      xorg.xwininfo
      htop
      sxiv
      xorg.xset
      xorg.xmodmap
      lxappearance
      xclip
    ];

    fonts = {
      fontDir.enable = true;
      fontconfig.enable = true;
      enableGhostscriptFonts = true;
      fonts = with pkgs; [
        nerdfonts
        cantarell-fonts
        noto-fonts-emoji
        source-sans-pro
        source-serif-pro
      ];
    };

    services.picom = {
      opacityRules = [
        "100:class_g = 'Firefox'"
        # Art/image programs where we need fidelity
        "100:class_g = 'feh'"
        "100:class_g = 'mpv'"
        "100:class_g = 'zathura'"
        "100:class_g = 'brave'"
        "100:_NET_WM_STATE@:32a = '_NET_WM_STATE_FULLSCREEN'"
        "100:class_g = 'xmobar'"
        "100:class_g = 'xmonad'"
        "100:class_g = 'xmonad'"
      ];
    };
  };
}
