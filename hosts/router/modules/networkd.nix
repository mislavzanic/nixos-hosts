{ config, lib, pkgs, ... }:
with config.router;
with config.router.interfaces;
with lib;
with lib.my;
let
  ethLink = (iface: {
    matchConfig = {
      type = "ether";
      MACAddress = iface.mac;
    };
    linkConfig.Name = iface.name;
  });

  bridgedNet = (iface: {
    matchConfig.Name = iface.name;
    networkConfig = {
      Bridge = iface.bridge;
      LinkLocalAddressing = "no";
    };
    dhcpServerConfig = {
      EmitDNS = true;
      DNS = ["_server_address"];
      DefaultLeaseTimeSec = 86400;
      MaxLeaseTimeSec = 86400;
      PoolOffset = 50;
    };
    linkConfig.RequiredForOnline = "no";
  });
in
{
  age.secrets.client-private-key.owner = lib.mkForce "systemd-network";

  services.resolved = {
    enable = true;
    # domains = [ domain ];
    fallbackDns = [ "8.8.8.8" "1.1.1.1" ];
    extraConfig = ''
      DNS=::1 127.0.0.1 1.1.1.1
      DNSStubListener=no
    '';
  };

  systemd.network = {
    enable = true;
    links = {
      "10-wan0" = ethLink wan0;
      "15-eth1" = ethLink eth1;
      "20-eth2" = ethLink eth2;
      "25-wlan0" = ethLink wlan0;
    };

    netdevs = {
      "00-vlan100" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan100";
        };
        vlanConfig.Id = 100;
      };
      "20-br0" = {
        netdevConfig = {
          Kind = "bridge";
          Name = br0.name;
          MACAddress = br0.mac;
        };
      };
    };

    networks = {
      "5-lo" = {
        matchConfig.Name = "lo";
      };

      "10-vlan100" = {
        matchConfig.Name = "vlan100";
      };

      "10-wan0" = {
        matchConfig.Name = wan0.name;
        vlan = [ "vlan100" ];
      };

      "20-eth1" = bridgedNet eth1;
      "20-eth2" = bridgedNet eth2;

      "20-wlan0" = {
        matchConfig.Name = wlan0.name;
        address = ["10.10.1.1/24"];
        networkConfig = {
          DHCPServer = true;
        };
        dhcpServerConfig = {
          EmitDNS = true;
          DNS = ["_server_address"];
          DefaultLeaseTimeSec = 86400;
          MaxLeaseTimeSec = 86400;
          PoolOffset = 50;
        };
        linkConfig.RequiredForOnline = "no";
      }; 

      "40-br0" = {
        matchConfig.Name = br0.name;
        address = ["10.1.1.1/24"];
        networkConfig = {
          DHCPServer = true;
        };
        dhcpServerStaticLeases = lib.forEach (filterAttrList config.router.hosts (host: host.mac != "")) (host: {
          dhcpServerStaticLeaseConfig = {
            Address = host.ipv4;
            MACAddress = host.mac;
          };
        });
        dhcpServerConfig = {
          EmitDNS = true;
          DNS = ["_server_address"];
          DefaultLeaseTimeSec = 86400;
          MaxLeaseTimeSec = 86400;
          PoolOffset = 50;
        };
      };
    };
  };
}
