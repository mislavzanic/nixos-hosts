{ config, lib, pkgs, ... }:
with config.router;
with config.router.interfaces;
# https://unix.stackexchange.com/questions/721816/linux-router-with-traffic-forwarding-over-a-wireguard-tunnel
let
  endpoint = wireguard.client.ipv4;
  wg-up = pkgs.writeShellScriptBin "wg-up" ''
    sudo ${pkgs.iproute2}/bin/ip route del default
    sudo ${pkgs.iproute2}/bin/ip route add default dev ${wg0.name}
    sudo ${pkgs.iproute2}/bin/ip route add ${endpoint}/32 via 0.0.0.0 dev ppp0
  '';
  wg-down = pkgs.writeShellScriptBin "wg-down" ''
    sudo ${pkgs.iproute2}/bin/ip route del ${endpoint}/32 via 0.0.0.0 dev ppp0
    sudo ${pkgs.iproute2}/bin/ip route del default dev ${wg0.name}
    sudo ${pkgs.iproute2}/bin/ip route add default dev ppp0
  '';
in {
  environment.systemPackages = [ wg-up wg-down ];
  age.secrets.server-private-key.owner = lib.mkForce "systemd-network";

  systemd.network = {
    netdevs."10-${wg0.name}" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "${wg0.name}";
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets.server-private-key.path;
        ListenPort = ports.wireguard;
      };
      wireguardPeers = map (peer: { wireguardPeerConfig = peer; }) wireguard.peers;
    };

    networks."40-${wg0.name}" = {
      matchConfig.Name = "${wg0.name}";
      address = [ "10.100.1.1/24" ];
      routes = [
        {
          routeConfig = {
            Destination = "10.100.1.20/24";
          };
        }
      ];
      linkConfig.RequiredForOnline = "routable";
    };
  };
}
