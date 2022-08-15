#!/usr/bin/env bash

# Script archlinux install
# Franklin Souza
# @FranklinTech

# Formatação de discos
format_disk(){
  clear
  echo -e "[!] - Formatando os discos\n"
  sleep 2
  mkfs.vfat -F32 /dev/sda1
  mkfs.btrfs -f /dev/sda2
}

# Criação de subvolumes
subvolumes(){
  clear
  echo -e "[!] - Criando subvolumes em btrfs\n"
  sleep 2
  mount /dev/sda2 /mnt
  btrfs su cr /mnt/@
  btrfs su cr /mnt/@home
  btrfs su cr /mnt/@var
  btrfs su cr /mnt/@snapshots
  chattr +C /mnt/@var
  umount /mnt
}

# Montando as partições
mount_partitions(){
  clear
  echo -e "[!] - Montando as partições\n"
  sleep 2
  mount -o defaults,compress=zstd,nossd,autodefrag,subvol=@ /dev/sda2 /mnt
  mkdir -p /mnt/boot/efi
  mkdir /mnt/home
  mkdir /mnt/var
  mkdir /mnt/.snapshots
  mount -o defaults,compress=zstd,nossd,autodefrag,subvol=@home /dev/sda2 /mnt/home
  mount -o defaults,compress=zstd,nossd,autodefrag,subvol=@var /dev/sda2 /mnt/var
  mount -o defaults,compress=zstd,nossd,autodefrag,subvol=@snapshots /dev/sda2 /mnt/.snapshots
  mount /dev/sda1 /mnt/boot/efi
}

# Instalando pacotes base do Arch Linux
pacstrap_arch(){
  clear
  echo -e "[!] - Instalando os pacotes base do Arch Linux\n"
  sleep 2
  pacstrap /mnt base dhcpcd neovim linux-firmware base-devel
  pacman -Sy archlinux-keyring --noconfirm
  pacstrap /mnt base dhcpcd neovim linux-firmware base-devel
}

# Gerando o fstab
fstab_gen(){
  clear
  echo -e "[!] - Gerando o Fstab\n"
  sleep 2
  genfstab /mnt >> /mnt/etc/fstab
}

# Entrando no chroot
arch_chroot_enter(){
  clear && echo -e "[!] - ENTRE NO CHROOT DIGITANDO: arch-chroot /mnt"
  sleep 2
}

format_disk
subvolumes
mount_partitions
pacstrap_arch
fstab_gen
arch_chroot_enter
