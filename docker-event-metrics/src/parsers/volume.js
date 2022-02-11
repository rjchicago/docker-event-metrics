module.exports = (event) => {
    const {
        Actor: {
            'ID': volume_name,
            Attributes: {
                driver
            }
        }
    } = event;
    return {
        volume_name,
        driver
    };
};