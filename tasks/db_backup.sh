#!/bin/sh
#Puppet Task Name: db_backup

# Backup DB Task

set -e

BASE_BACKUP_DIR=$PT_backupdir
DB_BACKUP=${BASE_BACKUP_DIR}/database
PUPPET_BIN_DIR="/opt/puppetlabs/bin"
PUPPET_VERSION=$("${PUPPET_BIN_DIR?}/puppet" --version)

if [[ ${PUPPET_VERSION%%.*} -ge 6 ]]
  then
    PUPPET_6=true
  else
    PUPPET_6=false
fi

if [ ${PUPPET_6} = false ]

  then
    mkdir -p $DB_BACKUP
    cd $DB_BACKUP
    chown pe-postgres:pe-postgres $DB_BACKUP

    for db in pe-activity pe-classifier pe-orchestrator pe-puppetdb pe-rbac
      do echo "Backing up $db" ; sudo -u pe-postgres /opt/puppetlabs/server/bin/pg_dump -Fc $db -f $db.backup.bin
    done
    printf 'DB Dump Successful \n'

  else
    printf 'This task is not compatible with this version of Puppet Enterprise. Run pe_migrate::puppet_backup -> pe_migrate::backup_transfer -> pe_migrate::puppet_restore. \n'

fi
