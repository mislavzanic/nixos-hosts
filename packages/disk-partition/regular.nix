{ lib, pkgs ? import <nixpkgs> {}, ... }:
let
  disk-name = builtins.getEnv "DISK";
  disk = if lib.elem disk-name [""] then "/dev/sda" else disk-name;
  createPartitions = ''
    parted -s "${disk}" mklabel gpt
    parted -s "${disk}" mkpart ESP fat32 1MiB 512MiB
    parted -s "${disk}" mkpart primary 512MiB -4GiB
    parted -s "${disk}" mkpart primary linux-swap -4GiB 100%
    parted -s "${disk}" set 1 esp on
    mkfs.fat -F32 -n BOOT "${disk}1"
    mkfs.ext4 -L nixos "${disk}2"
    mkswap -L swap "${disk}3"
  '';

  mountPartitions = ''
    mount /dev/disk/by-label/nixos /mnt
    mkdir -p /mnt/{home,boot,usr/store}
    mount /dev/disk/by-label/boot /mnt/boot
    swapon /dev/disk/by-label/swap
  '';
in pkgs.writeShellApplication {
  name = "partition-disk";
  runtimeInputs = with pkgs; [ parted ];
  text = lib.strings.concatStringsSep "\n" [createPartitions mountPartitions];
}
