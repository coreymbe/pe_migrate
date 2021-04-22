#!/bin/sh
# Puppet Task Name: puppet_backup

# Create a Puppet Backup

set -e

BACKUP_DIR=$PT_backupdir
PE_SERVER_VERSION=$(/usr/local/bin/facter -p pe_server_version)

/opt/puppetlabs/bin/puppet-backup create --dir=${BACKUP_DIR} --name pe_migrate-${PE_SERVER_VERSION}_backup.tgz
