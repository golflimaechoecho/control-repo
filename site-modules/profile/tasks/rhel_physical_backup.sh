#!/bin/sh
LOCAL_BACKUP_PATH=${PT_local_backup_path:-/opt}
REMOTE_USER=${PT_remote_user:-pmadmin1}
REMOTE_HOST=${PT_remote_host:?"ERROR: remote_host is required"}
REMOTE_DIR=${PT_remote_dir:-/opt/simpana}

# CLI_NOOP checks if --noop passed on CLI
# GUI_NOOP checks if noop param passed (as --noop currently can't pass via GUI)
CLI_NOOP=${PT__noop:-false}
GUI_NOOP=${PT_noop:-false}

if [ "${GUI_NOOP}" == "true" -o "${CLI_NOOP}" == "true" ]; then
  NOOP=true
else
  NOOP=false
fi

HOSTNAME=$(hostname)
BACKUP_DIR="${LOCAL_BACKUP_PATH}/${HOSTNAME}"
FILESYSTEM_LIST="/usr /var /home /etc /root /boot"

[ -d ${BACKUP_DIR} ] || {
  [ "${NOOP}" == "true" ] && {
    echo "NOOP: would have run: mkdir -p ${BACKUP_DIR}"
  } || {
    mkdir -p ${BACKUP_DIR}
  }
}

# DO NOT ENCLOSE FILESYSTEM_LIST in quotes in this instance
for FILESYSTEM in ${FILESYSTEM_LIST}; do
  [ "${NOOP}" == "true" ] && {
    echo "NOOP: would have run: tar cvzf ${BACKUP_DIR}/tar-${HOSTNAME}-${FILESYSTEM##*/}.tar.gz --one-file-system --exclude=*.iso ${FILESYSTEM}"
  } || {
    tar cvzf ${BACKUP_DIR}/tar-${HOSTNAME}-${FILESYSTEM##*/}.tar.gz --one-file-system --exclude=*.iso ${FILESYSTEM}
  }
done

# below assumes connectivity, ssh keys in place
[ "${NOOP}" == "true" ] && {
  echo "NOOP: would have run: scp -r ${BACKUP_DIR} ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"
} || {
  scp -r ${BACKUP_DIR} ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/
}
