// app/index.js
const express = require('express');
const morgan = require('morgan');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const cors = require('cors');
const crypto = require('crypto');

const app = express();

// ----- Config -----
const PORT = process.env.PORT || 8080;
const NODE_ENV = process.env.NODE_ENV || 'development';

// ----- Middleware -----
app.use(helmet());
app.use(express.json());
app.use(morgan(NODE_ENV === 'production' ? 'combined' : 'dev'));
app.use(cors({ origin: true, credentials: true }));

// Simple rate limit (dev-friendly)
const limiter = rateLimit({ windowMs: 60 * 1000, max: 120 });
app.use(limiter);

// ----- In-memory store (DEV ONLY) -----
const users = [{ id: 1, email: 'demo@medsec.local', password: 'demo123', name: 'Demo User' }];
const sessions = new Map(); // token -> { userId, exp }

// Mock patient records (DEV ONLY)
const patients = [
  { id: 'P-1001', name: 'Jane Doe', dob: '1988-01-14', lastVisit: '2025-08-10' },
  { id: 'P-1002', name: 'John Smith', dob: '1979-05-02', lastVisit: '2025-09-20' },
];

// ----- Helpers -----
function makeToken() {
  return crypto.randomBytes(24).toString('hex');
}

function auth(req, res, next) {
  const hdr = req.header('Authorization') || '';
  const token = hdr.startsWith('Bearer ') ? hdr.slice(7) : null;
  if (!token || !sessions.has(token)) return res.status(401).json({ error: 'unauthorized' });

  const session = sessions.get(token);
  if (Date.now() > session.exp) {
    sessions.delete(token);
    return res.status(401).json({ error: 'session_expired' });
  }
  req.userId = session.userId;
  next();
}

// ----- Health / Readiness -----
app.get('/health', (_req, res) => res.status(200).json({ status: 'ok', service: 'medsec-portal' }));
app.get('/ready', (_req, res) => {
  // Add checks (e.g., DB, queue) here when you have them
  res.status(200).json({ ready: true });
});

// ----- Public -----
app.get('/', (_req, res) => {
  res.type('html').send(`
    <html>
      <head><title>MedSec Portal (dev)</title></head>
      <body>
        <h1>MedSec Patient Portal (dev)</h1>
        <p>Try POST /login with { "email": "demo@medsec.local", "password": "demo123" }</p>
        <p>Then call GET /api/patients with Authorization: Bearer &lt;token&gt;</p>
        <p>Health: <a href="/health">/health</a> | Readiness: <a href="/ready">/ready</a></p>
      </body>
    </html>
  `);
});

// ----- Auth (DEV) -----
app.post('/login', (req, res) => {
  const { email, password } = req.body || {};
  if (typeof email !== 'string' || typeof password !== 'string') {
    return res.status(400).json({ error: 'invalid_payload' });
  }
  const user = users.find(u => u.email === email && u.password === password);
  if (!user) return res.status(401).json({ error: 'invalid_credentials' });

  const token = makeToken();
  // short-lived: 30 minutes
  sessions.set(token, { userId: user.id, exp: Date.now() + 30 * 60 * 1000 });
  return res.status(200).json({ token, user: { id: user.id, name: user.name, email: user.email } });
});

// ----- Protected API -----
app.get('/api/patients', auth, (_req, res) => {
  // later: filter by user role/tenant; paginate
  res.status(200).json({ data: patients });
});

app.get('/api/patients/:id', auth, (req, res) => {
  const p = patients.find(x => x.id === req.params.id);
  if (!p) return res.status(404).json({ error: 'not_found' });
  res.status(200).json(p);
});

// ----- Errors -----
app.use((req, res) => res.status(404).json({ error: 'route_not_found' }));
app.use((err, _req, res, _next) => {
  /* eslint-disable no-console */
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'internal_error' });
});

app.listen(PORT, () => {
  console.log(`MedSec portal listening on ${PORT} (env=${NODE_ENV})`);
});
// redeploy
// redeploy
