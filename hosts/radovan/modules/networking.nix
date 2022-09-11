{ lib, ... }:
{
  networking = {
    hostName = "radovan";
    domain = "";

    nameservers = ["8.8.8.8"];
    defaultGateway = "172.31.1.1";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="91.107.208.213"; prefixLength=32; }
        ];
        ipv6.addresses = [
          { address="2a01:4f8:c17:d581::1"; prefixLength=64; }
          { address="fe80::9400:2ff:fe12:e239"; prefixLength=64; }
        ];
        ipv4.routes = [ { address = "172.31.1.1"; prefixLength = 32; } ];
        ipv6.routes = [ { address = "fe80::1"; prefixLength = 128; } ];
      };

    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="96:00:02:12:e2:39", NAME="eth0"
  '';
}
