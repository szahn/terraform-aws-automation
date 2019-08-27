#!/usr/bin/env node
const express = require('express')
const app = express()
const port = process.env.PORT || 80;
const getPayload = require('./getPayload');

app.get('/', (req, res) => {

    getPayload(new Date(), './payload.json').then(payload => {
        res.json(payload);
    }).catch(err => {
        throw err;
    })

})

app.listen(port, () => console.log(`Listening on port ${port}!`));
