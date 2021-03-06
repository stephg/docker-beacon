#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo usage: $(basename $0) [dest]
  exit 1
fi

set -e
CONFIG="$1"

SERVICE_VAR=SERVICES
SERVICE_HOSTNAME=$(hostname -f)
SERVICE_HEARTBEAT=${BEACON_SERVICE_HEARTBEAT:-30}
SERVICE_TTL=${BEACON_SERVICE_TTL:-30}
DOCKER_URI=${BEACON_DOCKER_URI:-http://172.17.42.1:5001}
ETCD_URI=${BEACON_ETCD_URI:-http://172.17.42.1:4001}
ETCD_PREFIX=${BEACON_ETCD_PREFIX:-beacon}
LOG_LEVEL=${BEACON_LOG_LEVEL:-NOTICE}

test -n "$BEACON_SERVICE_VAR" && SERVICE_VAR="$(echo $BEACON_SERVICE_VAR | tr 'a-z\-\ ' 'A-Z__')"
test -n "$BEACON_SERVICE_HOSTNAME" && SERVICE_HOSTNAME="$BEACON_SERVICE_HOSTNAME"
test "$BEACON_LOG_SYSLOG" == false && LOG_SYSLOG=false || LOG_SYSLOG=true
test "$BEACON_LOG_CONSOLE" == true && LOG_CONSOLE=true || LOG_CONSOLE=false

mkdir -p "$(dirname $CONFIG)"
cat > "$CONFIG" <<EOF
--- # generated by $(basename $0)

service:
  var: $SERVICE_VAR
  hostname: $SERVICE_HOSTNAME
  heartbeat: $SERVICE_HEARTBEAT
  ttl: $SERVICE_TTL

docker:
  uri: $DOCKER_URI

etcd:
  uri: $ETCD_URI
  prefix: $ETCD_PREFIX

logging:
  syslog: $LOG_SYSLOG
  console: $LOG_CONSOLE
  level: $LOG_LEVEL

...
EOF

exec /usr/share/go/bin/beacon -config "$CONFIG"
