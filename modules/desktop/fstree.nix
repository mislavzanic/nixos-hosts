{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.desktop.fstree;
  configDir = config.dotfiles.configDir;

in {
  options.modules.desktop.fstree = {
    dev = {
      create = mkBoolOpt false;
    };
    devops = {
      create = mkBoolOpt false;
    };
    notes = {
      create = mkBoolOpt false;
      git = mkOpt types.str "ssh://git@github.com/mislavzanic/notes.git";
    };
  };

  config = {
    system.userActivationScripts = {
      addDirs = mkIf cfg.dev.create ''
        if [ ! -d  "$HOME/.local/dev" ]; then
          mkdir -p "$HOME/.local/dev"
          mkdir -p "$HOME/.local/dev/compprog"
          mkdir -p "$HOME/.local/dev/nix-tinkering"
        fi
      '';

      getNotes = mkIf cfg.notes.create ''
        if [ -d /home/${config.user.name}/.ssh ] || [ -d /etc/.ssh ]; then
            export PATH="/home/${config.user.name}/.ssh:$PATH"
            export PATH="${pkgs.openssh}/bin"
            if [ ! -d  "$HOME/.local/notes" ]; then
                ${pkgs.git}/bin/git clone "${cfg.notes.git}" "$HOME/.local/notes"
            fi
        fi
      '';

      devopsDirs = mkIf cfg.devops.create ''
        if [ ! -d  "$HOME/.local/work" ]; then
          mkdir -p "$HOME/.local/work/repos/argoCD"
          mkdir -p "$HOME/.local/work/repos/tf"
        fi
      '';
    };

    home = mkIf cfg.devops.create {
      file.".local/work/.envrc".text = ''
        use flake $FLAKE#devops
      '';
    };
  };
}
