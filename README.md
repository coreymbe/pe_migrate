# pe_migrate

##### Table of Contents

1. [Overview](#Overview)
2. [Setup Requirements](#setup)
    * [Limitations](#limitations)
3. [Usage](#usage)
    * [Migration Guide](#migration_steps)
4. [Advanced Usage](#advanced_usage)

## Overview

With the steps provided in this module you'll migrate the following components of your PE installation to a new host:

  * PE configuration, including license, classification, and RBAC settings.
  * PE CA certificates and the full SSL directory.
  * The Puppet code deployed to your code directory at backup time.
  * PuppetDB data, including facts, catalogs and historical reports.

## Setup

This module should be installed on the current Puppet Primary Server (MoM).

The tasks provided in this module require the [`puppet-bolt`](https://puppet.com/docs/bolt/latest/bolt_installing.html) and `rsync` packages. You can manually install these packages, or you can apply the `pe_migrate::prep` class to the Puppet Primary Server. This class will set up the Puppet Tools repository and install both `puppet-bolt` and `rsync`. Although you will need to **manually install** `rsync` on the **target host**.

**Requirement**: Utilization of this module also requires SSH access as `root` to the new host via an ssh-key.

### Limitations:

**Please Note:** These instructions are for **[standard installations](https://puppet.com/docs/pe/2019.8/supported_architectures.html#standard-installation)** only. While the tasks provided in this module allow you to backup and restore your Puppet Enterprise installation on a target host, you will need to manually install PE on the target host before restoring the backup.

**Additionally**:

* If you are migrating from PE 2018.1 or older, you may need to remove the class ***mcollective\_middleware\_hosts*** from the **PE Infrastructure** node group before moving to PE 2019.x.
  *  PE 2018.1+ no longer includes MCollective. To prepare, [migrate your MCollective work to Puppet orchestrator](https://puppet.com/docs/pe/2018.1/managing_mcollective/migrating_from_mcollective_to_orchestrator.html) to automate tasks and create consistent, repeatable administrative processes.


## Usage

While most of the migration can be automated with the use of these tasks, there are a few manual steps you will need to perform. Please follow the guideline below when performing a migration of your PE installation. The tasks can be ran from the command line as shown, or from the PE Console.

### Migration Steps:

#### **Step One: Backup the PE installation.**

```
puppet task run pe_migrate::puppet_backup backupdir=</BACKUP/DIR> --nodes <PRIMARY SERVER FQDN>
```

#### **Step Two: Transfer the backup.**

```
puppet task run pe_migrate::backup_transfer backupdir=</BACKUP/DIR> targetdir=</BACKUP/DIR/ON/TARGET> targethost=<NEW PRIMARY SERVER FQDN> --nodes <PRIMARY SERVER FQDN>
```

#### **Step Three: Install PE**

On the new primary server, install the [same version of PE](https://puppet.com/misc/pe-files/previous-releases/).

#### **Step Four: Restore the backup to the new PE installation.**

```
puppet task run pe_migrate::puppet_restore privatekey=</PATH/TO/KEY> targetdir=</BACKUP/DIR/ON/TARGET> targethost=<NEW PRIMARY SERVER FQDN> --nodes <PRIMARY SERVER FQDN>
```

#### **Step Five: Upgrade the new PE installation.**

On the new primary server, perform an in-place upgrade to the desired version of PE by following the steps in our documentation [here](https://puppet.com/docs/pe/2019.8/upgrading_pe.html#upgrade_standard).

#### **Step Six: Point agent nodes at the new primary server.**

```
puppet task run pe_migrate::agent_migrate targethost=<NEW PRIMARY FQDN> --node-group <PE-Agent node-group-id>
```

**Please Note**: The PE Agent node group ID can be found in the PE Console under _Node Groups -> PE Agent -> Activity_. The ID will be in the very first entry.

#### **Step Seven: Upgrade agent nodes.**

If you migrated to a newer version of PE, [upgrade the agent nodes](https://puppet.com/docs/pe/2019.8/upgrading_agents.html).

---

## Advanced Usage - Manual Migration

Before utilizing the advanced steps in this module, please make sure you are unable to use the built-in `puppet-backup` command to [backup and restore](https://puppet.com/docs/pe/2019.8/backing_up_and_restoring_pe.html) your PE installation. An example scenario where you would be unable to use the aforementioned command would be moving to a new host OS that does support the current version of Puppet Enterprise installed.

If you are unable to use the `puppet-backup` command, you may be able to use the advanced [manual migration steps](https://github.com/coreymbe/pe_migrate/tree/main/docs/ManualMigration.md) and tasks provided in this module.

---

