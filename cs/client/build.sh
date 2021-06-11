
PACKAGE_NAME="Org.Aicpa.AuditData.Client"
MODEL_PACKAGE_NAME="Org.Aicpa.AuditData"
SHARED_TYPES=( )
MODEL_PACKAGE_PATH="models"

setup_build_folder() {
    rm -rf "$BUILD_DIR/$LANG-client/"
}

convert_spec () {
    mkdir -p "$BUILD_DIR/$LANG-client/$1"
    cp "$LANG/client/generator-template/.openapi-generator-ignore" "$BUILD_DIR/$LANG-client/$1/"

    privatePackageRepo=$(realpath "dist/$LANG/.")

    java -jar ./openapi-generator-cli.jar generate -i "$SPEC_LOCATION/$2" -g csharp-netcore -t "$LANG/client/generator-template" \
        -c "$LANG/client/config.yaml" -o "$BUILD_DIR/$LANG-client/$1" \
        --additional-properties=packageVersion=$PACKAGE_VERSION,packageName=$3,modelPackageName=$MODEL_PACKAGE_NAME,privatePackageRepo=$privatePackageRepo
}

post_conversion_cleanup () {
    :
}

build_package() { 
    pushd "$BUILD_DIR/$LANG-client/"
    dotnet pack -c Release
    popd
    mv "$BUILD_DIR/$LANG-client/src/$PACKAGE_NAME/bin/Release/"*.nupkg "dist/$LANG"
}

