#! /bin/bash

######### DEPLOYMENT CONFIG ############
# Setup your application deployment here
########################################

# Main version number we are tagging the app with. Always update
# this when you cut a new version of the app!
APP_VERSION=v1.0.0

# Keycloak
KC_TAG=21.1.2
KC_HOSTNAME=auth.library.ucdavis.edu
KC_HOST_PORT=3122
#KC_HOSTNAME=sandbox.auth.library.ucdavis.edu
#KC_HOST_PORT=3123

# Postgres
POSTGRES_TAG=15.3

# Utils
NODE_TAG=20

# local dev settings
LOCAL_DEV_DIRECTORY=keycloak-local-dev
KC_LOCAL_DEV_HOST_PORT=3000
KC_ADMIN_USERNAME=admin
KC_ADMIN_PASSWORD=admin
ADMINER_TAG=4.8.1
ADMINER_HOST_PORT=8080
