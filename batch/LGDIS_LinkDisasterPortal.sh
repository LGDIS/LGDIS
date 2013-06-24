#!/bin/sh
# Batch command script.
#
# bundle exec rails runner Batches::LinkDisasterPortal.execute -e production

APP_NAME="LGDIS"
APP_NAMEn=`echo ${APP_NAME}| tr "[:upper:]" "[:lower:]"`
APP_ROOT="/home/rails/${APP_NAME}"
ENV="production"

PROG="bundle exec"
RAILS_COMMAND="rails runner Batches::LinkDisasterPortal.execute"

RVMDIR="/usr/local/rvm/environments"
RUBYSET="ruby-1.9.3-p392@${APP_NAMEn}"
RVMENV=${RVMDIR}/${RUBYSET}

LOCK="$APP_ROOT/tmp/`basename $0`.lock"

#source function library.
. /etc/rc.d/init.d/functions

#to syslog
LOGGER="/usr/bin/logger -t ${APP_NAME} -i"
ERRMSG="`basename $0`: command error"

#rvm environment
if [[ -s "${RVMENV}" ]]
then
  source "${RVMENV}"
else
  echo "ERROR: Missing RVM environment file: '${RVMENV}'" >&2
  exit 1
fi

cd ${APP_ROOT} || exit 1

check(){
  if [ -e ${LOCK} ]; then
      echo `basename $0` is already running. | $LOGGER
      return 1
  else
      touch ${LOCK}
  fi
} 

command(){
  CMD="${PROG} ${RAILS_COMMAND} -e ${ENV}"
  cd ${APP_ROOT}
  echo $"Call ${APP_NAME}: ${CMD}" 
  ${CMD} 2>&1  
  if [ ! $? -eq 0 ]; then
    echo ${ERRMSG}
  fi
  rm ${LOCK}
}

check  
[ ! $? -eq  0 ] && exit 1
command 2>&1 | $LOGGER
