#!/bin/sh
# Puppet Task Name: backup_transfer

# Transfer Backup Task

BASE_BACKUP_DIR=$PT_backupdir
TARGET_HOST=$PT_targethost
TARGET_DIR=$PT_targetdir
PE_ENVIRONMENT=$PT_environment

cp /etc/puppetlabs/code/environments/"$PT_environment"/modules/pe_migrate/files/restore_databases.sh "$PT_backupdir"

rsync -ave 'ssh -o StrictHostKeyChecking=no' "$PT_backupdir"/* root@"$PT_targethost":"$PT_targetdir"
