{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.sensible-defaults;
in {
  options.modules.sensible-defaults = {
    enable = mkBoolOpt true;
    useLatestKernel = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    environment.variables.DOTFILES = config.dotfiles.dir;
    environment.variables.DOTFILES_BIN = config.dotfiles.binDir;
    environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
    fileSystems."/".device = mkDefault "/dev/disk/by-label/nixos";

    boot = {
      kernelPackages = mkIf cfg.useLatestKernel pkgs.linuxPackages_latest;
      loader = {
        efi.canTouchEfiVariables = true;
        efi.efiSysMountPoint = "/boot";
        systemd-boot.configurationLimit = 10;
        systemd-boot.enable = mkDefault true;
      };
      supportedFilesystems = ["ntfs"];
    };
  };
}
