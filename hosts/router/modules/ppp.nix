{ config, pkgs, lib, ... }:
{
  age.secrets.chap-secrets.owner = lib.mkForce "root";
  environment.etc."ppp/chap-secrets".source = config.age.secrets.chap-secrets.path;
  services.pppd = {
    enable = true;
    peers = {
      ht = {
        autostart = true;
        enable = true;
        config = ''
          noipdefault
          defaultroute

          hide-password

          connect /bin/true
          noauth
          persist

          noaccomp
          default-asyncmap

          plugin pppoe.so
          vlan100

          user "zanicmis@htnet-dsl"

          nodetach
          persist
          debug
        '';
      };
    };
  };
}
