{
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my;
  pkgs.mkShell {
    buildInputs = toolchains.golang;
    shellHook = ''
      export XDG_DATA_HOME="/home/mzanic/.local/share"
      export GO111MODULE=on
      export GOPATH=$XDG_DATA_HOME/go
      export PATH=$GOPATH/bin:$PATH
    '';
  }
