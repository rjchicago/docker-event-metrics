# Docker Swarm

> NOTE: For this demo you will need to run Docker in Swarm mode.

``` sh
docker swarm init > /dev/null
```

Copy [docker-stack.yml](./docker-stack.yml) and [prometheus.yml](./prometheus.yml) to a local directory and proceed to deploy the stack locally...

``` sh
# create demo directory
mkdir docker-event-metrics-demo
cd docker-event-metrics-demo

# copy required config
uri=https://raw.githubusercontent.com/rjchicago/docker-event-metrics/master/examples/swarm/
curl ${uri}docker-stack.yml -o docker-stack.yml
curl ${uri}prometheus.yml -o prometheus.yml

#deploy
docker stack deploy -c docker-stack.yml docker-event-metrics --prune

# check services until all are up and running
docker service ls 
```

## test

Create some test events...

``` sh
docker network create test
docker network rm test
docker run --rm alpine echo "hello"
docker service update --replicas 3 docker-event-metrics_test
docker service rm docker-event-metrics_test

# create a flapping container
docker service create \
 --restart-condition any \
 --name docker-event-metrics_testy \
 alpine \
 sleep 10
```

Open ./metrics endpoints:

* <http://localhost:8076/metrics>
* <http://localhost:8077/metrics>

## prometheus

Open in Prometheus...

* <http://localhost:9090>

Example graph...

* <http://localhost:9090/graph?g0.expr=rate(docker_events%5B2m%5D)%20%3E%200&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=15m>

``` sql
rate(docker_events[2m]) > 0
```

Looking specifically at container starts...

* <http://localhost:9090/graph?g0.expr=rate(docker_events%7Btype%3D%22container%22%2C%20action%3D%22start%22%7D%5B2m%5D)%20%3E%200&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=15m>

``` sql
rate(docker_events{type="container", action="start"}[2m]) > 0
```

## cleanup

``` sh
docker stack rm docker-event-metrics
docker service rm docker-event-metrics_testy
```
