{ lib, pkgs, ... }:
let
  disk-name = builtins.getEnv "DISK";
  disk = if lib.elem disk-name [""] then "/dev/sda" else disk-name;
  createPartitions = ''
    parted -s "${disk}" mklabel gpt
    parted -s "${disk}" mkpart ESP fat32 1MiB 500MiB
    parted -s "${disk}" mkpart primary 500MiB 100%
    parted -s "${disk}" set 1 esp on
  '';

  formatPartitions = ''
    mkfs.vfat "${disk}1"
    cryptsetup -q luksFormat "${disk}2" --type luks2
    cryptsetup open --type luks "${disk}2" encrypted_root
    pvcreate /dev/mapper/encrypted_root
    vgcreate encrypted_root_pool /dev/mapper/encrypted_root
    lvcreate -L 8G -n swap encrypted_root_pool
    mkswap -L swap /dev/mapper/encrypted_root_pool-swap
    lvcreate -l 100%FREE -n nixos encrypted_root_pool
    mkfs.ext4 -L nixos /dev/mapper/encrypted_root_pool-nixos
  '';

  mountPartitions = ''
    mount /dev/mapper/encrypted_root_pool-nixos /mnt
    mkdir /mnt/boot
    mount "${disk}1" /mnt/boot
  '';
in pkgs.writeShellApplication {
  name = "partition-encrypt-disk";
  runtimeInputs = with pkgs; [ parted cryptsetup lvm2 ];
  text = lib.strings.concatStringsSep "\n" [createPartitions formatPartitions mountPartitions];
}
