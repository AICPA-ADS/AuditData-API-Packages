
PACKAGE_NAME="@aicpa-ads/auditdata-client"
MODEL_PACKAGE_NAME="@aicpa-ads/auditdata-model"
SHARED_TYPES=( )
MODEL_PACKAGE_PATH="models"

#declare -A MODEL_PACKAGE=( ["gl"]="gl" ["ar"]="ar" ["ent"]="entity" ["combined"]="" )

setup_build_folder() {
    rm -rf "$BUILD_DIR/$LANG-client/"
}

convert_spec () {
    mkdir -p "$BUILD_DIR/$LANG-client/$1"
    cp "$LANG/client/generator-template/.openapi-generator-ignore" "$BUILD_DIR/$LANG-client/$1/"
    #rm -rf "$BUILD_DIR/$LANG-client/$1/$MODEL_PACKAGE_PATH"
    java -jar ./openapi-generator-cli.jar generate -i "$SPEC_LOCATION/$2" -g typescript -t "$LANG/client/generator-template" \
        -c "$LANG/client/config.yaml" -o "$BUILD_DIR/$LANG-client/$1" --additional-properties=npmVersion=$PACKAGE_VERSION,npmName=$3
        #,modelPackage=$4
}

post_conversion_cleanup () {
    pushd "$BUILD_DIR/$LANG-models/combined/dist/"
    files=($(find . -type f -name '*.d.ts' ! -name 'index.d.ts'))
    declare -A lookups
    for file in "${files[@]}" ; do
        key=$(basename -- $file)
        key=${key%.d.ts}
        value=$(dirname -- $file | cut -c2-)
        #echo $key $value
        lookups[$key]=$value
    done
    popd

    find -type f -name '*.ts'
    files=($(find "$BUILD_DIR/$LANG-client/" -type f -name '*.ts' ))
    for file in "${files[@]}" ; do
        echo $file
        for type in "${!lookups[@]}" ; do
            subst=${lookups[$type]}
            #echo $type $subst
            sed -i "s~//__import__$type~import { $type } from '$MODEL_PACKAGE_NAME$subst'~g" "$file"
        done
    done
}

## Build Models
build_package() { 
    mkdir -p "dist/js" 
    pushd "$BUILD_DIR/$LANG-client"
    npm i && npm run build \
        && cd dist && npm pack
    popd
    mv "$BUILD_DIR/$LANG-client/dist"/*.tgz "dist/js"
}

