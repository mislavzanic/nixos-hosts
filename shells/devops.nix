{
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  gcpPkgs = with pkgs; [(google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])];
in
  pkgs.mkShell {
    buildInputs = toolchains.devops ++ gcpPkgs;
    shellHook = ''
      export USE_GKE_GCLOUD_AUTH_PLUGIN=TRUE
      export PATH="$XDG_DATA_HOME/gem/ruby/2.7.0/bin:$PATH"
      export PATH="$DOTFILES/shells/aliases/work:$PATH"
      export PATH="/nix/store/2vy0rrggvmb1vxf4mrypvywrhdidc2v8-python3.10-json-schema-for-humans-0.41.0/bin:$PATH"
    '';
  }
