#!/bin/sh
# Puppet Task Name: puppet_restore

# Restore Puppet Backup

TARGET_DIR=$PT_targetdir
TARGET_HOST=$PT_targethost
SSH_PRIVKEY=$PT_privatekey
bolt=/opt/puppetlabs/bin/bolt
facter=/usr/local/bin/facter

$bolt command run "/opt/puppetlabs/bin/puppet-backup restore "$PT_targetdir"/pe_migrate-$($facter -p pe_server_version)_backup.tgz --force" --targets "$PT_targethost" --tty --user root --no-host-key-check --private-key "$PT_privatekey"
