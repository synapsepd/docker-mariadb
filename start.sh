#!/bin/bash
# Starts up MariaDB within the container.

# Stop on error
set -e

DATADIR="/data"

# test if DATADIR has content
if [ ! "$(ls -A $DATADIR)" ]; then
    echo "Initializing MariaDB at $DATADIR"
    # Copy the data that we generated within the container to the empty DATADIR.
    cp -R /var/lib/mysql/* $DATADIR
fi

# Ensure mysql owns the DATADIR
chown -R mysql $DATADIR
chown root $DATADIR/debian*.flag

# Start MariaDB
echo "Starting MariaDB..."
/usr/bin/mysqld_safe
sleep 2
/bin/bash &
