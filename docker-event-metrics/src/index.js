const DockerEventStream = require('@rjchicago/docker-event-stream');
const MetricService = require('./MetricService');
const express = require('express');
const http = require('http');
require('./ParentProcessUtil').init();

const options = process.env.OPTIONS ? JSON.parse(process.env.OPTIONS) : {};
DockerEventStream.init(options);
DockerEventStream.on('event', MetricService.push);


const app = express();
const port = process.env.PORT || '3000';

app.get('/health', (req, res) => {
    res.setHeader('content-type', 'text/plain');
    res.send('OK');
});

app.get('/metrics', async (req, res) => {
    res.setHeader('content-type', 'text/plain');
    res.send(await MetricService.collect());
});

const server = http.createServer(app);
server.listen(port, () => console.log(`http://localhost:${port}/metrics`));
