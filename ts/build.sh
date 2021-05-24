
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

mkdir -p build/ts-models
mkdir -p build/ts-client
cp ts/models/generator-template/.openapi-generator-ignore build/ts-models
cp ts/client/generator-template/.openapi-generator-ignore build/ts-client

echo "Building from spec: $SPEC_LOCATION"

java -jar ./openapi-generator-cli.jar generate -i $SPEC_LOCATION -g typescript -t ts/models/generator-template \
    -c ts/models/config.yaml -o build/ts-models --additional-properties=npmVersion=$PACKAGE_VERSION

## Build Models
rm -rf dist/js/@aicpa-ads/audidata-model
mkdir -p dist/js/@aicpa-ads/audidata-model
cd build/ts-models
npm i && npm run build
cd ../../
mv build/ts-models/dist/* dist/js/@aicpa-ads/audidata-model

## Build API Client
java -jar ./openapi-generator-cli.jar generate -i $SPEC_LOCATION -g typescript -t ts/client/generator-template \
    -c ts/client/config.yaml -o build/ts-client --additional-properties=npmVersion=$PACKAGE_VERSION

rm -rf dist/js/@aicpa-ads/audidata-client
mkdir -p dist/js/@aicpa-ads/audidata-client
cd build/ts-client
npm i 
npm run build
cd ../../
mv build/ts-client/dist/* dist/js/@aicpa-ads/audidata-client