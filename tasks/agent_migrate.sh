#!/bin/sh
# Puppet Task Name: agent_migrate

TARGET_HOST=$PT_targethost
PUPPET_BIN_DIR=/opt/puppetlabs/bin

${PUPPET_BIN_DIR}/puppet config set server $TARGET_HOST

if [ $? -ne 0 ]

  then
    printf "Failed to update 'server' parameter in puppet.conf. \n"
  else
    printf "The puppet.conf 'server' parameter was updated to %s. \n" "$TARGET_HOST"

fi
