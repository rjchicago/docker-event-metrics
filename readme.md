# docker-event-metrics

coming soon...

## test locally

``` sh
# build
docker compose -f docker-stack.yml build wrapper

# deploy
docker stack deploy -c docker-stack.yml dem

# logs
docker service logs dem_wrapper

#cleanup
docker container rm dem_local -f
docker stack rm dem
```

## watch script example

``` sh
#!/bin/sh -eu
"${PARENT_PID:?PARENT_PID is required}"
"${CONTAINER_NAME:?CONTAINER_NAME is required}"
SELF=$(docker inspect -f "{{.State.Pid}}" $(docker ps --filter "name=$CONTAINER_NAME" --format "{{.ID}}"))
while true; do (kill -0 $PARENT_PID || kill $SELF) && sleep 1; done &
```
