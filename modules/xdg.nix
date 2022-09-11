{
  config,
  home-manager,
  ...
}: {
  home-manager.users.${config.user.name}.xdg.enable = true;

  environment = {
    sessionVariables = {
      "PATH" = "$PATH:$HOME/.config/.dotfiles/bin";
      "FLAKE" = "$HOME/.config/.dotfiles/";
    };

    variables = {
      "HISTFILE" = "$XDG_DATA_HOME/zsh/history";
      "INPUTRC" = "$XDG_CONFIG_HOME/readline/inputrc";
      "LESSHISTFILE" = "$XDG_CACHE_HOME/lesshst";
      "WGETRC" = "$XDG_CONFIG_HOME/wgetrc";
      "EDITOR" = "nvim";
      "ZDOTDIR" = "$XDG_CONFIG_HOME/zsh";
    };
  };
}
