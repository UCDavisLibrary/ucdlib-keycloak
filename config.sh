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
