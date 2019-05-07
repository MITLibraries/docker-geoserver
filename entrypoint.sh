#!/bin/sh

USERS=$GEOSERVER_DATA_DIR/security/usergroup/default/users.xml
S3_PROPERTIES=$GEOSERVER_DATA_DIR/s3.properties

cp -rf $GEOSERVER_HOME/data_dir/* $GEOSERVER_DATA_DIR
envsubst < $USERS.tmpl > $USERS
envsubst < $S3_PROPERTIES.tmpl > $S3_PROPERTIES

exec "$@"
