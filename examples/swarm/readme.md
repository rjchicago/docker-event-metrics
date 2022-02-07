# Docker Swarm

## deploy

``` sh
docker stack deploy -c docker-stack.yml docker-event-metrics --prune
```

## test

Create some events...

``` sh
docker network create test
docker network rm test
docker run -it --rm alpine echo "hello"
docker service update --replicas 3 docker-event-metrics_test
docker service rm docker-event-metrics_test
```

Open ./metrics endpoints:

> <http://localhost:8076/metrics>
> <http://localhost:8077/metrics>

## prometheus

Open in Prometheus...

> <http://localhost:9090>

Example graph

> <http://localhost:9090/graph?g0.expr=rate(docker_events%5B2m%5D)%20%3E%200&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=30m>

``` sql
rate(docker_events[2m]) > 0
```

## cleanup

``` sh
docker stack rm docker-event-metrics
```