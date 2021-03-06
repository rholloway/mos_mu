
## Table of Contents
 - [Inventory](#inventory)
 - [Folder structure](#folder-structure)
   - [Fuel](#fuel)
   - [Nodes](#nodes)
 - [Playbooks](#playbooks)
   - [gather_customizations.yml](#gather_customizationsyml)
   - [verify_patches.yml](#verify_patchesyml)
   - [apply_mu.yml](#apply_muyml)
   - [update_fuel.yml](#update_fuelyml)
   - [restart_services.yml](#restart_servicesyml)
   - [update_ceph.yml](#update_cephyml)
   - [rollback.yml](#rollbackyml)


Inventory
=========

Inventory Python script generates inventory data for Ansible using Fuel API.
For review inventory you can run this script separately.

[fuel_inventory.py](../inventory/fuel_inventory.py)

Please be aware that this script generates the inventory only for nodes which
are in **ready** state and **online**!

Folder structure
================

By default it looks like this (might be configured in conf file):

Fuel
----

Directory tree:
```
../fuel_mos_mu/
├── env_1
|   ├── backup
|   │   ├── customizations__07.10.17__08-19-03.tgz
|   │   └── reports__07.10.17__08-19-05.tgz
|   ├── customizations
|   │   ├── node-1
|   │   │   ├── neutron-common_customization.patch
|   │   │   └── nova-compute_customization.patch
|   │   ├── node-2
|   │   ├── node-3
|   │   │   └── neutron-common_customization.patch
|   │   ├── node-4
|   │   └── node-5
|   ├── customizations_unified
|   │   ├── neutron-common_customization.patch
|   │   └── nova-compute_customization.patch
|   ├── customizations_verification
|   │   ├── neutron-common
|   │   │   ├── node-1
|   │   │   │   └── neutron-common_customization.patch
|   │   │   └── node-3
|   │   │       └── neutron-common_customization.patch
|   │   └── nova-compute
|   │       └── node-1
|   │           └── nova-compute_customization.patch
|   ├── patches
|   │   ├── 00-customizations
|   │   │   ├── neutron-common_customization.patch
|   │   │   └── nova-compute_customization.patch
|   │   └── 01-neutron.patch
│   └── report
│       ├── node-1
│       │   ├── md5_results
│       │   ├── pkgs_verification_results
│       │   └── upgradable_pkgs
│       ├── node-2
│       │   ├── md5_results
│       │   ├── pkgs_verification_results
│       │   └── upgradable_pkgs
│       ├── node-3
│       │   ├── md5_results
│       │   ├── pkgs_verification_results
│       │   └── upgradable_pkgs
│       ├── node-4
│       │   ├── md5_results
│       │   ├── pkgs_verification_results
│       │   └── upgradable_pkgs
│       └── node-5
│           ├── md5_results
│           ├── pkgs_verification_results
│           └── upgradable_pkgs
└── fuel_backup
    └── fuel_backup__07.10.17__06-12-16.tgz
```

* Each environment has its own folder **env_<env_id>**

* **backup** contains backups of gathered customizations.
  Backup is generated after each gathering customizations process.

* **customizations** is used for gathering customizations from nodes.
  Customizations are placed in folder with nodename.
  Customizations are gathered when this folder is absent or if you want to
  gather it from scratch please use flag **gather_customizations: true**.
  This folder is generated by [gather_customizations.yml](#gather_customizationsyml)

* **customizations_verifications** is used for processing of customizations
  which contains set of folders (package customization) across the environment.
  This folder is generated by [verify_customizations.yml](../playbooks/tasks/verify_customizations.yml)

* **customizations_unified** contains unified customizations which will be
  copied to **patches/00-customizations** folder and used for applying after updating.

* **patches** is used for storing set of patches which will be synced
  on nodes and used for verifying and applying on cloud.
  Patches should have **.patch** extensions. Please be aware that patches
  will be applied in alphabetic order, also keep in mind that if flag
  **use_current_customizations: true** is enabled current customizations
  will be also copied to **patches** folder on nodes with to
  **00-customizations** folder.
  So it is recommended to name patches with prefixes like this
  **01-\<patchname\>.patch, 02-\<patchname2\>.patch**.

* **report** contains reports from all nodes

* **fuel_backup** contains backup of PSQL DB and some configuration files.


Nodes
-----

Directory tree:
```
/root/mos_mu/
├── apt
│   ├── apt.conf
│   ├── preferences.d
│   │   └── mos.pref
│   └── sources.list.d
│       ├── fuel.list
│       ├── GA.list
│       ├── mu-1.list
│       ├── mu-2.list
│       └── mu-3.list
├── backup
│   └── etc.tgz
├── customizations
│   ├── neutron-common
│   │   ├── 2%3a7.1.1-4~u14.04+mos82
│   │   │   └── ...
│   │   └── neutron-common_customization.patch
│   └── nova-compute
│       ├── 2%3a12.0.4-1~u14.04+mos10
│       │   └── ...
│       └── nova-compute_customization.patch
├── patches
│   ├── 00-customizations
│   │   ├── neutron-common_customization.patch
│   │   └── nova-compute_customization.patch
│   └── 01-neutron.patch
├── report
│   ├── md5_results
│   ├── pkgs_verification_results
│   └── upgradable_pkgs
└── verification
    ├── neutron-common
    │   ├── 2%3a7.1.1-4~u14.04+mos82
    │   │   ├── neutron-common_2%3a7.1.1-4~u14.04+mos82_all.deb
    │   │   └── ...
    │   └── neutron-common_customization.patch
    ├── nova-compute
    │   ├── 2%3a12.0.4-1~u14.04+mos10
    │   │   ├── nova-compute_2%3a12.0.4-1~u14.04+mos10_all.deb
    │   │   └── ...
    │   └── nova-compute_customization.patch
    └── python-neutron
        ├── 01-neutron.patch
        └── 2%3a7.1.1-4~u14.04+mos82
            ├── python-neutron_2%3a7.1.1-4~u14.04+mos82_all.deb
            └── ...
```

* **apt** contains apt.conf which is always used for apt and uses
  only **sources.lists.d** folder for sources lists.

    * **apt/sources.list.d** contains sources lists for all configured in config
    repositories.

    * **apt/preferences.d** contains preferences for package pinning.
* **backup** contains backup files on node. For now archive for etc directory.
* **customizations** folder consists of folders for customized packages.
  Package folder contains a folder (current package version) with unpacked
  package and diff file between this unpacked (original) version and current
  installed (customized) version.

* **patches** folder contains all patches from Fuel **patches** folder and
  This folder is cleared every time when task [verify_patches.yml](#verify_patchesyml)
  is started.

* **report** contains some reports and cached files with the results of some steps
  which allow to reuse some results (save time) for the multiple run of some
  playbooks. For gathering fresh results please use special flags
  [Steps](../playbooks/vars/steps.yml).

* **verification** folder consists of folders for customized packages.
  Packages folders contain a folder (candidate package version, by default,
  configured by flag **pkg_ver_for_verification: "Candidate"**) with unpacked
  package and patches files witch should be applied.


Playbooks
=========

By default all playbooks are defined for all nodes in env_<env_id> except Fuel.
It might be run for any node and group of nodes using standard flag **--limit**
like this `--limit=compute` (all computes in env_<env_id>).

All playbooks include variable file
[vars/mos_releases/{{ mos_release }}.yml](../playbooks/vars/mos_releases)
based on **mos_release** variable, which dynamically defined during
the inventorization phase.

Also it is possible to pass extra variables via cli using standard flag **-e**,
like this `-e '{"apt_update":true, "health_check":false}'`.


[gather_customizations.yml](../playbooks/gather_customizations.yml)
-------------------------------------------------------------------
For the first step it starts health check (if it might be disabled by
**health_check** flag). Then generates APT configuration files, if they are
not present on node or enabled flag **apt_update** for regerating them.
Makes sure that customizations were not gathered already and then gathers it.
If you need to gather it again you can use flag **gather_customizations**.

Uses [vars/steps.yml](../playbooks/vars/steps.yml) set of flags.

* **"health_check":false** to skip the health check task
* **"apt_update":true** to repeat the generation of APT files
* **"gather_customizations":true** to repeat gathering of customizations
* **"md5_check":true** to repeat MD5 hash verification

Runs the following tasks:
* [health_checks.yml](../playbooks/tasks/health_checks.yml)
* [apt_update.yml](../playbooks/tasks/apt_update.yml)
* [gather_customizations.yml](../playbooks/tasks/gather_customizations.yml)
    * [verify_md5.yml](../playbooks/tasks/verify_md5.yml)
    * [gather_customizations_action.yml](../playbooks/tasks/gather_customizations_action.yml)


[verify_patches.yml](../playbooks/verify_patches.yml)
-----------------------------------------------------
Actually this playbook only verifies that all nodes have the same set of patches
and then verifies applying the patches on target version of packages
**pkg_ver_for_verification**. Let's

Uses [vars/steps.yml](../playbooks/vars/steps.yml) set of flags.

* **"use_current_customization":false** to skip handling gathered customizations from
  "customizaions" folder and use only patches that are already present in folder
  "patches"
* **"ignore_applied_patches": true** to ignore if patches already contains in
  new package. Please go on one node and double checked that this pached already contains
  to avoid any issues.

Runs 3 tasks:
* [apt_update.yml](../playbooks/tasks/apt_update.yml)
* [verify_customizations.yml](../playbooks/tasks/verify_customizations.yml)
* [verify_patches.yml](../playbooks/tasks/verify_patches.yml)


[apply_mu.yml](../playbooks/apply_mu.yml)
-----------------------------------------
This playbook contains all tasks from 2 previous playbooks
[gather_customizations.yml](#gather_customizationsyml) and
[verify_patches.yml](#verify_patchesyml).
Then upgrade packages and applies patches on nodes.

Uses [vars/steps.yml](../playbooks/vars/steps.yml) set of flags.

Runs the following tasks:
* [health_checks.yml](../playbooks/tasks/health_checks.yml)
* [apt_update.yml](../playbooks/tasks/apt_update.yml)
* [gather_customizations.yml](../playbooks/tasks/gather_customizations.yml)
    * [verify_md5.yml](../playbooks/tasks/verify_md5.yml)
    * [gather_customizations_action.yml](../playbooks/tasks/gather_customizations_action.yml)
* [verify_customizations.yml](../playbooks/tasks/verify_customizations.yml)
* [verify_patches.yml](../playbooks/tasks/verify_patches.yml)
* [apt_upgrade.yml](../playbooks/tasks/apt_upgrade.yml)
* [apply_patches.yml](../playbooks/tasks/apply_patches.yml)

and then runs one more playbook:
* [restart_services.yml](#restart_servicesyml)

[restart_services.yml](../playbooks/restart_services.yml)
---------------------------------------------------------
Restart all services for each role specified in
[vars/mos_releases/{{ mos_releases }}.yml](../playbooks/vars/mos_releases).

Might be used separately.


[update_fuel.yml](../playbooks/update_fuel.yml)
-------------------------------------------
Update the Master node itself.
Depends on the current version of Fuel it runs different set of tasks, for
MOS versions before 9.0 it runs the following tasks:

[update_old_fuel.yml](../playbooks/tasks/update_old_fuel.yml)
* Stop containers
* Make a backup of DB and config files
* Yum update
* Load new images
* Rebuild and start containers

For MOS9.x it uses another set of tasks:
[update_9x_fuel.yml](../playbooks/tasks/update_9x_fuel.yml)


[backup_mysql.yml](../playbooks/backup_mysql.yml)
-------------------------------------------

This playbook runs the following tasks:
* Stop VIP Management using Pacemaker
* Make MySQL backup
* Upload backup on the Fuel
* Start VIP Management using Pacemaker


[get_version.yml](../playbooks/get_version.yml)
-------------------------------------------

This playbook run apt-get upgrade for each MU repo. The repo which doesn't
required any upgrade/downgrade for any package is the currently used.

Runs the following tasks:
* [apt_update.yml](../playbooks/tasks/apt_update.yml)
* [get_current_mu](../playbooks/tasks/get_current_mu.yml)


[update_ceph.yml](../playbooks/update_ceph.yml)
-----------------------------------------
This is a separate playbook that uses some ideas and solutions introduced in
ceph-ansible project to update ceph installations deployed by Fuel.

Runs the following tasks:
* [health_checks.yml](../playbooks/tasks/health_checks.yml)
* [update_ceph.yml](../playbooks/tasks/update_ceph.yml)
* [restart_ceph.yml](../playbooks/tasks/restart_ceph.yml)

MON, OSD and RGW nodes are updated one-by-one. The following features are used
to protect data and achieve zero downtime:
* Quorum is checked after MONs services restart to ensure that updated host
came up and running.
* scrub and deep-scrub operations are stopped during OSDs update.
* noout flag is used to activate maintenance mode for a cluster.
* Clusters health is checked to ensure that updated OSD came up and running.
* Any failure during any update play will stop the whole update process.

This playbook should be runned with env_id specified using standard flag **-e**.
For example: `-e '{"env_id":1}'`.

Uses [vars/steps/ceph.yml](../playbooks/vars/steps/ceph.yml) set of flags.


[rollback.yml](../playbooks/rollback.yml)
-----------------------------------------
This is a pseudo rollback, since it does not save the current state, but provide
you a mechanism for installing any MU release (that you have initially for
rollback) and apply gathered customizations, of course as usual with verifying
patches before installing.

Runs the following tasks:
* [health_checks.yml](#health_checksyml)
* [apt_update.yml](#apt_updateyml)
* [verify_md5.yml](#verify_md5yml)
* [gather_customizations.yml](#gather_customizationsyml)
* [verify_customizations.yml](#verify_customizationsyml)
* [verify_patches.yml](#verify_patchesyml)
* [rollback_upgrade.yml](#rollback_upgradeyml)
* [apply_patches.yml](#apply_patchesyml)

and then include one more playbook:
* [restart_services.yml](#restart_servicesyml)

Uses [vars/steps.yml](../playbooks/vars/steps.yml) set of flags.
