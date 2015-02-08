#!/bin/bash

/usr/bin/truncate -s 10m /tmp/metadata_drive;sync;
# specify app location
parted /tmp/metadata_drive < /vagrant/app/metadata/parted_procedure.txt
sudo kpartx -av /tmp/metadata_drive
udevadm settle
mkfs -t vfat -n METADATA /dev/mapper/loop0p1
sudo mount -t vfat /dev/mapper/loop0p1 /tmp/md_mount
