{
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my;
  pkgs.mkShell {
    buildInputs = with pkgs; [
      ghc
      cabal2nix
      haskellPackages.haskell-language-server
      cabal-install
      hlint
    ];
  }
