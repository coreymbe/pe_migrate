#!/bin/sh
# Puppet Task Name: puppet_restore

# Restore Puppet Backup

TARGET_DIR=$PT_targetdir
TARGET_HOST=$PT_targethost
SSH_PRIVKEY=$PT_privatekey
PUPPET_BIN_DIR=/opt/puppetlabs/bin
BOLT=${PUPPET_BIN_DIR}/bolt
FACTER=/usr/local/bin/facter

$BOLT command run ""$PUPPET_BIN_DIR"/puppet-backup restore "$PT_targetdir"/pe_migrate-$($FACTER -p pe_server_version)_backup.tgz --force" --targets "$PT_targethost" --tty --user root --no-host-key-check --private-key "$PT_privatekey"

