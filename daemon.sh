#!/bin/bash

HERE=$(cd $(dirname $0) ; pwd )

. $(HERE)/config.env

echo $$ >${LOOKUP_FOLDER}/sshor.pid

function connect_to_remote() {
  IP=$1
  PORT=$(expr  $RANDOM % 5000 + 1024)
  ssh -fN -i ~/.ssh/sshor -R ${PORT}:localhost:22 ${IP}
  echo $! >${LOOKUP_FOLDER}/connection.pid
  echo 'ssh -i ~/.ssh/sshor -p ${PORT} -L ${LOCAL_PORT}:localhost:${REMOTE_PORT} localhost' >${LOOKUP_FOLDER}/bridge.sh
}

while [ ${MAX_ITERATION} -gt 0 ] ; do
  f=$(find ${LOOKUP_FOLDER} -name 'connect')
  if [ -n "${f}" ] ; then
    IP=head -1 ${f}
    rm -f ${f}
    connect_to_remote ${IP}
  fi
  f=$(find ${LOOKUP_FOLDER} -name 'kill')
  if [ -n "${f}" ] ; then
    kill -QUIT $(cat ${LOOKUP_FOLDER}/connection.pid)
    rm -f ${LOOKUP_FOLDER}/connection.pid
  fi
  sleep $SLEEP_DELAY
done

# relaucn itself to avoid long living daemon leaking resources
/bin/bash -c ${HERE}/$0 &
