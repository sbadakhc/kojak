#!/bin/bash
# 
# Copyright (C) 2013 Red Hat Inc.
# Author: Salim Badakhchani <sal@redhat.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.	
#
########################################################################

# Uncomment to debug script
#set -x

# Check to see if user is root
if [ "$USER" != "root" ]; then
    echo -e "\n# This script requires root priviledges to run"
    exit
fi

## Declare environment varibles
#
# Distro information
VMNAME=${VMNAME:="Fedora-19-x86_64-DVD"}
VMHOME=${VMHOME:="/var/lib/libvirt/images"}
TMPDIR=${TMPDIR:="/home/kojak"}
DIST=${DIST:="RedHat/Fedora/19/0/x86_64"}

# Sources and configuration
KSISO=${KSISO:="Fedora-19-x86_64-DVD.iso"}
KSCFG=${KSCFG:="Fedora-19-x86_64.cfg"}

# Working directories
CFGDIR="${TMPDIR}/cfg/${DIST}"
ISODIR="${TMPDIR}/iso/${DIST}"

# Virtual machine specifications
VMDISK="32768M"
VMMEM="4096"

heading() {
    clear
    echo -e "\n################################################################################"
    echo -e "#                                                                              #"
    echo -e "#                   !!! Welcome to Kojak...Koji in a box !!!                   #"
    echo -e "#                                                                              #\n"
}

menu() {
    while true
    do
    # Execute menu configuration options
    heading

    # Virtual machine name
    echo "Please specify a name for the virtual machine."
    read -e -i "$VMNAME" -p ">> VMNAME = $VMNAME : " VMNAME
    VMNAME="${VMNAME:=$VMNAME}"

    # Images directory
    echo "Please specify the directory where vm image will be created."
    read -e -i "$VMHOME" -p ">> VMHOME = $VMHOME : " VMHOME
    VMHOME="${VMHOME:=$VMHOME}"

    # Temp directory
    echo "Please specify a temporay directory used for the installation."
    read -e -i "$TMPDIR" -p ">> TMPDIR = $TMPDIR : " TMPDIR
    TMPDIR="${TMPDIR:=$TMPDIR}"

    # Distribution
    echo "Please specify your OS distribution."
    read -e -i "$DIST" -p ">> DIST = $DIST: " DIST
    DIST="${DIST:=$DIST}"

    # Kickstart iso file
    echo "Please specify the location of your distribution ISO file."
    read -e -i "$KSISO" -p ">> KSISO = $KSISO: " KSISO
    KSISO="${KSISO:=$KSISO}"

    # Kickstart configuration
    echo "Please specify the location of your kickstart configuration file."
    read -e -i "$KSCFG" -p ">> KSCFG = $KSCFG: " KSCFG
    KSCFG="${KSCFG:=$KSCFG}"

    # Kojak directories
    echo "Please specify the location of the Kojak configuration directory."
    read -e -i "$CFGDIR" -p ">> CFGDIR = $CFGDIR: " CFGDIR
    CFGDIR="${TMPDIR}/cfg/${DIST}"
    echo "Please specify the location of the ISO image directory."
    read -e -i "$ISODIR" -p ">> ISODIR = $ISODIR: " ISODIR
    ISODIR="${TMPDIR}/iso/${DIST}"

    # Virtual machine specifications
    echo "Please specify your vm disk space allocation."
    read -e -i "$VMDISK" -p ">> VMDISK = $VMDISK: " VMDISK
    VMDISK="32768M"
    echo "Please specify your vm memory allocation."
    read -e -i "$VMMEM" -p ">> VMMEM = $VMMEM: " VMMEM
    VMMEM="4096"


    echo -e "\n##   You check and modify your saved configuration options in the file kojak.cfg.   ##\n"
    echo -e "VMNAME=$VMNAME\nVMHOME=$VMHOME\nTMPDIR=$TMPDIR\nDIST=$DIST\nKSISO=$KSISO\nKSCFG=$KSCFG\nCFGDIR=$CFGDIR\nISODIR=$ISODIR\nVMDISK=$VMDISK\nVMMEM=$VMMEM" > $CFGDIR/kojak.cfg
    echo -e "# Saved configuration to kojak.cfg."
 
    read -s -n1 -p "`echo $'\n>> '`Press [RETURN] or [SPACE] to accept the configuration options: `echo $'\n>> '`Press [CTRL-C] to exit:" KEY
        if [ ${#KEY} -eq "0" ]; then
            echo -e "\n\nUsing supplied configuration options."
            break
        else
            echo -e "\n\nExiting configurator."
            exit
        fi
    done
}

# Prompt user for configuration defaults

if [ -f "$CFGDIR/kojak.cfg" ]; then
    heading
    read -s -n1 -p "`echo $'\n>> '`Press [RETURN] or [SPACE] to accept the previous saved configuration. `echo $'\n>> '`Press any other key to continue. `echo $'\n>> '`Press [CTRL-C] to exit." KEY
        if [ ${#KEY} -eq "0" ]; then
            echo -e "\n\n# Using saved configuration options."
            source $CFGDIR/kojak.cfg
	    else
            heading
            read -s -n1 -p "`echo $'\n>> '`Press [RETURN] or [SPACE] to accept the default options. `echo $'\n>> '`Press any other key run the configurator. `echo $'\n>> '`Press [CTRL-C] to exit:" KEY
            if [ ${#KEY} -eq "0" ]; then
                echo -e "\n\n# Using default configuration options."
            else
                echo -e "\n\n# Running Kojak menu options configurator."
            menu
            fi
        fi
else
    heading
    read -s -n1 -p "`echo $'\n>> '`Press [RETURN] or [SPACE] to accept the default options. `echo $'\n>> '`Press any other key run the configurator. `echo $'\n>> '`Press [CTRL-C] to exit. " KEY
        if [ ${#KEY} -eq "0" ]; then
            echo -e "\n\n# Using default configuration options."
        else
            echo -e "\n\n# Running Kojak menu options configurator."
            menu
        fi
fi

mkdir -p $CFGDIR $ISODIR 


if [ -f "$ISODIR/Fedora-19-x86_64-DVD.iso" ]; then
    echo "# DVD ISO Found"
else
    echo "# Downloading DVD ISO"
    cd $ISODIR
    wget http://download.fedoraproject.org/pub/fedora/linux/releases/19/Fedora/x86_64/iso/Fedora-19-x86_64-DVD.iso
    cd -
fi

cp kojak-ks.cfg $CFGDIR/

cd ${VMHOME}

echo -e "# Removing any pre-existing Kojak vm\n"
virsh destroy ${VMNAME}
virsh undefine ${VMNAME}

echo -e "# Removing any pre-existing Kojak image\n"
rm ${VMHOME}/${VMNAME}.img

echo -e "# Restarting virtualization services\n"
service libvirtd restart

echo -e "# Allocating the diskspace\n"
fallocate -l ${VMDISK} ${VMHOME}/${VMNAME}.img
chown qemu:qemu ${VMHOME}/${VMNAME}.img

echo -e "# Starting Kojak"
virt-install \
-n ${VMNAME} \
-r ${VMMEM} \
--vcpus=2 \
--os-type=linux \
--os-variant=fedora19 \
--accelerate \
--mac=00:00:00:00:00:00 \
--disk=${VMHOME}/${VMNAME}.img \
--disk=${ISODIR}/${KSISO},device=cdrom \
--location ${ISODIR}/${KSISO} \
--initrd-inject=${CFGDIR}/kojak-ks.cfg \
--extra-args="ks=file:kojak-ks.cfg console=tty0 console=ttyS0,115200 serial rd_NO_PLYMOUTH" \
--nographics
