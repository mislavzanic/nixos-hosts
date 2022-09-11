{
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my;
  pkgs.mkShell {
    buildInputs = toolchains.cc;
  }
