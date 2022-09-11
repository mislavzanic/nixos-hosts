let
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBuvOnQlLY/IafwhOXkM1N1ljAeT0c1AM50F9FKy6oHa mzanic@patak";
in {
  "wireguard-private.age".publicKeys = [key];
}
