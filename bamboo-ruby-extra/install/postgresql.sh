#!/bin/bash

#
# PostgreSQL 9.3
#

PG_VERSION=9.3

# Install from apt.postgresql.org
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list
wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
apt-get update && apt-get -y install postgresql-$PG_VERSION postgresql-server-dev-$PG_VERSION

# Recreate cluster with UTF-8 encoding
/etc/init.d/postgresql stop
pg_dropcluster --stop $PG_VERSION main
pg_createcluster --start -e UTF-8 $PG_VERSION main
/etc/init.d/postgresql start

# Create user 'bamboo' with random password
PASS=`date +%s | sha256sum | base64 | head -c 32 ; echo`
echo "CREATE USER $BAMBOO_USER WITH CREATEDB CREATEUSER PASSWORD '$PASS';" | su postgres -c psql

# Create default database
echo "CREATE DATABASE $BAMBOO_USER OWNER $BAMBOO_USER" | su postgres -c psql

# Don't ask for password
# See http://www.postgresql.org/docs/9.3/interactive/libpq-pgpass.html
echo "localhost:5432:*:$BAMBOO_USER:$PASS" > $BAMBOO_HOME/.pgpass
chmod 0600 $BAMBOO_HOME/.pgpass
chown $BAMBOO_USER:nogroup $BAMBOO_HOME/.pgpass

# Clean stop
/etc/init.d/postgresql stop

