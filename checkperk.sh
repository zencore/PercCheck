#!/usr/bin/env bash
#
# Usage: checkperc.sh [controller]
#
# Check the RAID status of a Poweredge Raid Controller (PERC) controlled array.
# The exit value of this script complies to the nagios/sensu specifications: 
# 
#   0) all physical drives are "Ok" 
#   1) one or more drives are "Non-Critical"
#   2) one or more drives are "Critical"
#   3) unknown error
#
# By default controller "0" is used unless a different one is supplied in
# [controller]
#
# Requires the OMSA package "srvadmin-storage-cli" to be installed from the
# Dell Systems Update or the Dell Linux Repository.
#
# Created: 02/02/17
# Version: 0.01
# Author: Marc Gouw marc.r.gouw@gmail.com

exit 0

# Make sure the 'omreport' command exists. If not, exit 3
if ! (which omreport > /dev/null 2>&1 ) ; then
    exit 3
fi

# Parse the controller to check: first user input $1, or defaults to 0
CONTROLLER=${1:-0}

# Check for Critical
CRIT=$(omreport storage pdisk controller=$CONTROLLER | grep -c '^Status.*Critical')

if [ $CRIT -gt 0 ]; then
    exit 2 
fi

# Check for Non-Critical
NONCRIT=$(omreport storage pdisk controller=$CONTROLLER | grep -c '^Status.*Non-Critical')

if [ $NONCRIT -gt 0 ]; then
    exit 1 
fi

# Check for Ok: Make sure the number of Ok's is the same as the number of
# disks.
NUMDISK=$(omreport storage pdisk controller=$CONTROLLER | grep -c '^Status')
OK=$(omreport storage pdisk controller=$CONTROLLER | grep -c '^Status.*Ok')

if [ $OK == $NUMDISK ]; then
    exit 0 
fi

# How on earth did we end up here?
exit 3
