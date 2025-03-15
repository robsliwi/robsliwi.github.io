---
title: NixOS Ansible JumpHost
date: 2025-03-15
description: Got the urgent need for a JumpHost that supports Ansible?
tags:
   - NixOS
   - Linux
   - SSH
   - JumpHost
   - Ansible
   - Python
   - tmpfiles.d
---

Given some Ansible hosts that you want to massage imperatively in the right direction sometimes there is the need for a SSH-JumpHost (ProxyJump) to access those hosts living in _secure enterprise networks_.
Instead of exposing some well known Linux distro or device that supports Ansible and some recent version of SSH you chose to jump through your NixOS host named `bastion`.

Well, not that easy as it turns out.
Most of the Ansible modules require a full blown Python interpreter.[^1] Yes, that's right. Think of just triggering an `ansible.builtin.shell` and you should think of a Python interpreter executing the shell command for you.

You should at least add the following to your `bastion/configuration.nix`:

```nix
{
  # Create a symlink from /usr/libexec/platform-python to the Python executable
  systemd.tmpfiles.rules = [
    "L+ /usr/libexec/platform-python - - - - ${pkgs.python3Minimal}/bin/python3"
  ];
}
```

Happy Ansibling!

[^1]: OpenWRT hosts: [Ansible w/o Python for some modules](https://github.com/gekmihesg/ansible-openwrt)
