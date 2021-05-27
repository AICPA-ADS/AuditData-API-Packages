#!/bin/sh
BRANCH_NAME=${1:-master}
PACKAGE_VERSION=${2:-0.0.0}
SPEC_LOCATION=${3}

echo "Building from branch/tag: $BRANCH_NAME"
echo "Package version: $PACKAGE_VERSION"

if [ ! -f ./openapi-generator-cli.jar ]; then
    wget https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/5.1.1/openapi-generator-cli-5.1.1.jar -O ./openapi-generator-cli.jar
fi

if [ -r SPEC_LOCATION ]; then
    git clone --depth 1 --branch $BRANCH_NAME https://github.com/AICPA-ADS/AuditData-API.git _spec &> /dev/null
    SPEC_LOCATION="_spec/AuditDataStandard.yml"
fi

mkdir -p build/cs-models
mkdir -p build/cs-client
cp cs/models/generator-template/.openapi-generator-ignore build/cs-models
#cp cs/client/generator-template/.openapi-generator-ignore build/cs-client

echo "Building from spec: $SPEC_LOCATION"

java -jar ./openapi-generator-cli.jar generate -i $SPEC_LOCATION -g csharp-netcore -t cs/models/generator-template \
    -c cs/models/config.yaml -o build/cs-models --additional-properties=packageVersion=$PACKAGE_VERSION
# couldn't figure out the way to configure the generator to output decimals (not supported in OAS yet)
find build/cs-models/src -type f -name "*.cs" -exec sed -i 's/float/decimal/g' {} \;


return
## Build Models
rm -rf dist/cs/@aicpa-ads/auditdata-model
mkdir -p dist/cs/@aicpa-ads/auditdata-model
cd build/cs-models
npm i && npm run build
cd ../../
mv build/cs-models/dist/* dist/cs/@aicpa-ads/auditdata-model

return
## Build API Client
java -jar ./openapi-generator-cli.jar generate -i $SPEC_LOCATION -g csharp-netcore -t cs/client/generator-template \
    -c cs/client/config.yaml -o build/cs-client --additional-properties=packageVersion=$PACKAGE_VERSION,platform=browser

rm -rf dist/cs/@aicpa-ads/auditdata-client
mkdir -p dist/cs/@aicpa-ads/auditdata-client
cd build/cs-client
npm i 
npm run build
cd ../../
mv build/cs-client/dist/* dist/cs/@aicpa-ads/auditdata-client