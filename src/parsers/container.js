module.exports = (event) => {
    const {
        Actor: {
            Attributes: {
                image,
                'com.docker.stack.namespace': stack_name,
                'com.docker.swarm.service.name': service_name
            }
        }
    } = event;
    return service_name
        ? { image, stack_name, service_name, container_name: service_name }
        : { image };
};