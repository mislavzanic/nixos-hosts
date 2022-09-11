{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  buildInputs = [
    pkgs.yaml-language-server
  ];
  shellHook = ''
    export FLAKE="$(pwd)"
    export PATH="$DOTFILES/shells/aliases/dots:$PATH"
  '';
}
