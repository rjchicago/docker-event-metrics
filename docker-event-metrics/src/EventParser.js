const parsers = require('./parsers');

class EventParser {
    static parse = (event) => {
        const {Type: type} = event;
        const parsed = parsers.base(event);
        if (Object.prototype.hasOwnProperty.call(parsers, type)) {
            Object.assign(parsed, parsers[type](event));
        }
        return parsed;
    }
}

module.exports = EventParser;
