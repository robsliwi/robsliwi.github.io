---
title: Am I a VM?
date: 2024-01-26
description: You got access to a Linux system. What is it? Is it a virtual machine?
tags:
   - systemd
   - Linux
   - TIL
---

Sometimes you stumble across things you really like and need to jot down to have them for usage later.
Or find your own question on Stack Overflow, a random forum or a mailing list.

On `$daytimejob` we often need to answer the question if a particular system that we have access to is a virtual machine or not.
Instead of doing some scrolling action through `lshw`, `dmesg` or others there is systemd in place. 
At least in most cases.

    systemd-detect-virt

And you will get your answer: `qemu`, `amazon`, `vmware` or `none` with an exit code of 1.
For additional information, see https://www.freedesktop.org/software/systemd/man/latest/systemd-detect-virt.html
