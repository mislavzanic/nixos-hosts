let
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmEl/rONf7u/HV/dl/STC3Pyf9WacsS5+JLMM5AmyB1 mzanic";
in {
  "private-net-pass.age".publicKeys = [key];
  "private-key.age".publicKeys = [key];
  "client-private-key.age".publicKeys = [key];
  "server-private-key.age".publicKeys = [key];
  "dns-env.age".publicKeys = [key];
  "chap-secrets.age".publicKeys = [key];
}
