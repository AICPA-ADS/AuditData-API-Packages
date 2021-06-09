
PACKAGE_NAME="Org.Aicpa.AuditData"
SHARED_TYPES=( "AbstractOpenAPISchema.cs" )
MODEL_PACKAGE_PATH="src/$PACKAGE_NAME"

declare -A MODEL_PACKAGE=( ["gl"]="Model.GL" ["ar"]="Model.AR" ["ent"]="Model.Entity" ["combined"]="Model" )

setup_build_folder() {
    rm -rf "$BUILD_DIR/$LANG-models/combined/$MODEL_PACKAGE_PATH/Model/"
}

convert_spec () {
    mkdir -p "$BUILD_DIR/$LANG-models/$1"
    cp "$LANG/models/generator-template/.openapi-generator-ignore" "$BUILD_DIR/$LANG-models/$1/"
    java -jar ./openapi-generator-cli.jar generate -i "$SPEC_LOCATION/$2" -g csharp-netcore -t "$LANG/models/generator-template" \
        -c "$LANG/models/config.yaml" -o "$BUILD_DIR/$LANG-models/$1" --additional-properties=packageVersion=$PACKAGE_VERSION,packageName=$3,modelPackage=$4
}

post_model_creation_cleanup(){
    :
}

post_conversion_cleanup () {
    # couldn't figure out the way to configure the generator to output decimals (not supported in OAS yet)
    find "$BUILD_DIR/$LANG-models/combined/src/" -type f -name "*.cs" -exec sed -i 's/float/decimal/g' {} \;
}

get_generated_model_package_name(){
    basename -- $1 | cut -c7-
}

build_package() {
    pushd "$BUILD_DIR/$LANG-models/combined"
    dotnet pack -c Release
    popd
    mv "$BUILD_DIR/$LANG-models/combined/src/$PACKAGE_NAME/bin/Release/"*.nupkg "dist/$LANG"
}