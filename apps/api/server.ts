import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import admin from 'firebase-admin';
import { AppFactory } from '@prismtek/app-factory';
import { SandboxManager } from '@prismtek/sandbox';
import firebaseConfig from '../../firebase-applet-config.json' with { type: 'json' } ;

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3001;

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(process.env.FIREBASE_SERVICE_ACCOUNT as string || {}),
  databaseURL: `https://${firebaseConfig.projectId}.firebaseio.com`
});

const db = admin.firestore();
const auth = admin.auth();

const appFactory = new AppFactory();
const sandboxManager = new SandboxManager(process.env.SANDBOX_DOCKER_IMAGE || 'prismtek/sandbox:latest');

// Initialize Templates in Firestore
async function initTemplates() {
  const templates = appFactory.getTemplates();
  const templatesCol = db.collection('templates');
  
  for (const template of templates) {
    await templatesCol.doc(template.id).set(template, { merge: true });
  }
  console.log('Templates initialized in Firestore');
}

initTemplates().catch(console.error);

app.use(cors());
app.use(express.json());

// Auth Middleware (Firebase)
const authenticateToken = async (req: any, res: any, next: any) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) return res.status(401).json({ error: 'Unauthorized' });

  try {
    const decodedToken = await auth.verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (err) {
    return res.status(403).json({ error: 'Forbidden' });
  }
};

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Admin Routes
app.get('/api/admin/stats', authenticateToken, async (req: any, res) => {
  try {
    const usersCount = (await auth.listUsers()).users.length;
    const workspacesCount = (await db.collection('workspaces').get()).size;
    const sessionsCount = (await db.collection('sandbox_sessions').get()).size;

    res.json({
      totalUsers: usersCount,
      activeSessions: sessionsCount,
      appGenerations: workspacesCount,
      systemLoad: 14,
      trends: {
        users: '+12%',
        sessions: '+5%',
        generations: '+24%',
        load: '-2%'
      }
    });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch stats' });
  }
});

app.get('/api/admin/logs', authenticateToken, async (req, res) => {
  try {
    const snapshot = await db.collection('system_logs').orderBy('time', 'desc').limit(50).get();
    const logs = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.json(logs);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch logs' });
  }
});

// Workspace Routes
app.get('/api/workspaces', authenticateToken, async (req: any, res) => {
  try {
    const snapshot = await db.collection('workspaces').where('ownerId', '==', req.user.uid).get();
    const workspaces = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.json(workspaces);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch workspaces' });
  }
});

app.post('/api/workspaces/:id/sync', authenticateToken, async (req: any, res) => {
  try {
    const wsRef = db.collection('workspaces').doc(req.params.id);
    const wsDoc = await wsRef.get();
    
    if (!wsDoc.exists) {
      return res.status(404).json({ error: 'Workspace not found' });
    }

    await wsRef.update({ status: 'syncing' });
    
    // Simulate sync process
    setTimeout(async () => {
      await wsRef.update({ 
        status: 'running',
        lastSyncedAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      });
      
      await db.collection('system_logs').add({
        id: Date.now().toString(),
        event: `Workspace Synced to ${wsDoc.data()?.repoUrl || 'Repository'}`,
        user: req.user.email,
        time: new Date().toISOString(),
        type: 'success'
      });
    }, 2000);

    res.json({ success: true, message: 'Sync started' });
  } catch (err) {
    res.status(500).json({ error: 'Sync failed' });
  }
});

// App Factory Service Interface
app.get('/api/factory/templates', authenticateToken, (req, res) => {
  res.json(appFactory.getTemplates());
});

app.get('/api/factory/models', authenticateToken, (req, res) => {
  res.json(appFactory.getModels());
});

app.post('/api/factory/generate', authenticateToken, async (req: any, res) => {
  const { description, templateId, target, modelId } = req.body;
  try {
    const job = await appFactory.generate({ description, templateId, target, modelId });
    
    // Log the event in Firestore
    await db.collection('system_logs').add({
      id: Date.now().toString(),
      event: 'App Generation Started',
      user: req.user.email,
      time: new Date().toISOString(),
      type: 'info'
    });

    // Handle job completion in background
    const pollJob = async () => {
      let status = 'processing';
      while (status !== 'completed' && status !== 'failed') {
        await new Promise(r => setTimeout(r, 2000));
        const currentJob = await appFactory.getJobStatus(job.id);
        if (!currentJob) break;
        status = currentJob.status;
        
        if (status === 'completed') {
          const template = appFactory.getTemplates().find(t => t.id === templateId);
          if (template) {
            await db.collection('workspaces').doc(job.id).set({
              id: job.id,
              name: `Generated ${template.name}`,
              templateId: template.id,
              status: 'running',
              repoUrl: template.repoUrl,
              lastSyncedAt: new Date().toISOString(),
              createdAt: new Date().toISOString(),
              updatedAt: new Date().toISOString(),
              ownerId: req.user.uid
            });
            
            await db.collection('system_logs').add({
              id: Date.now().toString(),
              event: `App Generation Completed: ${template.name}`,
              user: req.user.email,
              time: new Date().toISOString(),
              type: 'success'
            });
          }
        }
      }
    };
    pollJob();

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
app.post('/api/sandbox/launch', authenticateToken, async (req: any, res) => {
  const { workspaceId } = req.body;
  try {
    const session = await sandboxManager.launch(workspaceId);
    
    // Create session in Firestore
    const sessionData = {
      id: session.id,
      workspaceId,
      ownerId: req.user.uid,
      status: 'running',
      expiresAt: session.expiresAt,
      createdAt: new Date().toISOString(),
      logs: [
        '# Initializing BeMore workspace sandbox...',
        '# Mounting virtual filesystem...',
        '# Loading BeMore runtime harness...',
        '# Environment ready.'
      ]
    };
    
    await db.collection('sandbox_sessions').doc(session.id).set(sessionData);

    await db.collection('system_logs').add({
      id: Date.now().toString(),
      event: 'Sandbox Launch',
      user: req.user.email,
      time: new Date().toISOString(),
      type: 'success'
    });

    res.json(sessionData);
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
  console.log(`BeMore API running on http://localhost:${PORT}`);
});
