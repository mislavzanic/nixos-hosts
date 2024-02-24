{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  configDir = config.dotfiles.configDir;
  user = "mzanic";
in {
  imports = (lib.my.files ./modules);
  time.timeZone = "Europe/Zagreb";

  networking = {
    hostName = "ilija";
    useDHCP = false;
    networkmanager.enable = true;
  };

  modules = {
    apps = {
      alacritty.enable = true;
      emacs.enable = true;
    };

    desktop = {
      wm = {
        enable = true;
        picom.enable = true;
      };
      lightdm.enable = true;
      fstree = {
        dev.create = true;
        devops.create = false; 
        notes.create = true;
      };
    };

    sensible-defaults = {
      useLatestKernel = true;
    };

    shell = {
      zsh.enable = true;
      direnv.enable = true;
      starship.enable = true;
      pass = {
        enable = true;
        git = "git@github.com:mislavzanic/pass.git";
      };
      gnupg.enable = true;
      fzf.enable = true;
    };

    services.wireguard.enable = true;

    theme = {
      active = "true";
      wallpapers = {
        wallpaper = "0004.jpg";
      };
    };
  };

  programs.dconf.enable = true;

  services = {
    logind = {
      lidSwitch = "suspend";
      lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "suspend";
    };
    blueman.enable = true;
    dbus.packages = with pkgs; [dconf];
    fwupd.enable = true;
    xserver = {
      enable = true;
      libinput = {
        enable = true;
        touchpad = {
          naturalScrolling = false;
          middleEmulation = true;
          tapping = true;
        };
      };
    };
  };

  services.transmission.enable = true;
  services.transmission.settings = {
    incomplete-dir = "${config.user.home}/.local/torrents";
    download-dir = "${config.user.home}/.local/torrents";
  };

  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;
  sound.enable = true;

  user.packages = with pkgs; [
    brightnessctl
    spotify
    zathura
    autorandr
    vim
  ];

  environment.systemPackages = with pkgs; [gnumake];

  boot.extraModprobeConfig = ''
    options rtw89_pci disable_aspm_l1=y disable_aspm_l1ss=y disable_clkreq=y
    options rtw89pci  disable_aspm_l1=y disable_aspm_l1ss=y disable_clkreq=y
  '';

  environment.sessionVariables = rec {
    WINIT_X11_SCALE_FACTOR = "1.66";
  };

  virtualisation.docker.enable = true;
  users.users.mzanic.extraGroups = ["docker" "transmission"];
}
