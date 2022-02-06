module.exports = (event) => {
    const {
        Actor: {
            'ID': image
        }
    } = event;
    return {
        image
    };
};