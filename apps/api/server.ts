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

// Mock Database
const users: any[] = [];
const workspaces: any[] = [
  { id: '1', name: 'Customer Support Bot', template: 'BMO Agent', status: 'Running' },
  { id: '2', name: 'Data Analysis Tool', template: 'OpenClaw', status: 'Paused' }
];
const systemLogs: any[] = [
  { id: '1', event: 'System Boot', user: 'System', time: '1h ago', type: 'info' },
  { id: '2', event: 'New User Registration', user: 'sarah.j@example.com', time: '2m ago', type: 'success' }
];

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

// Admin Routes
app.get('/api/admin/stats', authenticateToken, (req: any, res) => {
  // In a real app, check if user is admin
  res.json({
    totalUsers: users.length + 1284,
    activeSessions: 84,
    appGenerations: 3492,
    systemLoad: 14,
    trends: {
      users: '+12%',
      sessions: '+5%',
      generations: '+24%',
      load: '-2%'
    }
  });
});

app.get('/api/admin/logs', authenticateToken, (req, res) => {
  res.json(systemLogs);
});

// Workspace Routes
app.get('/api/workspaces', authenticateToken, (req, res) => {
  res.json(workspaces);
});

app.post('/api/workspaces', authenticateToken, (req, res) => {
  const { name, template } = req.body;
  const workspace = { id: Date.now().toString(), name, template, status: 'Running' };
  workspaces.push(workspace);
  res.json(workspace);
});

app.delete('/api/workspaces/:id', authenticateToken, (req, res) => {
  const index = workspaces.findIndex(w => w.id === req.params.id);
  if (index !== -1) {
    workspaces.splice(index, 1);
  }
  res.json({ success: true });
});

// App Factory Service Interface
app.get('/api/factory/templates', authenticateToken, (req, res) => {
  res.json(appFactory.getTemplates());
});

app.post('/api/factory/generate', authenticateToken, async (req: any, res) => {
  const { description, templateId, target } = req.body;
  try {
    const job = await appFactory.generate({ description, templateId, target });
    
    // Log the event
    systemLogs.unshift({
      id: Date.now().toString(),
      event: 'App Generation Started',
      user: req.user.email,
      time: 'Just now',
      type: 'info'
    });

    res.json(job);
  } catch (error) {
    res.status(400).json({ error: (error as Error).message });
  }
});

app.get('/api/factory/jobs/:id', authenticateToken, async (req, res) => {
  const job = await appFactory.getJobStatus(req.params.id);
  if (!job) return res.status(404).json({ error: 'Job not found' });

  if (job.status === 'completed') {
    // Automatically create a workspace when job completes
    const template = appFactory.getTemplates().find(t => t.id === job.templateId);
    if (template && !workspaces.find(w => w.id === job.id)) {
      workspaces.unshift({
        id: job.id,
        name: `Generated ${template.name}`,
        template: template.name,
        status: 'Running'
      });
    }
  }

  res.json(job);
});

// Sandbox Service Interface
app.post('/api/sandbox/launch', authenticateToken, async (req: any, res) => {
  const { workspaceId } = req.body;
  try {
    const session = await sandboxManager.launch(workspaceId);
    
    // Add some initial logs to the session
    (session as any).logs = [
      '# Initializing Prismtek Sandbox...',
      '# Mounting virtual filesystem...',
      '# Loading OpenClaw harness...',
      '# Environment ready.'
    ];

    systemLogs.unshift({
      id: Date.now().toString(),
      event: 'Sandbox Launch',
      user: req.user.email,
      time: 'Just now',
      type: 'success'
    });

    res.json(session);
  } catch (error) {
    res.status(500).json({ error: (error as Error).message });
  }
});

app.get('/api/sandbox/sessions', authenticateToken, async (req, res) => {
  const sessions = await sandboxManager.listActiveSessions();
  res.json(sessions);
});

app.delete('/api/sandbox/sessions/:id', authenticateToken, async (req, res) => {
  await sandboxManager.terminate(req.params.id);
  res.json({ success: true });
});

app.listen(PORT, () => {
  console.log(`Prismtek API running on http://localhost:${PORT}`);
});
