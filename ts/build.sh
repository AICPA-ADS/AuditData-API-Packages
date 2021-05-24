
#!/bin/sh
BRANCH_NAME=${1:-master}
PACKAGE_VERSION=${2:-0.0.0}
SPEC_LOCATION=${3}

echo "Building from branch/tag: $BRANCH_NAME"
echo "Package version: $PACKAGE_VERSION"

if [ ! -f ./openapi-generator-cli.jar ]; then
    wget https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/5.1.0/openapi-generator-cli-5.1.0.jar -O ./openapi-generator-cli.jar
fi

if [ -r $SPEC_LOCATION ]; then
    git clone --depth 1 --branch $BRANCH_NAME https://github.com/AICPA-ADS/AuditData-API.git _spec &> /dev/null
    SPEC_LOCATION="_spec/AuditDataStandard.yml"
fi

mkdir -p build/ts
cp ts/models/generator-template/.openapi-generator-ignore build/ts

echo "Building from spec: $SPEC_LOCATION"

java -jar ./openapi-generator-cli.jar generate -i $SPEC_LOCATION -g typescript -t ts/models/generator-template \
    -c ts/config.yaml -o build/ts --additional-properties=npmVersion=$PACKAGE_VERSION

rm -rf dist/js/models
mkdir -p dist/js/models
cd build/ts
npm i && npm run build
cd ../../

mv build/ts/dist/* dist/js/models