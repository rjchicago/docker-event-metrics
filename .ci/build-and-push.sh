#!/bin/sh
set -Eeuo pipefail

if [ ! -f ci.env ]; then
    echo "ci.env required"
    exit 1
fi

cat ci.env && echo

set -o allexport; source ci.env; set +o allexport

COMPOSE_FILE=${COMPOSE_FILE:-docker-compose.yml}
REGISTRY_URL=${REGISTRY_URL:-docker.io}
REGISTRY_USER=${REGISTRY_USER:-}
REGISTRY_PASSWORD=${REGISTRY_PASSWORD:-}

export TARGET="production"
export VERSION=$(jq -r .version package.json)

BRANCH=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
if [[ "$BRANCH" != "master" ]]; then
  echo "BRANCH=$BRANCH
Continue? (y/n)"
  read -r CONTINUE
  if [[ ! "$CONTINUE" =~ ^y ]]; then
      exit 0
  fi
fi

# # hook for local testing
# if [[ -z $REGISTRY_USER ]] ; then
#   echo "Registry User (or hit ENTER to skip registry push):"
#   read REGISTRY_USER
# fi
# if [[ ! -z $REGISTRY_USER ]] && [[ -z $REGISTRY_PASSWORD ]] ; then
#   echo "Registry Password for $REGISTRY_USER:"
#   read -s REGISTRY_PASSWORD
# fi

function docker_login() {
  if [[ ! -z $REGISTRY_PASSWORD ]] ; then
    export DOCKER_CONFIG="$(pwd)/.docker"
    echo "$REGISTRY_PASSWORD" | docker login -u $REGISTRY_USER --password-stdin $REGISTRY_URL
  fi
}

function docker_logout() {
  if [[ ! -z $REGISTRY_PASSWORD ]] ; then
    docker logout $REGISTRY_URL
  fi
}

function build_and_push() {
  VERSION=$1 docker-compose -f $COMPOSE_FILE build
  if [[ ! -z $REGISTRY_PASSWORD ]] ; then
    VERSION=$1 docker-compose -f $COMPOSE_FILE push
  fi
}

docker_login
build_and_push $VERSION
build_and_push "latest"
docker_logout
