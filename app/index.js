const express = require('express');
const app = express();
app.get('/health', (_req, res) => res.status(200).json({status:'ok', service:'medsec-portal'}));
app.get('/', (_req, res) => res.send('MedSec Patient Portal (dev)'));
const port = process.env.PORT || 8080;
app.listen(port, () => console.log(`App listening on ${port}`));
