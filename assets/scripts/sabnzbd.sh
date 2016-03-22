#!/bin/bash

# Display settings on standard out.

USER="sabnzbd"

echo "SABnzbd settings"
echo "=================="
echo
echo "  User:       ${USER}"
echo "  UID:        ${SAB_UID:=666}"
echo "  GID:        ${SAB_GID:=666}"
echo
echo "  DATADIR:    ${DATADIR:=/data/sabnzbd}"
echo "  CONFIG:     ${CONFIG:=${DATADIR}/sabnzbd.ini}"
echo

# Change UID / GID of SABnzbd user.
printf "Updating sabnzbd user... "
SBEARD=$(id -u sabnzbd 2> /dev/null)
if [ $? -eq 0 ]; then
  if [ ${SBEARD} != ${SAB_UID} ]; then
    groupmod -u ${SAB_GID} ${USER}
    usermod -u ${SAB_UID} ${USER}
  fi
else
  groupadd -r -g ${SAB_GID} ${USER}
  useradd -r -u ${SAB_UID} -g ${SAB_GID} -d /sabnzbd ${USER}
fi
echo "[DONE]"

if [ ! -f ${CONFIG} ]; then
  echo "[ERROR] Unable to find ${CONFIG}"
  exit 1
fi

# Set directory permissions.
printf "Set permissions for /sabnzbd... "
if [[ $(stat -c "%u" /sabnzbd/) -ne ${SAB_UID} && \
      $(stat -c "%g" /sabnzbd/) -ne ${SAB_GID} ]]; then
  chmod 2755 /sabnzbd
  chown -R ${USER}: /sabnzbd
fi
echo "[DONE]"

printf "Set permissions for ${DATADIR}... "
if [[ $(stat -c "%u" ${DATADIR}/) -ne ${SAB_UID} && \
      $(stat -c "%g" ${DATADIR}/) -ne ${SAB_GID} ]]; then
  chown ${USER}: ${DATADIR}
fi
echo "[DONE]"


# Finally, start SABnzbd.
echo "Starting SABnzbd..."
exec su -pc "/sabnzbd/SABnzbd.py -f ${CONFIG}" ${USER}
