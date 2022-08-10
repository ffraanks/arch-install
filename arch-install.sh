#!/usr/bin/env bash

# Script archlinux install
# Franklin Souza
# @FranklinTech

main(){
  clear
  cat << Warning
  AVISO: Esse script foi criado/desenvolvido para minha própria instalação tudo aqui foi pensando EM MIM, caso você venha a usa-lo, por favor sinta-se livre em abri-lo e ler o código fonte, NÃO ME RESPOSABILIZO POR DANOS, caso queira instalar o Arch Linux, recomendo a documentção oficial: https://wiki.archlinux.org/title/Installation_guide_(Portugu%C3%AAs)
  Eu utilizo o Filesystem BTRFS minha montagem é simples:

  dev/sda1 - EFI - BOOT
  dev/sda2 - / (BTRFS)
Warning
}
printf "\n\n" && read -p 'PRESSIONE ENTER PARA CONTINUAR...'

font_system(){
  clear
  echo -e "[!] - Aumentando o tamanho da fonte do sistema\n"
  sleep 2
  setfont lat4-19
}

format_disk(){
  clear
  echo -e "[!] - Formatando os dicos\n"
  sleep 2
  mkfs.vfat -F32 /dev/sda1
  mkfs.btrfs -f /dev/sda2
}

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

mount_partitions(){
  clear
  echo -e "[!] - Montando partições\n"
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
pacstrap_arch(){
  clear
  echo -e "[!] - Instalando os pacotes base do Arch Linux\n"
  sleep 2
  pacstrap /mnt base dhcpcd neovim linux-firmware base-devel
  pacman -Sy archlinux-keyring --noconfirm
  pacstrap /mnt base dhcpcd neovim linux-firmware base-devel
}

fstab_gen(){
  clear
  echo -e "[!] - Gerando o Fstab\n"
  sleep 2
  genfstab /mnt >> /mnt/etc/fstab
}

arch-chroot_enter(){
clear
echo -e "[!] - Entrando no chroot\n"
sleep 2
arch-chroot /mnt
}

dhcpcd_enable(){
  systemctl enable dhcpcd
}

timezone_config(){
  ln -sf /usr/share/zoneinfo/America/Recife /etc/localtime
hwclock --systohc
timedatectl set-ntp true
}

language_system(){
  nvim /etc/locale.gen
  clear && locale-gen
  printf "\nCole a linguagem descomentada abaixo (Ex: en_US.UTF-8):\n\n"
  read LANGUAGE
  echo LANG="$LANGUAGE" > /etc/locale.conf
  export "$LANGUAGE"
}

keymap_config(){
  echo KEYMAP=br-abnt2 > /etc/vconsole.conf
}

hostname_config(){
  clear && printf "Digite abaixo um hostname para a sua maquina:\n\n"
  read HOST_NAME
  echo "$HOST_NAME" > /etc/hostname
}

btrfs_progs_config(){
  pacman -S btrfs-progs --noconfirm
}

kernels_download(){
  clear && printf "Escolha seu kernel de preferência:\n\n[1] - linux (Kernel defautl)\n[2] - linux-hardened (Kernel focado na segurança)\n[3] - linux-lts (Kernel a longo prazo)\n[4] - linux-zen (Kernel focado em desempenho)\n\n"
  read KERNEL_CHOICE
  if [ $KERNEL_CHOICE == '1' ] || [ $KERNEL_CHOICE == '01' ] ; then
    clear && pacman -S linux linux-headers --noconfirm

  elif [ $KERNEL_CHOICE == '2' ] || [ $KERNEL_CHOICE == '02' ] ; then
    clear && pacman -S linux-hardened linux-hardened-headers --noconfirm

  elif [ $KERNEL_CHOICE == '3' ] || [ $KERNEL_CHOICE == '03' ] ; then
    clear && pacman -S linux-lts linux-lts-headers --noconfirm

  elif [ $KERNEL_CHOICE == '4' ] || [ $KERNEL_CHOICE == '04' ] ; then
    clear && pacman -S linux-zen linux-zen-headers --noconfirm

  else
    read -p 'Opção invalida, POR FAVOR ESCOLHA UM KERNEL, PRESSIONE ENTER PARA CONTINUAR...' && kernels_download
  fi
}

pacman_config(){
  nvim /etc/pacman.conf
}

repo_update(){
  pacman -Syy
}

password_root(){
  clear && printf "Digite e confirme sua senha root abaixo (CUIDADO A SENHA NÃO É EXIBIDA):\n\n"
  passwd
}

user_create(){
  clear && printf "Criando usuario, escolha seu shell de preferência:\n\n[1] - bash\n[2] - zsh\n\n"
  read SHELL_CHOICE
  if [ $SHELL_CHOICE == '1' ] || [ $SHELL_CHOICE == '01' ] ; then
    clear && pacman -S bash --noconfirm
    clear && printf "Digite o nome do seu usuario abaixo (COM LETRAS MINUSCULAS SEM ACENTOS E SEM ESPAÇOS):\n\n"
    read USERNAME
    clear && useradd -m -g users -G wheel -s /bin/bash "$USERNAME"

  elif [ $SHELL_CHOICE == '2' ] || [ $SHELL_CHOICE == '02' ] ; then
    clear && pacman -S zsh --noconfirm
    clear && printf "Digite o nome do seu usuario abaixo (COM LETRAS MINUSCULAS SEM ACENTOS E SEM ESPAÇOS):\n\n"
    read USERNAME
    clear && useradd -m -g users -G wheel -s /bin/zsh "$USERNAME"

  else
    read -p 'Opção invalida, por favor tente novamente PRESSIONE ENTER PARA CONTINUAR...' && user_create
  fi
}

password_user(){
  clear && read -p 'Digite e confirme a sua senha de usuario abaixo (CUIDADO A SENHA NÃO É EXIBIDA) PRESSIONE ENTER PARA CONTINUAR...'
  clear && read -p 'Digite o nome do seu user abaixo:'
  read USERNAME1
  passwd "$USERNAME1"
}

edit_sudoers(){
  nvim /etc/sudoers
}

grub_install(){
pacman -S grub efibootmgr --noconfirm
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux --recheck
grub-mkconfig -o /boot/grub/grub.cfg
}

finish_install(){
  clear && read -p 'Instalação finalizada, NÃO ESQUEÇA DE SAIR DO CHROOT E REBOOTAR O PC!!! PRESSIONE ENTER PARA CONTINUAR...' && exit 0
}

main
font_system
format_disk
subvolumes
mount_partitions
pacstrap_arch
fstab_gen
arch-chroot_enter
dhcpcd_enable
timezone_config
language_system
keymap_config
hostname_config
btrfs_progs_config
kernels_download
pacman_config
repo_update
password_root
user_create
password_user
edit_sudoers
grub_install
finish_install
