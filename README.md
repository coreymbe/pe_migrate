# pe_migrate

##### Table of Contents

1. [Overview](#Overview)
1. [Setup Requirements](#setup)
    * [Limitations](#limitations)
1. [Usage - Configuration options and additional functionality](#usage)
    * [Migration Guide](#migration_steps)

## Overview

Before using this module, please make sure you are unable to use the built-in `puppet-backup` command to [backup and restore](https://puppet.com/docs/pe/2019.8/backing_up_and_restoring_pe.html) your PE installation. An example scenario where you would be unable to use the aforementioned command would be moving to a new host OS that does support the current version of Puppet Enterprise installed.

If you are unable to use the `puppet-backup` command, you can use the `pe_migrate` module. This module provides a number of tasks that can be utilized to manually migrate a Puppet Enterprise installation.

With the steps provided in this module you'll prepare and move certs, database, classifier, configuration files, Puppet code, and Hiera data while keeping your current infrastructure up and running.

## Setup

This module should be installed on the current Puppet Primary Server.

The tasks provided in this module require the [`puppet-bolt`](https://puppet.com/docs/bolt/latest/bolt_installing.html) and `rsync` packages. You can manually install these packages, or you can apply the `pe_migrate::prep` class to the Puppet Primary Server and PE-PostgreSQL node (if you are utilizing an [external PE-PostgreSQL node](https://puppet.com/docs/pe/2019.7/installing_postgresql.html)). This class will set up the Puppet Tools repository and install both `puppet-bolt` and `rsync`. Although you will need to **manually install** `rsync` on the **target host**.

**Requirement**: Utilization of this module also requires SSH access as `root` to the new host via an ssh-key.

### Limitations:

**Please Note:** These tasks should **not** be used with `PE 2019.4` or newer, as there are changes to PE-PuppetDB which prevents the successful use of these tasks. I suggest migrating to `PE 2019.2.1`, and then performing an in-place upgrade to the latest version. Although you will want to double check for any [upgrade cautions](https://puppet.com/docs/pe/2019.2/upgrading_pe.html#upgrade_cautions) based on the current version of your PE installation.

**Additionally**:

*   Use of this module assumes that you're using the instance of PostgreSQL provided by PE and a default Hiera configuration with `hiera.yaml` in the default location, `/etc/puppetlabs/puppet/hiera.yaml`.

* If you are migrating from PE 2018.1 or older, you may need to remove the class ***mcollective\_middleware\_hosts*** from the **PE Infrastructure** node group before moving to PE 2019.x.
  *  PE 2018.1+ no longer includes MCollective. To prepare, [migrate your MCollective work to Puppet orchestrator](https://puppet.com/docs/pe/2018.1/managing_mcollective/migrating_from_mcollective_to_orchestrator.html) to automate tasks and create consistent, repeatable administrative processes.


## Usage

While most of the migration can be automated with the use of these tasks, there are a few manual steps you will need to perform. Please follow the guideline below when performing a migration of your PE installation. The tasks can be ran from the command line as shown, or from the PE Console.

### Migration Steps:

#### **Step One: Back up the SSL directory.**

```
puppet task run pe_migrate::ssl_backup backupdir=</BACKUP/DIR> --nodes <PRIMARY SERVER FQDN>
```

#### **Step Two: Back up the databases.**

```
puppet task run pe_migrate::db_backup backupdir=</BACKUP/DIR> --nodes <POSTGRESQL NODE FQDN>
```

**Note**: If you see the following error, you need to temporarily comment out `Defaults    requiretty` in the `/etc/sudoers` file.

```
ERROR: sudo: sorry, you must have a tty to run sudo
```

#### **Step Three: Transfer the backups.**

```
puppet task run pe_migrate::backup_transfer environment=<MODULE ENVIRONMENT> backupdir=</BACKUP/DIR> targetdir=</DIR/ON/TARGETHOST> targethost=<NEW PRIMARY SERVER FQDN> --nodes <PRIMARY SERVER FQDN>
```

#### **Step Four: Restore the SSL directory.**

```
puppet task run pe_migrate::restore_ssldir privatekey=</PATH/TO/PRIVATEKEY> targetdir=</DIR/ON/TARGETHOST> targethost=<NEW PRIMARY SERVER FQDN> --nodes <PRIMARY SERVER FQDN>
```

#### **Step Five: Install PE**

1.  On the new primary server, [install PE 2019.2](https://puppet.com/misc/pe-files/previous-releases/2019.2.1/).

#### **Step Six: Restore the databases and classifier data.**

On the new primary server, manually run the following bash script:

```
cd </path/to/backupdir>

bash restore_databases.sh
```

#### **Step Seven: (Optional) Deactivate and clear certificates on your old infrastructure nodes.**

This step is not required for the migration, but completing it deactivates infrastructure nodes in PuppetDB, deletes the old primary server's information cache, frees up licenses, and allows you to reuse hostnames on new nodes.

**Warning:** If your old primary server and the new primary server have the same certificate name, **do not complete this step**; it will delete your new primary server.

1.  On the new primary server, run the following command:

    `puppet node purge <OLD PRIMARY SERVER CERTNAME> ; find /etc/puppetlabs/puppet/ssl -name <OLD PRIMARY SERVER CERTNAME>.pem -delete`

#### **Step Eight: Manually migrate configuration files, Puppet code, and Hiera data.**

Your deployment determines the specifics of how to migrate your configuration files, Puppet code, and Hiera data.

Common steps include:

*   Edit `puppet.conf` to add customizations from your old deployment on the new primary server.

*   If you use Code Manager or r10k, configure Code Manager or r10k to deploy code on the new primary server.

*   If you don't use Code Manager or r10k, copy the contents of the code directory `/etc/puppetlabs/code/` to the new primary server.

*   Move your Hiera data and copy your old `hiera.yaml` file to `/etc/puppetlabs/puppet/hiera.yaml` on the new primary server.

*   Copy classification customizations to the new installation.

#### **Step Nine: Configure your agents and regenerate compiler certificates.**

Configure your new agents and compilers:

1.  Point the agents at the new primary server. On each agent, update `puppet.conf`: `puppet config set server <NEW PRIMARY SERVER FQDN>` You can automate this step by running the following task against your PE Agent node group from your old primary server. Please note the PE Agent node group id can be found in the PE console under _Node Groups -> PE Agent -> Activity -> The ID will be in the very first entry._

```
puppet task run pe_migrate::agent_migrate newprimary=<NEW PRIMARY FQDN> --node-group <PE-Agent node-group-id>
```

2.  Regenerate certs for all compilers using our documentation for [PE 2019.2](https://puppet.com/docs/pe/2019.2/regenerate_certificates.html), making sure to include `--allow-dns-alt-names` when signing the compiler's certificate request.

3.  Upgrade your compilers to the same version as your new primary server. SSH into each compiler and run:

    `/opt/puppetlabs/puppet/bin/curl --cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem https://<PRIMARY SERVER FQDN>:8140/packages/current/upgrade.bash | sudo bash`

4.  If you migrated to a newer version of PE, [upgrade the agent nodes](https://puppet.com/docs/pe/2019.2/upgrading_agents.html).

---
