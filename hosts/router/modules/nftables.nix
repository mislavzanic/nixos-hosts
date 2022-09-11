{ config, lib, pkgs, ... }:
with config.router;
with config.router.interfaces;
let
  trustedLans = with config.router.interfaces; [ br0 wg0 ];
  otherLans = with config.router.interfaces; [ wlan0 ];
  wans = with config.router.interfaces; [ ppp0 ];
  outbound = with config.router.interfaces; [ wg0 ppp0 ];
  mkCSV = lib.concatMapStrings (ifi: "${ifi.name}, ");

  icmpRules = ''
    ip6 nexthdr icmpv6 icmpv6 type {
      echo-request,
      destination-unreachable,
      packet-too-big,
      time-exceeded,
      parameter-problem,
      nd-neighbor-solicit,
      nd-neighbor-advert,
    } counter accept

    ip protocol icmp icmp type {
      echo-request,
      destination-unreachable,
      time-exceeded,
      parameter-problem,
    } counter accept
  '';

  forwardChain = ''
    chain forward {
      type filter hook forward priority 0; policy drop;
      ${icmpRules}

      iifname { ${mkCSV wans} } oifname { ${mkCSV trustedLans} } jump forward_wan_trusted_lan
      iifname { ${mkCSV wans} } oifname { ${mkCSV otherLans} } jump forward_wan_untrusted_lan
      iifname { ${mkCSV trustedLans} ${mkCSV otherLans} } oifname { ${mkCSV wans} } counter accept
      iifname { ${mkCSV trustedLans} } oifname { ${mkCSV trustedLans} ${mkCSV otherLans} } counter accept

      oifname { ${mkCSV wans} } tcp flags syn tcp option maxseg size set 1452
    }

    chain forward_wan_trusted_lan {
      ct state {established, related} counter accept
      ct state invalid counter drop
      counter reject
    }

    chain forward_wan_untrusted_lan {
      ct state {established, related} counter accept
      ct state invalid counter drop
      counter reject
    }
  '';

  outputChain = ''
    chain output {
      type filter hook output priority 100; policy accept;
      counter accept
    }
  '';

  inputChain = ''
    chain input {
      type filter hook input priority 0; policy drop;

      ct state { established, related } counter accept
      ct state invalid counter drop

      # Drop the traffic coming from these subnets.
      ip saddr {
        49.64.0.0/11,
        218.92.0.0/16,
        222.184.0.0/13,
      } counter drop comment "malicious subnets"

      ${icmpRules}

      iifname { ${mkCSV wans} } jump input_external
      iifname { ${mkCSV trustedLans}, lo } counter accept
      iifname { ${mkCSV otherLans} } jump input_untrusted
      iifname { ${mkCSV wans} } drop
    }

    chain input_external {
      tcp dport {
        ${ports.http},
        ${ports.https},
        ${ports.ssh},
      } counter accept comment "router WAN TCP"

      udp dport {
        ${ports.wireguard}
      } counter accept comment "router WAN server UDP"

      counter reject
    }

    chain input_untrusted {
      udp dport ${ports.dhcpServer} udp sport ${ports.dhcpClient} counter accept

      iifname ${wlan0.name} ip daddr != ${wlan0.ipv4} counter drop

      tcp dport {
        ${ports.dns},
      } counter accept comment "router untrusted TCP"

      udp dport {
        ${ports.dns},
      } counter accept comment "router untrusted UDP"

      counter drop
    }
  '';

  natTable = ''
    table ip nat {
      chain prerouting {
        type nat hook prerouting priority 0; policy accept;
        iifname { ${mkCSV wans} } jump prerouting_wans
        accept
      }

      chain prerouting_wans {
        udp dport {
          ${ports.dns},
        } redirect to ${ports.wireguard} comment "router IPv4 WireGuard DNAT"

        accept
      }

      chain postrouting {
        type nat hook postrouting priority 0; policy accept;
        oifname { ${mkCSV outbound} } masquerade
      }
    }
  '';
in
{
  networking.nftables = {
    enable = true;
    ruleset = ''
      table inet filter {
        ${inputChain}
        ${forwardChain}
        ${outputChain}
      }

      ${natTable}
    '';
  };
}
