{ inputs, config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ wireguard-tools screen tcpdump ];

  # networking.nat.enable = true;
  # networking.nat.externalInterface = "eth0";
  # networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall.enable = false;
  age.secrets.wireguard-private.owner = lib.mkForce "systemd-network";
  systemd.network = {
    enable = true;
    netdevs."10-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets.wireguard-private.path;
        ListenPort = 51820;
      };
      wireguardPeers = [
        {
          wireguardPeerConfig = {
            PublicKey = "/d8G26pzckYjABWf0H72rL+F9zjfm0DOTcRIBN8ndGs=";
            AllowedIPs = [ "10.100.1.20/32" ];
          };
        }
        {
          wireguardPeerConfig = {
            PublicKey = "0QsQ4TDktcsFOcyeplcJwRmKuquMVbnhWK1+6A9ibTM=";
            AllowedIPs = [ "10.100.1.1/32" ];
          };
        }
      ];
    };

    networks."40-wg0" = {
      matchConfig.Name = "wg0";
      address = [ "10.100.0.1/24" ];
      routes = [
        {
          routeConfig = {
            Destination = "10.100.1.20";
          };
        }
        {
          routeConfig = {
            Destination = "10.100.1.1";
          };
        }
      ];
    # make the routes on this interface a dependency for network-online.target
      linkConfig.RequiredForOnline = "routable";
    };
  };
}
