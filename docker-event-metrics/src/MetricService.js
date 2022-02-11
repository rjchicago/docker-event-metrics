const client = require("prom-client");
const EventParser = require('./EventParser');

class MetricService {
    static collections = {};

    static push = (event) => {
        const key = EventParser.parse(event);
        const jsonKey =  JSON.stringify(key);
        if (!MetricService.collections[jsonKey]) {
            MetricService.collections[jsonKey] = {_labels: Object.keys(key), count: 0};
        }
        MetricService.collections[jsonKey].count++;
    };
    static getGlobals = () => {
        const globals = {};
        if (process.env.ENV) globals.env = process.env.ENV;
        if (process.env.INSTANCE) globals.instance = process.env.INSTANCE;
        return globals;
    }
    static getLabels = () => {
        const globals = MetricService.getGlobals();
        return [...new Set(Object.keys(globals).concat(
                ...Object.keys(MetricService.collections)
                .map(jsonKey => MetricService.collections[jsonKey]._labels)   
        ))];
    };
    static collect = async () => {
        const registry = new client.Registry();
        const labelNames = MetricService.getLabels();
        const gauge = new client.Gauge({
            name: `docker_events`,
            help: `[${labelNames.join(', ')}]`,
            labelNames,
            registers: [registry],
        });
        Object.keys(MetricService.collections).forEach(jsonKey => {
            const labels = JSON.parse(jsonKey);
            Object.assign(labels, MetricService.getGlobals());
            gauge.labels(labels).set(MetricService.collections[jsonKey].count);
        });
        return await registry.metrics();
    };
}

module.exports = MetricService;
