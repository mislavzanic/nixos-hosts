{
  pkgs,
  lib,
  config,
  ...
}:
with lib.my;
{
  imports = files ./modules;
  time.timeZone = "Europe/Zagreb";

  environment.systemPackages = with pkgs; [
    vim
    dig
    htop
    ethtool
    tcpdump
    conntrack-tools
  ];

  modules = {
    shell = {
      zsh.enable = true;
      direnv.enable = true;
      starship.enable = true;
      gnupg.enable = true;
      fzf.enable = true;
    };
    editor.vim.enable = true;
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

  services.logind = {
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  virtualisation.docker.enable = true;
  users.users.mzanic.extraGroups = ["docker"];

  nix = {
    settings = {
      trusted-users = ["mzanic" "root"];
    };
  };
}
