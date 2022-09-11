{ config, lib, pkgs, ... }:
with config.router;
with lib;
let
  interface = interfaces.wlan0.name;
in {
  services.udev.packages = [ pkgs.crda ];
  environment.etc."default/crda".text = ''
    REGDOMAIN=HR
  '';

  services.hostapd = {
    inherit interface;
    enable = true;
    channel = 36;
    hwMode = "a";
    countryCode = "HR";
    wpaPassphrase = builtins.readFile "${config.age.secrets.private-net-pass.path}";
    extraConfig = ''
      ssid=guest
      wmm_enabled=1
      auth_algs=1
      wpa_key_mgmt=WPA-PSK
      wpa_psk_file=/etc/hostapd.psk
      ctrl_interface=/run/hostapd
      ht_capab=[HT40+][SHORT-GI-40][TX-STBC][RX-STBC1][DSSS_CCK-40]
    '';
  };

  systemd.services.hostapd.before = ["network.target" "systemd-networkd.service"];

  nixpkgs.overlays = [
    (self: super: {
      hostapd = super.hostapd.overrideAttrs (old: rec {
        extraConfig = ''
          ${old.extraConfig}
          CONFIG_DRIVER_NL80211=y
          CONFIG_WPS=y
          CONFIG_WPS_UPNP=y
        '';
        version = "2.10";
        src = (builtins.fetchGit {
          url = "http://w1.fi/hostap.git";
          ref = "main";
          rev = "72d4ca2fca983adbec82b0ef64dfcc2c9b971f5e";
        });
      });
    })
  ];

}
