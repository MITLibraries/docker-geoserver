#!/usr/bin/env bash

USERS=$GEOSERVER_DATA_DIR/security/usergroup/default/users.xml
S3_PROPERTIES=$GEOSERVER_DATA_DIR/s3.properties

envsubst < $USERS.tmpl > $USERS
envsubst < $S3_PROPERTIES.tmpl > $S3_PROPERTIES

exec "$@"
