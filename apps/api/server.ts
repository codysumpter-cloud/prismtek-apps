import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import rateLimit from 'express-rate-limit';
import { AppFactory } from '@prismtek/app-factory';
import { SandboxManager } from '@prismtek/sandbox';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3001;
const JWT_SECRET = process.env.JWT_SECRET || 'prismtek-super-secret-key';

const appFactory = new AppFactory();
const sandboxManager = new SandboxManager(process.env.SANDBOX_DOCKER_IMAGE || 'prismtek/sandbox:latest');

// Rate Limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: { error: 'Too many requests, please try again later.' }
});

app.use(limiter);
app.use(cors());
app.use(express.json());

// Mock User Database
const users: any[] = [];

// Auth Middleware
const authenticateToken = (req: any, res: any, next: any) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) return res.status(401).json({ error: 'Unauthorized' });

  jwt.verify(token, JWT_SECRET, (err: any, user: any) => {
    if (err) return res.status(403).json({ error: 'Forbidden' });
    req.user = user;
    next();
  });
};

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Auth Routes
app.post('/api/auth/register', async (req, res) => {
  const { email, password, name } = req.body;
  
  if (users.find(u => u.email === email)) {
    return res.status(400).json({ error: 'User already exists' });
  }

  const hashedPassword = await bcrypt.hash(password, 10);
  const user = { id: Date.now().toString(), email, password: hashedPassword, name };
  users.push(user);

  const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '24h' });
  res.json({ token, user: { id: user.id, email: user.email, name: user.name } });
});

app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  const user = users.find(u => u.email === email);

  if (!user || !(await bcrypt.compare(password, user.password))) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '24h' });
  res.json({ token, user: { id: user.id, email: user.email, name: user.name } });
});

// Workspace Routes
app.get('/api/workspaces', authenticateToken, (req, res) => {
  res.json([
    { id: '1', name: 'Customer Support Bot', template: 'BMO Agent', status: 'Running' },
    { id: '2', name: 'Data Analysis Tool', template: 'OpenClaw', status: 'Paused' }
  ]);
});

// App Factory Service Interface
app.get('/api/factory/templates', authenticateToken, (req, res) => {
  res.json(appFactory.getTemplates());
});

app.post('/api/factory/generate', authenticateToken, async (req, res) => {
  const { description, templateId, target } = req.body;
  try {
    const job = await appFactory.generate({ description, templateId, target });
    res.json(job);
  } catch (error) {
    res.status(400).json({ error: (error as Error).message });
  }
});

app.get('/api/factory/jobs/:id', authenticateToken, async (req, res) => {
  const job = await appFactory.getJobStatus(req.params.id);
  if (!job) return res.status(404).json({ error: 'Job not found' });
  res.json(job);
});

// Sandbox Service Interface
app.post('/api/sandbox/launch', authenticateToken, async (req, res) => {
  const { workspaceId } = req.body;
  try {
    const session = await sandboxManager.launch(workspaceId);
    res.json(session);
  } catch (error) {
    res.status(500).json({ error: (error as Error).message });
  }
});

app.get('/api/sandbox/sessions', authenticateToken, async (req, res) => {
  const sessions = await sandboxManager.listActiveSessions();
  res.json(sessions);
});

app.listen(PORT, () => {
  console.log(`Prismtek API running on http://localhost:${PORT}`);
});
