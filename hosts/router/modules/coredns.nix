{ config, lib, pkgs, ... }:
let
  blocklist = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts";
    sha256 = "sha256:134dc114cpwy88r4k8mxafgkigm91pwg89hhsq4c71jvnci7kryj";
  };
  domain = config.router.domain;
  hosts = with config.router.hosts; infra ++ servers ++ external;
in
{
  environment.etc."coredns/blocklist.hosts".source = blocklist;

  services.coredns = {
    enable = true;
    config = ''
      . {
        hosts /etc/coredns/blocklist.hosts {
          fallthrough
        }
        forward . tls://8.8.8.8 tls://8.8.4.4 {
          tls_servername dns.google
          health_check 5s
        }
        cache 3600 {
          success 8192
          denial 4096
        }
      }
      ${domain} {
        hosts {
          ${lib.concatMapStrings (host: ''
            ${host.ipv4} ${host.name}.${domain}
          '') (hosts ++ config.router.records)}
          fallthrough
        }
        forward . tls://8.8.8.8 tls://8.8.4.4 {
          tls_servername dns.google
          health_check 5s
        }
      }
    '';
  };
}
