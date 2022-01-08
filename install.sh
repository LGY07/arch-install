#!/bin/bash
title="ArchLinux inatall script"
printf "\033c"
if [ $(whoami) == "root" ]
then echo -e '\033]2;'$title'\007'
else echo -e "\033[31mERROR:\033[0m Please run this script as root，are you root?" & exit
fi
dhcpcd
timedatectl set-ntp true
cfdisk
clear

#Select partition
fdisk -l
echo -e "\033[36mMount point for /\033[0m"
read -p "/dev/" root
echo -e "\033[36mMount point for /boot\033[0m"
read -p "/dev/" boot
root=/dev/$root
boot=/dev/$boot
mkfs.btrfs $root
mkfs.fat -F32 $boot
mount $root /mount
mkdir /mnt/boot
mount $boot /mnt/boot
clear

#Select kernel
echo -e "\033[36mSelect kernel\033[0m"
echo "1: linux"
echo  -e "2: linux-zen (\033[35mdefault\033[0m)"
echo "4: linux-lts"
echo -e "\033[36mFor example, enter 1 to select linux,Enter 3(1+2) to select linux & linux-zen\033[0m"
read -p "Kernel: " Kernel
if [ Kernel == 1 ]
then Kernel=linux
elif [ Kernel == 3 ]
then Kernel=linux linux-zen
elif [ Kernel == 4 ]
then Kernel=linux-lts
elif [ Kernel == 5 ]
then Kernel=linux linux-lts
elif [ Kernel == 6 ]
then Kernel=linux-zen linux-lts
elif [ Kernel == 7 ]
then Kernel=linux linux-zen linux-lts
else Kernel=linux-zen
fi
clear

#Choose desktop environment
echo -e "\033[36mChoose desktop environment\033[0m"
echo "0: None"
echo -e "1: KDE Plasma (\033[35mdefault\033[0m)"
echo "2: GNOME"
echo -e "\033[36mFor example, enter 1 to select KDE plasma, enter 3(1+2) to select KDE plasma & GNOME\033[0m"
read -p "Desktop Environment:" de
if [ de == 0 ]
then de=networkmanager
elif [ de == 2 ]
then de=gnome gdm
elif [ de == 3 ]
then de=gnome plasma plasma-wayland-session kde-applications sddm
else de=plasma plasma-wayland-session kde-applications sddm
fi
clear

#Choose text editor
echo -e "\033[36mChoose text editor\033[0m"
echo "0: None"
echo -e "1: Vim (\033[35mdefault\033[0m)"
echo "2: Nano"
echo -e "\033[36mFor example, enter 1 to select Vim, enter 3(1+2) to select Vim & Nano\033[0m"
read -p "Text editor: " editor
if [ editor == 0]
then editor=vi
elif [ editor == 2 ]
then editor=nano vi
elif [ editor == 3 ]
then editor=nano vim vi
else editor=vim vi nano
fi
clear

#Select AUR helper
echo -e "\033[36mSelect AUR helper\033[0m"
echo "0: None"
echo -e "1: Yay (\033[35mdefault\033[0m)"
echo "2: Yaourt"
echo -e "\033[36mFor example, enter 1 to select KDE plasma, enter 3(1+2) to select Yay & Yaourt\033[0m"
read -p "AUR helper: " aur
if [ aur == 0 ]
then aur=pacman
elif [ aur == 2 ]
then aur=yaourt
elif [ aur == 3 ]
then aur=yay yaourt
else aur=yay
fi
echo "[archlinuxcn]">>/etc/pacman.conf
echo "SigLevel = Optional TrustAll">>/etc/pacman.conf
echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch'>>/etc/pacman.conf
clear

#arch-install-script
pkg="base base-devel linux-firmware dhcpcd grub efibootmgr os-prober ntfs-3g git $kernel $de $editor $aur"
pacstrap /mnt $pkg
genfstab -U /mnt/etc/fstab
echo "en_US.UTF-8 UTF-8">>/mnt/etc/locale.gen
echo "zh_CN.UTF-8 UTF-8">>/mnt/etc/locale.gen
echo LANG="en_US.UTF-8"> /mnt/etc/locale.conf
mkdir /mnt/boot/grub
read -p "Set username: " username
echo "$username-PC">/mnt/etc/hostname
echo "$username ALL=(ALL) ALL">>/mnt/etc/sudoers
echo $username>/mnt/tpm/user

#chroot
arch-chroot /mnt user=$(cat /tpm/user)
arch-chroot /mnt rm -f /tpm/user
arch-chroot /mnt echo "Set $user password"
arch-chroot /mnt passwd $user
arch-chroot /mnt echo "Set root passwd"
arch-chroot /mnt passwd
clear
arch-chroot /mnt os-prober
arch-chroot /mnt grub-install --target=$(uname -i)-efi --efi-directory=/boot --bootloader-id=ArchLinux
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
clear

#reboot
clear
n=10
while [ $n -ge 1 ]
do
    clear
    echo -e "\033[32mFINISH\033[0m,Reboot after $n seconds"
    let n=$(( $n - 1 ))
    sleep 1
done
reboot