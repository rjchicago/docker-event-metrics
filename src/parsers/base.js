module.exports = (event) => {
    const {
        Type: type,
        Action: action,
        scope,
        Actor: {
            Attributes: {
                name
            }
        }
    } = event;
    const base = { type, action, scope };
    base[`${type}_name`] = name;
    return base;
};
