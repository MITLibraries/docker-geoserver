#!/usr/bin/env bash

USERS=$GEOSERVER_DATA_DIR/security/usergroup/default/users.xml

envsubst < $USERS.tmpl > $USERS

exec "$@"
