{ config, pkgs, lib, ... }:
with lib.my;
{
  imports = files ./modules;
  router = builtins.fromJSON (builtins.readFile ./vars.json);

  environment.systemPackages = with pkgs; [
    iw
    vim
    dig
    ppp
    htop
    ethtool
    tcpdump
    conntrack-tools
    wireguard-tools
  ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda"; 
      extraConfig = ''
        serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
        terminal_input serial
        terminal_output serial
      '';
    };
    kernelParams = [
     "console=ttyS0,115200n8"
     "console=tty1"
    ];
  };

  modules = {
    sensible-defaults = {
      enable = false;
      useLatestKernel = false;
    };

    shell = {
      zsh.enable = true;
      starship.enable = true;
      fzf.enable = true;
    };
  };

  time.timeZone = "Europe/Zagreb";

  services.openssh.enable = true;
  
  users.users = {
    root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmEl/rONf7u/HV/dl/STC3Pyf9WacsS5+JLMM5AmyB1 mzanic"
    ];

    mzanic.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmEl/rONf7u/HV/dl/STC3Pyf9WacsS5+JLMM5AmyB1 mzanic"
    ];
  };

  system.stateVersion = "23.05";
}

