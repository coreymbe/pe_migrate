#!/bin/sh
# Puppet Task Name: ssl_backup

# Backup SSLDIR Task

set -e

BASE_BACKUP_DIR=$PT_backupdir
SSL_BACKUP=${BASE_BACKUP_DIR}/ssl

if [[ $(/opt/puppetlabs/bin/facter -p pe_server_version) < 2019 ]]

  then
  	mkdir -p $SSL_BACKUP
  	tar -czf ${SSL_BACKUP}/puppet_ssl.tar.gz /etc/puppetlabs/puppet/ssl
  	printf 'Backup of SSLDIR successful! \n'

  else
  	printf 'The tasks provided in this module are not compatible with this version of Puppet Enterprise. \n'

fi
