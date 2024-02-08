---
title: grep, but match a AND b
date: 2024-02-08
description: Ever wondered how grep can be used with an AND instead of OR? I did.
tags:
   - TIL
   - Linux
   - Ansible
   - grep
   - awk
---

## Actual problem, an Ansible Inventory

There is an Ansible inventory in YAML.
Or better: Multiple YAML files that make an Ansible Inventory in the end.

There is a particular file `_common.yml` that looks like this:

```yaml
app1:
  vars:
    app1_version: 1.2.1
app2:
  children:
    app1:
  vars:
    app2_versions:
      - app2-0.1.2
      - app2-plugin-a-0.0.1
      - app2-plugin-b-0.0.2
```

This is the base definition of variables for both groups, `app1` and `app2`.
Now in another file `hosts_from_datacenter_a.yml` there is the following:

```yaml
datacenter_a:
  hosts:
    fancyserver-a.datacenter-a.local:
    fancyserver-b.datacenter-a.local:
      app1_version: 1.2.0
      app2_versions:
        - app2-0.1.1
        - app2-plugin-a-0.0.1
        - app2-plugin-b-0.0.2
        - app2-plugin-c-0.0.3

app1:
  hosts:
    fancyserver-a.datacenter-a.local:
    fancyserver-b.datacenter-a.local:
```

What this gives us is two servers that are associated with variables from the above mentioned groups.

Letting Ansible parse our files results in the following output of `ansible-inventory -i . --list | jq '._meta.hostvars'`:

```json
{
  "fancyserver-a.datacenter-a.local": {
    "app1_version": "1.2.1",
    "app2_versions": [
      "app2-0.1.2",
      "app2-plugin-a-0.0.1",
      "app2-plugin-b-0.0.2"
    ]
  },
  "fancyserver-b.datacenter-a.local": {
    "app1_version": "1.2.0",
    "app2_versions": [
      "app2-0.1.1",
      "app2-plugin-a-0.0.1",
      "app2-plugin-b-0.0.2",
      "app2-plugin-c-0.0.3"
    ]
  }
}
```

Give those YAML files some time and several people to work with there will be some things and particular hosts that will be forgotten to be adjusted (especially bumped) when the values in the `_common.yml` get updated.

## How to get ahead of this particular YAMLrot?
I was searching for an easy method to spot files in which overrides like for `fancyserver-b` were done to poor hosts.

After struggling a lot and spending some time with search engines and even LLMs I came up with the following solution for an **AND**-grep:

```bash
grep -l "app1_version" inventory/*.yml | xargs grep -e "app1_version\|app2-"
```

And viola there were others with even older versions specified:

```yaml
datacenter_c.yml:    app1_version: 1.0.0
datacenter_c.yml:      - app2-0.0.2
datacenter_c.yml:      - app2-plugin-a-0.0.1
```

Next time there will be some `awk` I guess, but just printing out this particular nice list of matches in the files will be quite some wrangling with the awk language, at least with the current state of knowledge about it 😇.
