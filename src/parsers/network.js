module.exports = (event) => {
    const {
        Actor: {
            Attributes: {
                'type': network_type
            }
        }
    } = event;
    return {
        network_type
    };
};