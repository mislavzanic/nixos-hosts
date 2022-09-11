{ lib, ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [ "8.8.8.8" ];
    defaultGateway = "172.31.1.1";
    hostName = "patak";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="5.161.195.126"; prefixLength=32; }
        ];
        ipv6.addresses = [
          { address="2a01:4ff:f0:49cf::1"; prefixLength=64; }
          { address="fe80::9400:2ff:fe28:5d7b"; prefixLength=64; }
        ];
        ipv4.routes = [ { address = "172.31.1.1"; prefixLength = 32; } ];
        ipv6.routes = [ { address = "fe80::1"; prefixLength = 128; } ];
      };

    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="96:00:02:28:5d:7b", NAME="eth0"
  '';
}
