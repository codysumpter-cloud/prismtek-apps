import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Auth Routes (Placeholder)
app.post('/api/auth/register', (req, res) => {
  res.json({ message: 'Registration successful', user: { id: '1', email: req.body.email } });
});

// Workspace Routes
app.get('/api/workspaces', (req, res) => {
  res.json([
    { id: '1', name: 'Customer Support Bot', template: 'BMO Agent', status: 'Running' },
    { id: '2', name: 'Data Analysis Tool', template: 'OpenClaw', status: 'Paused' }
  ]);
});

// App Factory Service Interface
app.post('/api/factory/generate', (req, res) => {
  const { description, template, target } = req.body;
  console.log(`Generating app: ${description} using ${template} for ${target}`);
  res.json({ jobId: 'job_123', status: 'queued' });
});

// Sandbox Service Interface
app.post('/api/sandbox/launch', (req, res) => {
  const { workspaceId } = req.body;
  console.log(`Launching sandbox for workspace: ${workspaceId}`);
  res.json({ sandboxId: 'sb_456', url: 'https://sandbox.prismtek.dev/sb_456' });
});

app.listen(PORT, () => {
  console.log(`Prismtek API running on http://localhost:${PORT}`);
});
