{
  description = "My NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master"; # for packages on the edge

    home-manager = {
      url = "github:rycee/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-utils = {
      url = "github:mislavzanic/nix-utils";
    };

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-config = {
      url = "github:mislavzanic/emacs-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-utils.follows = "nix-utils";
      inputs.emacs-overlay.follows = "emacs-overlay";
    };

    xmonad-config = {
      url = "github:mislavzanic/xmonad-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wallpapers = {
      url = "github:mislavzanic/wallpapers";
      flake = false;
    };

    nix-modules = {
      url = "github:mislavzanic/nix-modules";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-utils.follows = "nix-utils";
      inputs.home-manager.follows = "home-manager";
      inputs.emacs-overlay.follows = "emacs-overlay";
      inputs.emacs-config.follows = "emacs-config";
      inputs.xmonad-config.follows = "xmonad-config";
      inputs.wallpapers.follows = "wallpapers";
    };

    nix-direnv.url = "github:nix-community/nix-direnv";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix-direnv,
    nix-utils,
    nix-modules,
    ...
  }: let
    inherit (lib.my) mapModules mapModulesRec mapHosts mapShell;
    inherit (nix-utils) mkPkgs;

    system = "x86_64-linux";

    pkgs = mkPkgs {
      inherit system;
      pkgs = nixpkgs;
      overlays = [self.overlay] ++ nix-modules.overlays;
    };

    pkgs' = mkPkgs {
      inherit system;
      pkgs = nixpkgs-unstable;
      overlays = (lib.attrValues self.overlays);
    };

    lib = nixpkgs.lib.extend (nix-utils.mkLib {inherit pkgs inputs;});
  in {
    lib = lib.my;

    overlay = final: prev: {
      unstable = pkgs';
      my = self.packages."${system}";
    };

    packages."${system}" = mapModulesRec ./packages (p: pkgs.callPackage p {});

    nixosModules = ({dotfiles = import ./.;} // mapModulesRec ./modules import);

    nixosConfigurations = mapHosts ./hosts { defaults = ./.; };

    devShells."${system}" = mapShell ./shells {inherit pkgs lib;};

    devShell."${system}" =
      import ./shell.nix {inherit pkgs;};

    formatter."${system}" = pkgs.alejandra;
  };
}
