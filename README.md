# PercCheck

A simple nagios/sensu compatible script to check the status of a PERC
controlled RAID array, used on most Dell Poweredge systems.

## Usage

```bash
checkperc.sh [controller]
```

Check the RAID status of a Poweredge Raid Controller (PERC) controlled array.
The exit value of this script complies to the nagios/sensu specifications: 

0. all physical drives are "Ok" 
1. one or more drives are "Non-Critical"
2. one or more drives are "Critical"
3. unknown error

By default controller "0" is used unless a different one is supplied in
_[controller]_

Requires the OMSA package *srvadmin-storage-cli* to be installed from the
[Dell Systems Update][dsu_repo] or the [Dell Linux Repository][dlr_repo].

[dsu_repo]: https://linux.dell.com/repo/hardware/dsu/
[dlr_repo]: http://linux.dell.com/repo/hardware/


