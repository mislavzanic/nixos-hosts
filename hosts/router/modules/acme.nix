{ config, lib, pkgs, ... }:
{
  users.groups.acme.members = [ "traefik" ];
  security.acme = {
    acceptTerms = true;
    defaults.email = "mislavzanic3@gmail.com";
    certs."wildcard" = {
      email = "mislavzanic3@gmail.com";
      dnsProvider = "cloudflare";
      domain = "*.mislavzanic.xyz";
      credentialsFile = config.age.secrets.dns-env.path;
    };
  };
}
