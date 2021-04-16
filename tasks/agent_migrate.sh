#!/bin/sh
# Puppet Task Name: agent_migrate

NEW_PRIMARY=$PT_newprimary

set -e

if [[ $(/opt/puppetlabs/bin/facter -p pe_server_version) < 2019 ]]

  then
  	puppet config set server $NEW_PRIMARY
  	printf "server puppet.conf parameter updated to %s \n" "$NEW_PRIMARY"

  else
  	printf 'The tasks provided in this module are not compatible with this version of Puppet Enterprise. \n'

fi
