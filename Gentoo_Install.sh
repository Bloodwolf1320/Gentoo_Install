#!/bin/bash
set -e

#Create partitions
#This script is intended to be run from a gentoo based gui live environment.
#Partitions should be made with gparted before running this script. If installing
#from command line please use cfdisk or whatever else you like BEFORE running the script

#Forces the creation of the /mnt/gentoo directory which sometimes fails in gentoo based distros
#mkdir /mnt/gentoo

#Formats the efi boot partition as fat32
mkfs.vfat -F 32 /dev/sda1

#Formats the root partition as ext4
mkfs.ext4 /dev/sda2

#Mounts gentoo on root partition
mount /dev/sda2 /mnt/gentoo

#Sets the time
#ntpd -q -g

#Change directory into the gentoo directory on HDD
cd /mnt/gentoo

#Downloads the stage3 tarball
wget https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20210519T214503Z/stage3-amd64-20210519T214503Z.tar.xz

# Extracts tarball
tar xpvf stage3-amd64-20210519T214503Z.tar.xz --xattrs-include='*.*' --numeric-owner

#Opens nano text editor to configure the make.conf file.
nano -w /mnt/gentoo/etc/portage/make.conf

#Choose Mirror
mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf

#Make repos.conf
mkdir --parents /mnt/gentoo/etc/portage/repos.conf

#Copy latest Gentoo repository configuration to repo directory
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

#Copy DNS settings to retain Internet access
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

#Mount required filesystems
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

#chroot into system
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"

#Mount Boot Partition
mount /dev/sda1 /boot

#Install latest ebuild snapshot
emerge-webrsync

#Update to latest ebuild repo after snapshot
emerge --sync

#List Profiles
eselect profile list

#To select a profile use eselect profile set followed by the profile number from the list.

#Update world set
emerge --ask --verbose --update --deep --newuse @world


