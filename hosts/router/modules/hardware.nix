{ config, lib, pkgs, modulesPath, ... }:
with config.router.interfaces;
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "ehci_pci" "usb_storage" "sd_mod" "sdhci_pci" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    kernel.sysctl = {
      # https://en.wikipedia.org/wiki/SYN_cookies
      "net.ipv4.tcp_syncookies" = true;

      # Enable IPv4 forwarding
      "net.ipv4.conf.all.forwarding" = true;
      
      "net.ipv4.ip_forward" = true;

      # Enable reverse path filtering
      "net.ipv4.conf.all.rp_filter" = true;
      "net.ipv4.conf.default.rp_filter" = true;

      # Disable ICMP redirects (prevent MITM attacks)
      "net.ipv4.conf.all.accept_redirects" = 0;

      # Log strange (martian) non-conformant packets
      "net.ipv4.conf.all.log_martians" = true;

      # Enable IPv6 forwarding
      "net.ipv6.conf.all.forwarding" = true;

      # By default, not automatically configure any IPv6 addresses.
      "net.ipv6.conf.all.accept_ra" = 0;
      "net.ipv6.conf.all.autoconf" = 0;
      "net.ipv6.conf.all.use_tempaddr" = 0;

      # Do not accept ICMP redirects (prevent MITM attacks)
      "net.ipv6.conf.all.accept_redirects" = 0;

      # On WAN, allow IPv6 autoconfiguration and tempory address use.
      "net.ipv6.conf.${wan0.name}.accept_ra" = 2;
      "net.ipv6.conf.${wan0.name}.autoconf" = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  networking = {
    hostName = "router";
    # wireless.athUserRegulatoryDomain = true;
    useDHCP = false;
    useNetworkd = true;
    firewall.enable = false;
    nat.enable = false;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # hardware.wirelessRegulatoryDatabase = true;
}
