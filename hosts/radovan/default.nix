{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib.my) files;
  configDir = config.dotfiles.configDir;
in {
  imports = files ./modules;

  networking.extraHosts = ''
    5.161.195.126 patak
  '';

  boot = {
    cleanTmpDir = true;
    loader = {
      grub = {
        enable = true;
        version = 2;
      };
    };
  };

  zramSwap.enable = true;
  
  modules = {
    sensible-defaults.enable = false;
    shell = {
      zsh.enable = true;
      starship.enable = true;
      fzf.enable = true;
    };
  };

  services.openssh.enable = true;
  users.users = {
    root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmEl/rONf7u/HV/dl/STC3Pyf9WacsS5+JLMM5AmyB1 mzanic"
    ];

    mzanic.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmEl/rONf7u/HV/dl/STC3Pyf9WacsS5+JLMM5AmyB1 mzanic"
    ];
  };

  virtualisation.docker.enable = true;
  users.users.mzanic.extraGroups = ["docker"];
}
