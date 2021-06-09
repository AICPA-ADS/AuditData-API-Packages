#!/usr/bin/env bash
LANG=${1:-cs}
SPEC=${2:-master}
PACKAGE_VERSION=${3:-0.0.0}
BUILD_DIR=${4:-build}

source generator-funcs.sh
source "$LANG/client/build.sh"

init_generator 
download_spec

## Init build directories
mkdir -p "$BUILD_DIR/$LANG-client"
setup_build_folder

convert_spec "combined" "/AuditDataStandard.yml" "$PACKAGE_NAME" 

post_conversion_cleanup

mkdir -p "dist/$LANG"
build_package 