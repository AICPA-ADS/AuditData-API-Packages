#!/usr/bin/env bash
LANG=${1:-cs}
SPEC=${2:-master}
PACKAGE_VERSION=${3:-0.0.0}
BUILD_DIR=${4:-build}

source generator-funcs.sh
source "$LANG/models/build.sh"

init_generator 
download_spec

## Init build directories
mkdir -p "$BUILD_DIR/$LANG-models"
setup_build_folder

TOP_SHARED_TYPES=($(awk -v ext="$LANG" -e '/^\w+:$/ {print substr($1, 1, length($1)-1 ) "." ext}' "$SPEC_LOCATION/shared/schemas/index.yml"))
SHARED_TYPES+=( "ErrorResult.$LANG" ${TOP_SHARED_TYPES[@]} )

#echo "${SHARED_TYPES[@]}"

convert_spec "gl" "GL/index.yml" "$PACKAGE_NAME" "${MODEL_PACKAGE[gl]}" 
convert_spec "ar" "AR/index.yml" "$PACKAGE_NAME" "${MODEL_PACKAGE[ar]}"
convert_spec "ent" "Entities/index.yml" "$PACKAGE_NAME" ${MODEL_PACKAGE[ent]}
convert_spec "combined" "/AuditDataStandard.yml" "$PACKAGE_NAME" ${MODEL_PACKAGE[combined]}

arr=("$BUILD_DIR/$LANG-models/ar/$MODEL_PACKAGE_PATH/${MODEL_PACKAGE[ar]}" "$BUILD_DIR/$LANG-models/gl/$MODEL_PACKAGE_PATH/${MODEL_PACKAGE[gl]}" "$BUILD_DIR/$LANG-models/ent/$MODEL_PACKAGE_PATH/${MODEL_PACKAGE[ent]}")
for i in "${arr[@]}"
do
    echo "Processing model: $i"
    rm_shared_types "$i"
    for file in "$i"/* ; do  
        #echo "$BUILD_DIR/$LANG-models/combined/$MODEL_PACKAGE_PATH/Model/$(basename -- $file)"
        rm "$BUILD_DIR/$LANG-models/combined/$MODEL_PACKAGE_PATH/${MODEL_PACKAGE[combined]}/$(basename -- $file)" 
    done

    post_model_creation_cleanup "$i"

    genPackageName=$(get_generated_model_package_name "$i")
    #echo "genPackageName: $genPackageName"
    mv "$i" "$BUILD_DIR/$LANG-models/combined/$MODEL_PACKAGE_PATH/${MODEL_PACKAGE[combined]}/$genPackageName"
done

post_conversion_cleanup

mkdir -p "dist/$LANG"
build_package 
