#!/bin/sh
# Restore Databases

chown -R pe-postgres:pe-postgres database/

for svc in puppet pe-puppetserver pe-puppetdb pe-console-services pe-nginx pe-activemq pe-orchestration-services pxp-agent
  do echo "Stopping $svc" ; puppet resource service $svc ensure=stopped
done

for db in pe-activity pe-classifier pe-orchestrator pe-puppetdb pe-rbac
  do echo "Restoring $db" ; sudo -u pe-postgres /opt/puppetlabs/server/bin/pg_restore -Cc database/$db.backup.bin -d template1
done

/opt/puppetlabs/bin/puppet-infrastructure configure
