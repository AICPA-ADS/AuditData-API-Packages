
#!/bin/sh
BRANCH_NAME=${1:-master}

echo $BRANCH_NAME

if [ ! -f ./openapi-generator-cli.jar ]; then
    wget https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/5.1.0/openapi-generator-cli-5.1.0.jar -O ./openapi-generator-cli.jar
fi

git clone --depth 1 --branch $BRANCH_NAME https://github.com/AICPA-ADS/AuditData-API.git _spec &> /dev/null

mkdir -p build/ts
cp ts/models/generator-tempalte/.openapi-generator-ignore build/ts

java -jar ./openapi-generator-cli.jar generate -i _spec/AuditDataStandard.yml -g typescript -t ts/models/generator-tempalte \
    -c ts/config.yaml -o build/ts

rm -rf dist/js/models
mkdir -p dist/js/models
cd build/ts
npm i && npm run build
cd ../../

mv build/ts/dist/* dist/js/models