{
  config,
  lib,
  pkgs,
  options,
  my,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.services.wireguard;
in {
  options.modules.services.wireguard = {
    enable = mkBoolOpt false;
    port = mkOpt types.int 51820;
  };

  config = mkIf cfg.enable {
    networking.firewall = {
    logReversePathDrops = true;
    extraCommands = ''
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport ${toString cfg.port} -j RETURN
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport ${toString cfg.port} -j RETURN
    '';
    extraStopCommands = ''
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport ${toString cfg.port} -j RETURN || true
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport ${toString cfg.port} -j RETURN || true
    '';
    };
  };
}
