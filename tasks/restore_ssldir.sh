#!/bin/sh
# Puppet Task Name: restore_ssldir

# Restore SSLDIR Task

TARGET_DIR=$PT_targetdir
TARGET_HOST=PT_targethost
SSH_PRIVKEY=PT_privatekey
bolt=/opt/puppetlabs/bin/bolt

$bolt command run "mkdir -p /etc/puppetlabs/puppet && tar -xzf "$PT_targetdir"/ssl/puppet_ssl.tar.gz -C / && current_serial_num=$(cat /etc/puppetlabs/puppet/ssl/ca/serial) ; printf "%04X" $(( 16#${current_serial_num} + 1000 )) > /etc/puppetlabs/puppet/ssl/ca/serial" --targets "$PT_targethost" --tty --user root --no-host-key-check --private-key "$PT_privatekey"
