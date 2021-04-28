#!/bin/sh
# Puppet Task Name: ssl_backup

# Backup SSLDIR Task

set -e

BASE_BACKUP_DIR=$PT_backupdir
SSL_BACKUP=${BASE_BACKUP_DIR}/ssl
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
  	mkdir -p $SSL_BACKUP
  	tar -czf ${SSL_BACKUP}/puppet_ssl.tar.gz /etc/puppetlabs/puppet/ssl
  	printf 'Backup of SSLDIR successful! \n'
  else
    printf 'This task is not compatible with this version of Puppet Enterprise. Run pe_migrate::puppet_backup -> pe_migrate::backup_transfer -> pe_migrate::puppet_restore. \n'

fi
