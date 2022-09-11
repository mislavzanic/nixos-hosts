{ config, lib, pkgs, ... }:
with lib;
with lib.my;
{
  networking = {
    hostName = "kreso";

    useNetworkd = true;
    useDHCP = false;
    firewall.enable = false;
  };

  systemd.network = {
    enable = true;
    links."10-eth0" = {
      matchConfig = {
        type = "ether";
        MACAddress = "b4:2e:99:f1:79:98";
      };
      linkConfig = {
        Name = "eth0";
        WakeOnLan = "magic";
      };
    };

    networks = {
      "5-lo" = {
        matchConfig.Name = "lo";
      };

      "10-eth0" = {
        matchConfig.Name = "eth0";
        networkConfig.DHCP = "ipv4";
        dhcpV4Config.ClientIdentifier = "mac";
      };
    };
  };
}
