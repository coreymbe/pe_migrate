#!/bin/sh
# Puppet Task Name: puppet_backup

# Create a Puppet Backup

set -e

BACKUP_DIR=$PT_backupdir
PUPPET_BIN_DIR=/opt/puppetlabs/bin
PE_SERVER_VERSION=$(/usr/local/bin/facter -p pe_server_version)

${PUPPET_BIN_DIR}/puppet-backup create --dir=${BACKUP_DIR} --name pe_migrate-${PE_SERVER_VERSION}_backup.tgz
