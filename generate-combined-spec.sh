#!/usr/bin/env bash
SPEC=${2:-master}
PACKAGE_VERSION=${3:-0.0.0}

LANG=oas

source generator-funcs.sh

init_generator 
download_spec

java -jar ./openapi-generator-cli.jar generate -i "$SPEC_LOCATION/AuditDataStandard.yml" -g openapi  \
        -c "$LANG/config.yaml" -o "dist/$LANG"

cp -r "$LANG/swagger-ui/"* "dist/$LANG"