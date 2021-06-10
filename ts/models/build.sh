
PACKAGE_NAME="@aicpa-ads/auditdata-model"
SHARED_TYPES=( )
MODEL_PACKAGE_PATH="models"

declare -A MODEL_PACKAGE=( ["gl"]="gl" ["ar"]="ar" ["ent"]="entity" ["combined"]="" )

setup_build_folder() {
    rm -rf "$BUILD_DIR/$LANG-models/combined/"
}

convert_spec () {
    mkdir -p "$BUILD_DIR/$LANG-models/$1"
    cp "$LANG/models/generator-template/.openapi-generator-ignore" "$BUILD_DIR/$LANG-models/$1/"
    rm -rf "$BUILD_DIR/$LANG-models/$1/$MODEL_PACKAGE_PATH"
    java -jar ./openapi-generator-cli.jar generate -i "$SPEC_LOCATION/$2" -g typescript -t "$LANG/models/generator-template" \
        -c "$LANG/models/config.yaml" -o "$BUILD_DIR/$LANG-models/$1" --additional-properties=npmVersion=$PACKAGE_VERSION,npmName=$3
        #,modelPackage=$4
    
    if [ $1 != "combined" ] ; then
        for file in "$BUILD_DIR/$LANG-models/$1/$MODEL_PACKAGE_PATH"/*.ts ; do
            for type in "${SHARED_TYPES[@]}" ; do
                type=${type%.ts}
                str="from '\.\/$type'"
                subst="from '\.\.\/$type'"
                #echo "s/$str/$subst/g"
                sed -i "s/$str/$subst/g" "$file"
            done
        done

        fld="${MODEL_PACKAGE[$1]}"
        mkdir "$BUILD_DIR/$LANG-models/$1/$MODEL_PACKAGE_PATH/$fld"
        mv "$BUILD_DIR/$LANG-models/$1/$MODEL_PACKAGE_PATH"/*.ts "$BUILD_DIR/$LANG-models/$1/$MODEL_PACKAGE_PATH/$fld"
    fi
}

post_model_creation_cleanup(){
    find $1 -maxdepth 1 -type f ! -name 'index.ts' -printf 'export * from "./%f"\n' |  sed "s/\.ts//" > $1/index.ts 
}

post_conversion_cleanup () {
    post_model_creation_cleanup "$BUILD_DIR/$LANG-models/combined/$MODEL_PACKAGE_PATH/"

    mv "$BUILD_DIR/$LANG-models/combined/$MODEL_PACKAGE_PATH"/* "$BUILD_DIR/$LANG-models/combined/"
}

get_generated_model_package_name(){
    #echo "Calculating $1"
    basename $1 
}

## Build Models
build_package() {   
    mkdir -p "dist/js" 
    pushd "$BUILD_DIR/$LANG-models/combined"
    npm i && npm run build \
        && cd dist && npm pack
    popd
    mv "$BUILD_DIR/$LANG-models/combined/dist"/*.tgz "dist/js"
}

