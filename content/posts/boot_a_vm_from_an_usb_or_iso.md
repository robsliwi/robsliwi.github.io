---
title: Boot a VM from an USB or ISO
date: 2025-01-23
description: Built or got a new ISO that possibly auto-install and don't want to nuke your current system?
tags:
   - ISO
   - Linux
   - TIL
   - QEMU
   - KVM
---

It's great to learn a few things. Back in the day I was creating a VirtualBox VM with Vagrant to test the newly built ISOs that auto-installed the Linux distribution of choice.
Anybody that dealt with VirtualBox Kernel modules and the licensing knows that it can be quite, let's say, at least, time-consuming.

Any recent Linux or Windows with QEMU is a joy to use to quickly spin up a VM and boot your ISO. Or even a USB-Stick you found that already got some Fedora or NixOS label on it:

    qemu-system-x86_64 -boot d -cdrom mylittle.iso -m 2048 -enable-kvm

That's it. A VM booting the ISO with 2GB of RAM. Close the window when you're done.

For the USB-version you need to be root and mount the right device thoughtfully. Or you need to install new anyways:

    qemu-system-x86_64 -drive file=/dev/sda,format=raw,media=disk -m 2048 -enable-kvm -boot menu=on

Oh, how many hours spent dealing with incompatible kernel modules in the past...
