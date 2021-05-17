#!/bin/sh
# Puppet Task Name: agent_migrate

TARGET_HOST=$PT_targethost
CLEAN_HOST=$PT_cleanhost
PUPPET_BIN_DIR=/opt/puppetlabs/bin

if [$CLEAN_HOST = true ]

  then
    ${PUPPET_BIN_DIR}/puppet ssl clean

fi

${PUPPET_BIN_DIR}/puppet config set server $TARGET_HOST

if [ $? -ne 0 ]

  then
    printf "Failed to update 'server' parameter in puppet.conf. \n"
  else
    printf "The puppet.conf 'server' parameter was updated to %s. \n" "$TARGET_HOST"

fi
