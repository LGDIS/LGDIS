#!/bin/sh
#  input-tools archivelog delete script.
#

USER="rails"
APP_NAME="`basename $0`"
CACHE_PASS="/home/rails/LGDIS/tmp/cache/"

#to syslog
LOGGER="/usr/bin/logger -t ${APP_NAME} -i"
ERRMSG="`basename $0`: command error"

#source function library.
. /etc/rc.d/init.d/functions

if [ $UID -eq 0 ]; then
    abspath=$(cd $(dirname $0); pwd)/$(basename $0)
    exec su - $USER $abspath "$@"
    false
fi

check() {
  cd ${CACHE_PASS} || exit 1 
  find .  -name "*" -type f -daystart -mtime +13 
}

command(){
  cd ${CACHE_PASS} || exit 1
  find .  -name "*" -type f -daystart -mtime +13 | xargs rm -rf 
  if [ ! $? -eq 0 ]; then
    echo ${ERRMSG}
  fi
}

case "$1" in

  start)
    command 2>&1 | $LOGGER 
    ;;
  check)
    check 
    ;;
  *)
    echo "Usage: ${APP_NAME} {start|check}" >&2
    exit 1
    ;;

esac

