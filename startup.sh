#!/bin/bash

# Generate the geoserver_startup.sh ----------------------------------------------------------------------#
python /tmp/gen_runtime_dynamic_files.py

# Set HIS user ID and permissions ------------------------------------------------------------------------#
usermod -u $IRODS_ID gsapp
setfacl -Rm u:gsapp:rwX,d:u:gsapp:rwX /var/geoserver

# Start with supervisor ----------------------------------------------------------------------------------#
/usr/bin/supervisord -c $GEOSERVER_HOME/supervisord.conf