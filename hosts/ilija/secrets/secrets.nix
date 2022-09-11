let
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmEl/rONf7u/HV/dl/STC3Pyf9WacsS5+JLMM5AmyB1 mzanic";
in {
  "wireguard-private.age".publicKeys = [key];
  "wireguard-public.age".publicKeys = [key];
  "private-net-pass.age".publicKeys = [key];
}
