import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import { AppFactory } from '@prismtek/app-factory';
import { SandboxManager } from '@prismtek/sandbox';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3001;

const appFactory = new AppFactory();
const sandboxManager = new SandboxManager(process.env.SANDBOX_DOCKER_IMAGE || 'prismtek/sandbox:latest');

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
app.get('/api/factory/templates', (req, res) => {
  res.json(appFactory.getTemplates());
});

app.post('/api/factory/generate', async (req, res) => {
  const { description, templateId, target } = req.body;
  try {
    const job = await appFactory.generate({ description, templateId, target });
    res.json(job);
  } catch (error) {
    res.status(400).json({ error: (error as Error).message });
  }
});

app.get('/api/factory/jobs/:id', async (req, res) => {
  const job = await appFactory.getJobStatus(req.params.id);
  if (!job) return res.status(404).json({ error: 'Job not found' });
  res.json(job);
});

// Sandbox Service Interface
app.post('/api/sandbox/launch', async (req, res) => {
  const { workspaceId } = req.body;
  try {
    const session = await sandboxManager.launch(workspaceId);
    res.json(session);
  } catch (error) {
    res.status(500).json({ error: (error as Error).message });
  }
});

app.get('/api/sandbox/sessions', async (req, res) => {
  const sessions = await sandboxManager.listActiveSessions();
  res.json(sessions);
});

app.listen(PORT, () => {
  console.log(`Prismtek API running on http://localhost:${PORT}`);
});
