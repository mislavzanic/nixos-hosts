{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my;
let
  system = "x86_64-linux";
in {

  imports = [inputs.home-manager.nixosModules.home-manager]
          ++ inputs.nix-modules.nixosModules
          ++ (mapModulesRec' (toString ./modules) import);

  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  i18n.defaultLocale = "en_US.UTF-8";
  environment.systemPackages = with pkgs; [ git vim ];

  dotfiles.dir = (findFirst pathExists (toString ./.) [
    "${config.user.home}/.config/.dotfiles"
  ]);

  nix = {
    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 30d";
    };

    settings = {
      auto-optimise-store = true;
    };

    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.stateVersion = "23.11";
}
