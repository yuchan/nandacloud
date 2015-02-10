#!/bin/bash

sudo umount -l /tmp/md_mount
sudo kpartx -dv /tmp/metadata_drive

