{ config, lib, pkgs, ... }:
let
  wan = "eth0";
  wg0 = "wg0";
  lans = [ wan wg0 ];
  mkCSV = lib.concatMapStrings (ifi: "${ifi}, ");

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

      iifname { ${wan} } oifname { ${mkCSV lans} } jump forward_wan_trusted_lan
      iifname { ${mkCSV lans} } oifname { ${wan} } counter accept
      iifname { ${mkCSV lans} } oifname { ${mkCSV lans} } counter accept
    }

    chain forward_wan_trusted_lan {
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

      iifname { ${wan} } jump input_external
      iifname { ${mkCSV lans}, lo } counter accept
      iifname { ${wan} } drop
    }

    chain input_external {
      tcp dport {
        80, 443, 22
      } counter accept comment "router WAN TCP"

      udp dport {
        51820
      } counter accept comment "router WAN server UDP"

      counter reject
    }
  '';

  natTable = ''
    table ip nat {
      chain prerouting {
        type nat hook prerouting priority 0; policy accept;
        iifname { ${wan} } jump prerouting_wans
        accept
      }

      chain prerouting_wans {
        udp dport {
          53,
        } redirect to 51820 comment "router IPv4 WireGuard DNAT"

        accept
      }

      chain postrouting {
        type nat hook postrouting priority 0; policy accept;
        oifname { wg0, ${wan} } masquerade
      }
    }
  '';

  debug = ''
    chain input {
      type filter hook input priority 0; policy accept;
      accept
    }
    chain output {
      type filter hook output priority 100; policy accept;
      accept
    }
    chain forward {
      type filter hook forward priority 0; policy accept;
      accept
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
