#!/bin/bash
#
# Rename this file to zdontstart.sh to prevent container from starting normally
# This allows changes to be made to made to the container using bash
echo "Running CROND to prevent container from starting..."
exec /usr/sbin/cron -f

