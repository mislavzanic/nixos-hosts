{
  lib,
  pkgs,
  ...
}:
with pkgs;
  mkShell {
    name = "example-env";
    buildInputs = [
      python39
      python39Packages.venvShellHook
      autoPatchelfHook
    ];
    venvDir = "./venv";
    postVenvCreation = ''
      pip install -U pip setuptools wheel
      pip install -r requirements.txt
      pip install -e .
      autoPatchelf ./venv
    '';
  }
