{
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my;
with pkgs; let
  pythonPkgs =
    toolchains.py
    ++ [
      pypy38
      python310Packages.z3
      python310Packages.numpy
      python310Packages.matplotlib
      python310Packages.pandas
      python310Packages.scipy
      python310Packages.sympy
      python310Packages.ipython
      python310Packages.termcolor
    ];
in
  mkShell {
    buildInputs = pythonPkgs;
    shellHook = ''
      export PATH="$DOTFILES/shells/aliases/aoc:$PATH"
      export PYTHONPATH="~/.local/dev/compprog/aoc:$PYTHONPATH"
    '';
  }
