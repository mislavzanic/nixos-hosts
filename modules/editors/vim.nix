{
  config,
  options,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.editor.vim;
  configDir = config.dotfiles.configDir;
in {
  options.modules.editor.vim = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      (neovim.override {
        vimAlias = true;
        configure.packages.myPlugins = with vimPlugins; {
          start = [vim-nix];
        };
      })
    ];

    environment.shellAliases = {
      v = "nvim";
      vim = "nvim";
    };
  };
}
