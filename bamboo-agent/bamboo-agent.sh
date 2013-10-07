#!/usr/bin/env bash

set -e # Exit on errors

echo "-> Starting Bamboo Agent ..."
echo "   - BAMBOO_USER:   $BAMBOO_USER"
echo "   - BAMBOO_HOME:   $BAMBOO_HOME"
echo "   - BAMBOO_SERVER: $BAMBOO_SERVER"

BAMBOO_INSTALLER=$BAMBOO_HOME/bamboo-agent-installer.jar
if [ -f $BAMBOO_INSTALLER ]; then
  echo "-> Installer already found at $BAMBOO_INSTALLER. Skipping download."
else
  BAMBOO_INSTALLER_URL=$BAMBOO_SERVER/agentServer/agentInstaller
  echo "-> Downloading installer from $BAMBOO_INSTALLER_URL ..."
  wget --progress=dot:mega $BAMBOO_INSTALLER_URL -O $BAMBOO_INSTALLER
fi

# Fix permissions
chown -R $BAMBOO_USER:nogroup $BAMBOO_HOME

echo "-> Running Bamboo Installer ..."
su - $BAMBOO_USER -c "java -Dbamboo.home=$BAMBOO_HOME -jar $BAMBOO_INSTALLER $BAMBOO_SERVER/agentServer/" &

# Kill Bamboo process on signals from supervisor
trap 'kill `cat $BAMBOO_HOME/bin/bamboo-agent.pid`' SIGINT SIGTERM EXIT

# Wait for Bamboo process to terminate
wait $(jobs -p)
~
