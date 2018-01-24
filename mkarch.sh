#!/bin/bash
#
# Install Arch Linux base system on VirtualBox
#

# clock
timedatectl set-ntp true

# partition virtual disk
fdisk /dev/sda <<EOF
n
p
1


a
w
EOF

# root fs
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt

# swap
dd if=/dev/zero of=/mnt/swapfile bs=1M count=512
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile

# bootstrap
pacstrap /mnt base

# fstab
genfstab -U /mnt >> /mnt/etc/fstab
printf "/swapfile none swap defaults 0 0\n" >> /mnt/etc/fstab

# chroot
arch-chroot /mnt <<EOF

# timezone
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc

# locale
sed -i "s|^# en_US.UTF-8 UTF-8|en_US.UTF-8 UTF-8|" /etc/locale.gen
locale-gen
printf "LANG=en_US.UTF-8\n" > /etc/locale.conf

# hostname
printf "ArchLinux\n" > /etc/hostname
printf "127.0.0.1  localhost.localdomain  localhost\n" >> /etc/hosts
printf "127.0.1.1  ArchLinux.localdomain  ArchLinux\n" >> /etc/hosts

# grub
pacman -S --noconfirm grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# root password
printf "password\n" | passwd

# quit
EOF
umount -R /mnt
