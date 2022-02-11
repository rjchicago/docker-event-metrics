#!/bin/sh -eu

echo "DOCKER EVENT METRICS WRAPPER"
"${PROMETHEUS_TARGET_FILE:?PROMETHEUS_TARGET_FILE is required}"
"${PORT:?PORT is required}"
"${ENV:?ENV is required}"
"${INSTANCE:?INSTANCE is required}"
"${IMAGE:?IMAGE is required}"
"${NETWORK:?NETWORK is required}"
"${INSTANCE:?INSTANCE is required}"


CONTAINER_NAME=${CONTAINER_NAME:-docker-event-metrics_local}
PID=$(docker inspect -f "{{.State.Pid}}" $(hostname))

# SERVICE="dem_wrapper"
# ID=$(docker ps --format "{{.Names}} {{.ID}}" | grep $SERVICE | sed -n -e 's/^.*\s\(.*\)$/\1/p')
# PID=$(docker inspect -f "{{.State.Pid}}" $ID)

function get_nodes() {
  # https://docs.docker.com/desktop/mac/networking/#use-cases-and-workarounds
  [ "$INSTANCE" = "localhost" ] && echo "host.docker.internal" || docker node ls --format "{{.Hostname}}"
  # if [ "$INSTANCE" = "localhost" ]; then
  #   echo "host.docker.internal"
  # else
  #   docker node ls --format "{{.Hostname}}"
  # fi
}

function write_prometheus_target_file() {
  echo "---" > ${PROMETHEUS_TARGET_FILE}
  echo "- targets:" >> ${PROMETHEUS_TARGET_FILE}
  for NODE in $(get_nodes); do 
    echo "  - ${NODE}:${PORT}" >> ${PROMETHEUS_TARGET_FILE}
  done
  echo "  labels:" >> ${PROMETHEUS_TARGET_FILE}
  echo "    env: ${ENV}" >> ${PROMETHEUS_TARGET_FILE}
}

function reload_prometheus() {
  echo "PROMETHEUS_RELOAD_URL=$PROMETHEUS_RELOAD_URL"
  if [[ ! -z $PROMETHEUS_RELOAD_URL ]]; then
    curl -X POST -i $PROMETHEUS_RELOAD_URL
  fi
}

function docker_run() {
  docker container rm $CONTAINER_NAME -f 2> /dev/null
  docker pull "${IMAGE}"
  # DEFAULT_OPTIONS='{"filter": {"scope": "local"}}'
  docker run \
    --rm \
    --init \
    --pid=host \
    --label hidden \
    --name="${CONTAINER_NAME}" \
    --network="${NETWORK}" \
    -e CONTAINER_NAME="${CONTAINER_NAME}"
    -e PARENT_PID="${PID}"
    -e ENV="${ENV}" \
    -e INSTANCE="${INSTANCE}" \
    -e OPTIONS="${OPTIONS:-'{\"filter\": {\"scope\": \"local\"}}'}" \
    --volume="/var/run/docker.sock:/var/run/docker.sock" \
    --publish="${PORT}:3000" \
    --hostname="${INSTANCE}" \
    "${IMAGE}"
}


write_prometheus_target_file
docker_run
