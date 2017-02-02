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

# Hardcode omreport path (typically not part of 'sensu's path).
OMREPORT="/opt/dell/srvadmin/bin/omreport"

# Make sure the 'omreport' command exists and is executable. If not, exit 3
CRIT=$($OMREPORT storage pdisk controller=$CONTROLLER | grep -c '^Status.*Critical')
if [ ! -x  $OMREPORT ] ; then
    echo "'omreport' not found, or is not executable."
    exit 3
fi

# Parse the controller to check: first user input $1, or defaults to 0
CONTROLLER=${1:-0}

# Check for Critical
CRIT=$($OMREPORT storage pdisk controller=$CONTROLLER | grep -c '^Status.*Critical')

if [ $CRIT -gt 0 ]; then
    echo "PERC CRITICAL: One or more disks needs IMMEDIATE replacing"
    exit 2 
fi

# Check for Non-Critical
NONCRIT=$($OMREPORT storage pdisk controller=$CONTROLLER | grep -c '^Status.*Non-Critical')

if [ $NONCRIT -gt 0 ]; then
    echo "PERC Non-Critical: One or more disks need checking"
    exit 1 
fi

# Check for Ok: Make sure the number of Ok's is the same as the number of
# disks.
NUMDISK=$($OMREPORT storage pdisk controller=$CONTROLLER | grep -c '^Status')
OK=$($OMREPORT storage pdisk controller=$CONTROLLER | grep -c '^Status.*Ok')

if [ $OK == $NUMDISK ]; then
    echo "PERC Ok: All $OK disks on controller $CONTROLLER are Ok" 
    exit 0
fi

# How on earth did we end up here?
echo "Unexpexted end of script reached. Something is wrong"
exit 3
