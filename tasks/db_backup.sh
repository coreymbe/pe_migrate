#!/bin/sh
# Puppet Task Name: db_backup

# Backup DB Task

set -e

BASE_BACKUP_DIR=$PT_backupdir
DB_BACKUP=${BASE_BACKUP_DIR}/database

if [[ $(/opt/puppetlabs/bin/facter -p pe_server_version) < 2019 ]]

  then
    mkdir -p $DB_BACKUP
    cd $DB_BACKUP
    chown pe-postgres:pe-postgres $DB_BACKUP

    for db in pe-activity pe-classifier pe-orchestrator pe-puppetdb pe-rbac
      do echo "Backing up $db" ; sudo -u pe-postgres /opt/puppetlabs/server/bin/pg_dump -Fc $db -f $db.backup.bin
    done
    printf 'DB Dump Successful \n'

  else
  	printf 'The tasks provided in this module are not compatible with this version of Puppet Enterprise. \n'

fi
