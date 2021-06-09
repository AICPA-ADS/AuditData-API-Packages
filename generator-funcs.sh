function init_generator() {
    mkdir -p "$BUILD_DIR/"
    echo "Package version: $PACKAGE_VERSION"

    if [ ! -f ./openapi-generator-cli.jar ]; then
        wget https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/5.1.1/openapi-generator-cli-5.1.1.jar -O ./openapi-generator-cli.jar
    fi
}

function download_spec() {
    if test -d "$SPEC" ; then
        echo "Building from spec: $SPEC"
        SPEC_LOCATION="$SPEC"
    else
        echo "Building from branch/tag: $SPEC"
        git clone --depth 1 --branch $SPEC https://github.com/AICPA-ADS/AuditData-API.git _spec &> /dev/null
        SPEC_LOCATION="_spec/"
    fi
}

rm_shared_types(){
    for file in "${SHARED_TYPES[@]}"
    do
        #echo "deleting $1/$file"; 
        rm "$1/$file" &>/dev/null
    done
}