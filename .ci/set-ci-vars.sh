
TARGET="production"
VERSION=$(jq -r .version package.json)
BRANCH=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
COMMIT_HASH=$(git rev-parse HEAD)
GENERATED_AT="`date -u +%Y-%m-%dT%H:%M:%SZ`";

printf "TARGET="production"
VERSION=$VERSION
BRANCH=$BRANCH
COMMIT_HASH=$COMMIT_HASH
GENERATED_AT=$GENERATED_AT" > ci.env
