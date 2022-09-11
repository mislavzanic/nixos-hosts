{ config, lib, pkgs, ... }:

{
  systemd = {
    services.dyndns = {
      description = "Update IP in DNS records";
      path = with pkgs; [ curl dig ];
      script = ''
        IP="$(dig +short myip.opendns.com @resolver1.opendns.com)"
        [[ -f /tmp/dyndns-lastip ]] && LASTIP=$(</tmp/dyndns-lastip)
        if [[ "$IP" != "$LASTIP" ]]; then
          echo "$IP">/tmp/dyndns-lastip
          curl -X PUT \
               -H "Authorization: Bearer $CLOUDFLARE_DNS_API_TOKEN" \
               -H "Content-Type: application/json" \
               -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
               --data "{\"type\":\"A\",\"name\":\"$RECORD\",\"content\":\"$IP\"}" \
               https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records/$DOMAINID
               
          echo "Updated DNS: $LASTIP -> $IP"
        else
          echo "No change ($IP)"
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile = config.age.secrets.dns-env.path;
      };
    };
    timers.dyndns = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        Unit = "dyndns.service";
        OnCalendar = "*:0/5";
      };
    };
  };
}
