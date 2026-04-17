import { useState, useEffect } from 'react';
import { 
  LayoutDashboard, 
  PlusCircle, 
  Settings, 
  Terminal, 
  Box, 
  LogOut, 
  User,
  Activity,
  Shield,
  Zap,
  Loader2,
  CreditCard,
  ShieldCheck,
  Cpu,
  Palette,
  Bot,
  ChevronRight,
  RefreshCw,
  Globe,
  Clock
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { BuddyStudioView } from './BuddyStudioView';
import { CodexTasksView } from './CodexTasksView';
import { 
  auth, 
  db, 
  googleProvider, 
  signInWithPopup, 
  signOut, 
  onAuthStateChanged,
  collection,
  doc,
  setDoc,
  getDoc,
  onSnapshot,
  query,
  where,
  orderBy,
  limit,
  addDoc,
  deleteDoc,
  updateDoc
} from './firebase';

enum OperationType {
  CREATE = 'create',
  UPDATE = 'update',
  DELETE = 'delete',
  LIST = 'list',
  GET = 'get',
  WRITE = 'write',
}

interface FirestoreErrorInfo {
  error: string;
  operationType: OperationType;
  path: string | null;
  authInfo: {
    userId: string | undefined;
    email: string | null | undefined;
    emailVerified: boolean | undefined;
    isAnonymous: boolean | undefined;
    tenantId: string | null | undefined;
    providerInfo: {
      providerId: string;
      displayName: string | null;
      email: string | null;
      photoUrl: string | null;
    }[];
  }
}

function handleFirestoreError(error: unknown, operationType: OperationType, path: string | null) {
  const errInfo: FirestoreErrorInfo = {
    error: error instanceof Error ? error.message : String(error),
    authInfo: {
      userId: auth.currentUser?.uid,
      email: auth.currentUser?.email,
      emailVerified: auth.currentUser?.emailVerified,
      isAnonymous: auth.currentUser?.isAnonymous,
      tenantId: auth.currentUser?.tenantId,
      providerInfo: auth.currentUser?.providerData.map(provider => ({
        providerId: provider.providerId,
        displayName: provider.displayName,
        email: provider.email,
        photoUrl: provider.photoURL
      })) || []
    },
    operationType,
    path
  };
  console.error('Firestore Error: ', JSON.stringify(errInfo));
  throw new Error(JSON.stringify(errInfo));
}

interface Template {
  id: string;
  name: string;
  description: string;
  version: string;
}

interface Job {
  id: string;
  status: 'queued' | 'processing' | 'completed' | 'failed';
  progress: number;
}

export default function App() {
  const [user, setUser] = useState<any>(null);
  const [token, setToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('dashboard');
  const [templates, setTemplates] = useState<Template[]>([]);
  const [generating, setGenerating] = useState(false);
  const [currentJob, setCurrentJob] = useState<Job | null>(null);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      if (firebaseUser) {
        const idToken = await firebaseUser.getIdToken();
        setToken(idToken);

        // Ensure user document exists in Firestore
        const userRef = doc(db, 'users', firebaseUser.uid);
        const userSnap = await getDoc(userRef);
        
        if (!userSnap.exists()) {
          const newUser = {
            uid: firebaseUser.uid,
            email: firebaseUser.email,
            name: firebaseUser.displayName,
            role: firebaseUser.email === 'Cody.Sumpter@gmail.com' ? 'admin' : 'user',
            createdAt: new Date().toISOString()
          };
          await setDoc(userRef, newUser);
          setUser(newUser);
        } else {
          setUser(userSnap.data());
        }
      } else {
        setUser(null);
        setToken(null);
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  useEffect(() => {
    if (user) {
      // Listen for templates
      const q = query(collection(db, 'templates'));
      const unsubscribe = onSnapshot(q, (snapshot) => {
        const tList = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Template));
        setTemplates(tList);
      }, (error) => {
        handleFirestoreError(error, OperationType.LIST, 'templates');
      });
      return () => unsubscribe();
    }
  }, [user]);

  const handleLogin = async () => {
    try {
      await signInWithPopup(auth, googleProvider);
    } catch (err) {
      console.error('Login failed', err);
    }
  };

  const handleLogout = async () => {
    try {
      await signOut(auth);
    } catch (err) {
      console.error('Logout failed', err);
    }
  };

  const isAdmin = user?.role === 'admin' || user?.email === 'Cody.Sumpter@gmail.com';

  const handleGenerate = async (description: string, templateId: string, target: string, modelId?: string) => {
    setGenerating(true);
    try {
      const res = await fetch('http://localhost:3001/api/factory/generate', {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ description, templateId, target, modelId })
      });
      const job = await res.json();
      setCurrentJob(job);
      pollJob(job.id);
    } catch (err) {
      console.error('Generation failed', err);
      setGenerating(false);
    }
  };

  const pollJob = async (jobId: string) => {
    const interval = setInterval(async () => {
      try {
        const res = await fetch(`http://localhost:3001/api/factory/jobs/${jobId}`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        const job = await res.json();
        setCurrentJob(job);
        if (job.status === 'completed' || job.status === 'failed') {
          clearInterval(interval);
          setGenerating(false);
          if (job.status === 'completed') {
            setActiveTab('workspaces');
          }
        }
      } catch (err) {
        clearInterval(interval);
        setGenerating(false);
      }
    }, 1000);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-[#0a0a0a] flex items-center justify-center">
        <Loader2 className="animate-spin text-blue-500" size={48} />
      </div>
    );
  }

  if (!user) {
    return <AuthView onLogin={handleLogin} />;
  }

  return (
    <div className="flex h-screen bg-[#0a0a0a] text-white font-sans selection:bg-blue-500/30">
      {/* Sidebar */}
      <aside className="w-64 border-r border-white/10 bg-[#0f0f0f] flex flex-col">
        <div className="p-6">
          <div className="flex items-center gap-2 mb-8">
            <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
              <Zap className="w-5 h-5 text-white" />
            </div>
            <span className="font-bold text-xl tracking-tight">BeMore</span>
          </div>

          <nav className="space-y-1">
            <SidebarItem 
              icon={<LayoutDashboard size={20} />} 
              label="Dashboard" 
              active={activeTab === 'dashboard'} 
              onClick={() => setActiveTab('dashboard')}
            />
            <SidebarItem 
              icon={<Box size={20} />} 
              label="Workspaces" 
              active={activeTab === 'workspaces'} 
              onClick={() => setActiveTab('workspaces')}
            />
            <SidebarItem 
              icon={<Cpu size={20} />} 
              label="Model Hub" 
              active={activeTab === 'models'} 
              onClick={() => setActiveTab('models')}
            />
            <SidebarItem 
              icon={<PlusCircle size={20} />} 
              label="App Factory" 
              active={activeTab === 'factory'} 
              onClick={() => setActiveTab('factory')}
            />
            <SidebarItem 
              icon={<Palette size={20} />} 
              label="Buddy Studio" 
              active={activeTab === 'buddy'} 
              onClick={() => setActiveTab('buddy')}
            />
            <SidebarItem 
              icon={<Bot size={20} />} 
              label="Codex Tasks" 
              active={activeTab === 'codex'} 
              onClick={() => setActiveTab('codex')}
            />
            <SidebarItem 
              icon={<Terminal size={20} />} 
              label="Sandbox" 
              active={activeTab === 'sandbox'} 
              onClick={() => setActiveTab('sandbox')}
            />
            <SidebarItem 
              icon={<CreditCard size={20} />} 
              label="Billing" 
              active={activeTab === 'billing'} 
              onClick={() => setActiveTab('billing')}
            />
            {isAdmin && (
              <SidebarItem 
                icon={<ShieldCheck size={20} />} 
                label="Admin" 
                active={activeTab === 'admin'} 
                onClick={() => setActiveTab('admin')}
              />
            )}
          </nav>
        </div>

        <div className="mt-auto p-6 border-t border-white/10">
          <nav className="space-y-1">
            <SidebarItem icon={<Settings size={20} />} label="Settings" onClick={() => {}} />
            <SidebarItem icon={<LogOut size={20} />} label="Logout" onClick={handleLogout} />
          </nav>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 overflow-y-auto">
        <header className="h-16 border-b border-white/10 bg-[#0f0f0f]/50 backdrop-blur-md flex items-center justify-between px-8 sticky top-0 z-10">
          <h1 className="text-lg font-medium capitalize">{activeTab}</h1>
          <div className="flex items-center gap-4">
            <div className="flex items-center gap-2 px-3 py-1.5 bg-white/5 rounded-full border border-white/10">
              <Activity className="w-4 h-4 text-green-500" />
              <span className="text-xs font-medium text-white/70">System Healthy</span>
            </div>
            <button className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center hover:bg-white/20 transition-colors">
              <User size={18} />
            </button>
          </div>
        </header>

        <div className="p-8 max-w-7xl mx-auto">
          <AnimatePresence mode="wait">
            <motion.div
              key={activeTab}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              transition={{ duration: 0.2 }}
            >
              {activeTab === 'dashboard' && <DashboardView user={user} />}
              {activeTab === 'workspaces' && <WorkspacesView user={user} />}
              {activeTab === 'models' && <ModelsView user={user} token={token} />}
              {activeTab === 'factory' && (
                <AppFactoryView 
                  templates={templates} 
                  onGenerate={handleGenerate} 
                  generating={generating}
                  currentJob={currentJob}
                  user={user}
                  token={token}
                />
              )}
              {activeTab === 'buddy' && token && <BuddyStudioView token={token} />}
              {activeTab === 'codex' && token && <CodexTasksView token={token} />}
              {activeTab === 'sandbox' && <SandboxView user={user} token={token} />}
              {activeTab === 'billing' && <BillingView />}
              {activeTab === 'admin' && <AdminView user={user} />}
            </motion.div>
          </AnimatePresence>
        </div>
      </main>
    </div>
  );
}

function AuthView({ onLogin }: { onLogin: () => void }) {
  const [loading, setLoading] = useState(false);

  const handleGoogleLogin = async () => {
    setLoading(true);
    try {
      await onLogin();
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#0a0a0a] flex items-center justify-center p-4">
      <motion.div 
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        className="w-full max-w-md bg-[#0f0f0f] border border-white/10 p-8 rounded-2xl shadow-2xl"
      >
        <div className="flex items-center gap-2 mb-8 justify-center">
          <div className="w-10 h-10 bg-blue-600 rounded-xl flex items-center justify-center">
            <Zap className="w-6 h-6 text-white" />
          </div>
          <span className="font-bold text-2xl tracking-tight text-white">BeMore</span>
        </div>

        <h2 className="text-xl font-bold text-center mb-2">Welcome to BeMore</h2>
        <p className="text-white/40 text-center text-sm mb-8">
          The flagship personal agent app from Prismtek
        </p>

        <button 
          onClick={handleGoogleLogin}
          disabled={loading}
          className="w-full bg-white text-black hover:bg-white/90 disabled:bg-white/50 py-4 rounded-xl font-bold transition-all active:scale-[0.98] flex items-center justify-center gap-3"
        >
          {loading ? <Loader2 size={20} className="animate-spin" /> : (
            <svg className="w-5 h-5" viewBox="0 0 24 24">
              <path fill="currentColor" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" />
              <path fill="currentColor" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
              <path fill="currentColor" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" />
              <path fill="currentColor" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" />
            </svg>
          )}
          Sign in with Google
        </button>

        <div className="mt-8 pt-8 border-t border-white/5 text-center">
          <p className="text-xs text-white/20">
            By signing in, you agree to our Terms of Service and Privacy Policy.
          </p>
        </div>
      </motion.div>
    </div>
  );
}

function BillingView() {
  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold">Billing & Subscription</h2>
        <div className="px-4 py-2 bg-blue-600/20 border border-blue-500/30 rounded-lg text-blue-400 text-sm font-medium">
          Pro Plan Active
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-[#0f0f0f] border border-white/10 p-6 rounded-2xl">
          <p className="text-white/40 text-sm mb-1">Current Usage</p>
          <h3 className="text-3xl font-bold mb-4">$42.50</h3>
          <div className="w-full bg-white/5 h-2 rounded-full overflow-hidden">
            <div className="bg-blue-600 h-full w-[40%]" />
          </div>
          <p className="text-xs text-white/40 mt-2">40% of $100.00 soft limit</p>
        </div>
        <div className="bg-[#0f0f0f] border border-white/10 p-6 rounded-2xl">
          <p className="text-white/40 text-sm mb-1">Active Sandboxes</p>
          <h3 className="text-3xl font-bold mb-4">4 / 10</h3>
          <p className="text-xs text-white/40">Pro plan allows up to 10 concurrent sessions</p>
        </div>
        <div className="bg-[#0f0f0f] border border-white/10 p-6 rounded-2xl">
          <p className="text-white/40 text-sm mb-1">Next Invoice</p>
          <h3 className="text-3xl font-bold mb-4">May 1, 2026</h3>
          <button className="text-blue-400 text-sm hover:underline">View Invoices</button>
        </div>
      </div>

      <div className="bg-[#0f0f0f] border border-white/10 rounded-2xl overflow-hidden">
        <div className="p-6 border-b border-white/10">
          <h3 className="font-bold">Payment Methods</h3>
        </div>
        <div className="p-6 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div className="w-12 h-8 bg-white/5 rounded border border-white/10 flex items-center justify-center text-[10px] font-bold">VISA</div>
            <div>
              <p className="text-sm font-medium">Visa ending in 4242</p>
              <p className="text-xs text-white/40">Expires 12/28</p>
            </div>
          </div>
          <button className="text-white/60 hover:text-white transition-colors text-sm">Edit</button>
        </div>
      </div>
    </div>
  );
}

function AdminView({ user }: { user: any }) {
  const [stats, setStats] = useState<any>(null);
  const [logs, setLogs] = useState<any[]>([]);

  useEffect(() => {
    // Mock stats for now, but logs are real
    setStats({
      totalUsers: 1284,
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

    const q = query(collection(db, 'system_logs'), orderBy('time', 'desc'), limit(20));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const logList = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setLogs(logList);
    }, (error) => {
      handleFirestoreError(error, OperationType.LIST, 'system_logs');
    });

    return () => unsubscribe();
  }, []);

  if (!stats) return <div className="flex items-center justify-center h-64"><Loader2 className="animate-spin text-blue-500" /></div>;

  return (
    <div className="space-y-8">
      <h2 className="text-2xl font-bold">Platform Administration</h2>
      
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <AdminStat label="Total Users" value={stats.totalUsers.toLocaleString()} trend={stats.trends.users} />
        <AdminStat label="Active Sessions" value={stats.activeSessions.toString()} trend={stats.trends.sessions} />
        <AdminStat label="App Generations" value={stats.appGenerations.toLocaleString()} trend={stats.trends.generations} />
        <AdminStat label="System Load" value={`${stats.systemLoad}%`} trend={stats.trends.load} />
      </div>

      <div className="bg-[#0f0f0f] border border-white/10 rounded-2xl overflow-hidden">
        <div className="p-6 border-b border-white/10 flex items-center justify-between">
          <h3 className="font-bold">Recent System Events</h3>
          <button className="text-xs text-blue-400 hover:underline">View All Logs</button>
        </div>
        <div className="divide-y divide-white/5">
          {logs.map(log => (
            <AdminLog key={log.id} event={log.event} user={log.user} time={log.time} type={log.type} />
          ))}
          {logs.length === 0 && (
            <div className="p-8 text-center text-white/20 text-sm italic">No system events recorded.</div>
          )}
        </div>
      </div>
    </div>
  );
}

function AdminStat({ label, value, trend }: { label: string, value: string, trend: string }) {
  return (
    <div className="bg-[#0f0f0f] border border-white/10 p-4 rounded-xl">
      <p className="text-white/40 text-xs mb-1">{label}</p>
      <div className="flex items-end justify-between">
        <h4 className="text-xl font-bold">{value}</h4>
        <span className={`text-[10px] font-bold ${trend.startsWith('+') ? 'text-green-500' : 'text-red-500'}`}>{trend}</span>
      </div>
    </div>
  );
}

function AdminLog({ event, user, time, type }: { event: string, user: string, time: string, type: string }) {
  return (
    <div className="p-4 flex items-center justify-between hover:bg-white/5 transition-colors">
      <div className="flex items-center gap-3">
        <div className={`w-2 h-2 rounded-full ${
          type === 'success' ? 'bg-green-500' : type === 'warning' ? 'bg-yellow-500' : type === 'error' ? 'bg-red-500' : 'bg-blue-500'
        }`} />
        <div>
          <p className="text-sm font-medium">{event}</p>
          <p className="text-xs text-white/40">{user}</p>
        </div>
      </div>
      <span className="text-xs text-white/40">{time}</span>
    </div>
  );
}
function ModelsView({ user, token }: { user: any, token: string | null }) {
  const [models, setModels] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (token) {
      fetch('http://localhost:3001/api/factory/models', {
        headers: { 'Authorization': `Bearer ${token}` }
      })
        .then(res => res.json())
        .then(data => {
          setModels(data);
          setLoading(false);
        })
        .catch(err => {
          console.error(err);
          setLoading(false);
        });
    }
  }, [token]);

  if (loading) return <div className="flex items-center justify-center h-64"><Loader2 className="animate-spin text-blue-500" /></div>;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold">AI Model Hub</h2>
        <div className="flex items-center gap-2 text-xs text-white/40">
          <ShieldCheck size={14} className="text-green-500" />
          Enterprise Verified Models
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {models.map(model => (
          <div key={model.id} className="bg-[#0f0f0f] border border-white/10 p-6 rounded-xl hover:border-white/20 transition-all group">
            <div className="flex items-start justify-between mb-4">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-blue-600/10 text-blue-400 rounded-xl flex items-center justify-center group-hover:bg-blue-600 group-hover:text-white transition-all">
                  <Cpu size={24} />
                </div>
                <div>
                  <h3 className="font-bold text-lg">{model.name}</h3>
                  <p className="text-xs text-white/40">{model.provider} • {model.parameters}</p>
                </div>
              </div>
              {model.isFree && (
                <span className="text-[10px] px-2 py-0.5 bg-green-500/10 text-green-400 rounded-full font-bold uppercase">Free Tier</span>
              )}
            </div>
            <p className="text-sm text-white/60 mb-6 leading-relaxed">{model.description}</p>
            <div className="flex items-center justify-between pt-4 border-t border-white/5">
              <div className="flex items-center gap-2">
                <div className="flex -space-x-2">
                  {[1, 2, 3].map(i => (
                    <div key={i} className="w-6 h-6 rounded-full border-2 border-[#0f0f0f] bg-white/10" />
                  ))}
                </div>
                <span className="text-[10px] text-white/30">Used by 2.4k developers</span>
              </div>
              <button className="text-blue-400 text-sm font-medium hover:underline flex items-center gap-1">
                View Docs <Zap size={14} />
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
function SidebarItem({ icon, label, active, onClick }: { icon: React.ReactNode, label: string, active?: boolean, onClick: () => void }) {
  return (
    <button 
      onClick={onClick}
      className={`w-full flex items-center gap-3 px-3 py-2 rounded-lg transition-all duration-200 ${
        active 
          ? 'bg-blue-600/10 text-blue-400 border border-blue-500/20' 
          : 'text-white/60 hover:text-white hover:bg-white/5'
      }`}
    >
      {icon}
      <span className="font-medium text-sm">{label}</span>
    </button>
  );
}

function DashboardView({ user }: { user: any }) {
  const [stats, setStats] = useState({ workspaces: 0, apps: 0, sessions: 0 });
  const [recentLogs, setRecentLogs] = useState<any[]>([]);

  useEffect(() => {
    if (user) {
      // Get workspace count
      const wsQuery = query(collection(db, 'workspaces'), where('ownerId', '==', user.uid));
      const unsubscribeWs = onSnapshot(wsQuery, (snapshot) => {
        setStats(prev => ({ ...prev, workspaces: snapshot.size }));
      });

      // Get recent logs
      const logsQuery = query(
        collection(db, 'system_logs'), 
        where('user', '==', user.email),
        orderBy('time', 'desc'),
        limit(5)
      );
      const unsubscribeLogs = onSnapshot(logsQuery, (snapshot) => {
        setRecentLogs(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
      });

      return () => {
        unsubscribeWs();
        unsubscribeLogs();
      };
    }
  }, [user]);

  return (
    <div className="space-y-8">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <StatCard title="Active Workspaces" value={stats.workspaces.toString()} icon={<Box className="text-blue-400" />} />
        <StatCard title="Total Apps Built" value={stats.workspaces.toString()} icon={<Zap className="text-yellow-400" />} />
        <StatCard title="Sandbox Hours" value="1,240" icon={<Activity className="text-green-400" />} />
      </div>

      <section>
        <h2 className="text-xl font-bold mb-4">Recent Activity</h2>
        <div className="bg-[#0f0f0f] border border-white/10 rounded-xl overflow-hidden">
          {recentLogs.map(log => (
            <ActivityItem 
              key={log.id} 
              title={log.event} 
              time={new Date(log.time).toLocaleString()} 
              status={log.type === 'error' ? 'error' : log.type === 'warning' ? 'warning' : 'success'} 
            />
          ))}
          {recentLogs.length === 0 && (
            <div className="p-8 text-center text-white/20 text-sm italic">No recent activity.</div>
          )}
        </div>
      </section>
    </div>
  );
}

function StatCard({ title, value, icon }: { title: string, value: string, icon: React.ReactNode }) {
  return (
    <div className="bg-[#0f0f0f] border border-white/10 p-6 rounded-xl">
      <div className="flex items-center justify-between mb-4">
        <span className="text-white/50 text-sm font-medium">{title}</span>
        {icon}
      </div>
      <div className="text-3xl font-bold">{value}</div>
    </div>
  );
}

function ActivityItem({ title, time, status }: { title: string, time: string, status: 'success' | 'warning' | 'error' }) {
  return (
    <div className="flex items-center justify-between p-4 border-b border-white/5 last:border-0 hover:bg-white/5 transition-colors">
      <div className="flex items-center gap-4">
        <div className={`w-2 h-2 rounded-full ${
          status === 'success' ? 'bg-green-500' : status === 'warning' ? 'bg-yellow-500' : 'bg-red-500'
        }`} />
        <div>
          <div className="text-sm font-medium">{title}</div>
          <div className="text-xs text-white/40">{time}</div>
        </div>
      </div>
      <ChevronRight size={16} className="text-white/20" />
    </div>
  );
}

function WorkspacesView({ user }: { user: any }) {
  const [workspaces, setWorkspaces] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (user) {
      const q = query(
        collection(db, 'workspaces'), 
        where('ownerId', '==', user.uid),
        orderBy('createdAt', 'desc')
      );
      
      const unsubscribe = onSnapshot(q, (snapshot) => {
        const wsList = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        setWorkspaces(wsList);
        setLoading(false);
      }, (error) => {
        handleFirestoreError(error, OperationType.LIST, 'workspaces');
        setLoading(false);
      });
      
      return () => unsubscribe();
    }
  }, [user]);

  const handleDelete = async (id: string) => {
    try {
      await deleteDoc(doc(db, 'workspaces', id));
      
      // Log the event
      await addDoc(collection(db, 'system_logs'), {
        id: Date.now().toString(),
        event: 'Workspace Deleted',
        user: user.email,
        time: new Date().toISOString(),
        type: 'warning'
      });
    } catch (err) {
      console.error('Delete failed', err);
    }
  };

  const handleSync = async (id: string, repoUrl?: string) => {
    try {
      const wsRef = doc(db, 'workspaces', id);
      await updateDoc(wsRef, { status: 'syncing' });
      
      // Simulate sync process
      setTimeout(async () => {
        await updateDoc(wsRef, { 
          status: 'running',
          lastSyncedAt: new Date().toISOString(),
          updatedAt: new Date().toISOString()
        });
        
        await addDoc(collection(db, 'system_logs'), {
          id: Date.now().toString(),
          event: `Workspace Synced to ${repoUrl || 'Repository'}`,
          user: user.email,
          time: new Date().toISOString(),
          type: 'success'
        });
      }, 2000);
    } catch (err) {
      console.error('Sync failed', err);
    }
  };

  if (loading) return <div className="flex items-center justify-center h-64"><Loader2 className="animate-spin text-blue-500" /></div>;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold">Your Workspaces</h2>
        <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium flex items-center gap-2 transition-colors">
          <PlusCircle size={18} />
          New Workspace
        </button>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {workspaces.map(ws => (
          <WorkspaceCard 
            key={ws.id} 
            workspace={ws}
            onDelete={() => handleDelete(ws.id)}
            onSync={() => handleSync(ws.id, ws.repoUrl)}
          />
        ))}
        {workspaces.length === 0 && (
          <div className="col-span-full py-20 text-center border-2 border-dashed border-white/5 rounded-2xl">
            <Box size={48} className="mx-auto mb-4 text-white/10" />
            <p className="text-white/40">No workspaces found. Start by generating an app!</p>
          </div>
        )}
      </div>
    </div>
  );
}

function WorkspaceCard({ workspace, onDelete, onSync }: { workspace: any, onDelete: () => void, onSync: () => void }) {
  const isSyncing = workspace.status === 'syncing';
  
  return (
    <div className="bg-[#0f0f0f] border border-white/10 p-6 rounded-xl hover:border-white/20 transition-all cursor-pointer group relative overflow-hidden">
      {isSyncing && (
        <div className="absolute inset-0 bg-blue-600/5 backdrop-blur-[1px] flex items-center justify-center z-10">
          <div className="flex flex-col items-center gap-2">
            <RefreshCw size={24} className="animate-spin text-blue-400" />
            <span className="text-[10px] font-bold text-blue-400 uppercase tracking-widest">Syncing to Repo...</span>
          </div>
        </div>
      )}
      
      <div className="absolute top-4 right-4 flex items-center gap-2 z-20">
        <button 
          disabled={isSyncing}
          onClick={(e) => {
            e.stopPropagation();
            onSync();
          }}
          className={`text-white/20 hover:text-blue-400 transition-colors ${isSyncing ? 'opacity-0' : ''}`}
          title="Sync to Repository"
        >
          <RefreshCw size={14} />
        </button>
        <button 
          disabled={isSyncing}
          onClick={(e) => {
            e.stopPropagation();
            onDelete();
          }}
          className={`text-white/20 hover:text-red-500 transition-colors ${isSyncing ? 'opacity-0' : ''}`}
        >
          <LogOut size={14} />
        </button>
      </div>
      <div className="flex items-center justify-between mb-4">
        <div className="w-10 h-10 bg-white/5 rounded-lg flex items-center justify-center group-hover:bg-blue-600/20 group-hover:text-blue-400 transition-colors">
          <Box size={20} />
        </div>
        <span className={`text-xs px-2 py-1 rounded-full ${
          workspace.status === 'running' ? 'bg-green-500/10 text-green-400' : 'bg-white/10 text-white/40'
        }`}>
          {workspace.status}
        </span>
      </div>
      <h3 className="font-bold mb-1">{workspace.name}</h3>
      <p className="text-sm text-white/40 mb-4">{workspace.templateId}</p>
      
      {workspace.repoUrl && (
        <div className="mb-4 p-2 bg-white/5 rounded border border-white/5 text-[10px] font-mono text-white/40 truncate">
          {workspace.repoUrl}
        </div>
      )}
      
      <div className="flex items-center gap-4 pt-4 border-t border-white/5 text-[10px] text-white/30">
        <div className="flex items-center gap-1">
          <Globe size={10} />
          <span>{workspace.repoUrl ? 'Repo Linked' : 'Local Only'}</span>
        </div>
        <div className="flex items-center gap-1">
          <Clock size={10} />
          <span>{workspace.lastSyncedAt ? new Date(workspace.lastSyncedAt).toLocaleTimeString() : 'Never'}</span>
        </div>
      </div>
    </div>
  );
}

function AppFactoryView({ templates, onGenerate, generating, currentJob, user, token }: { 
  templates: Template[], 
  onGenerate: (desc: string, templateId: string, target: string, modelId?: string) => void,
  generating: boolean,
  currentJob: Job | null,
  user: any,
  token: string | null
}) {
  const [description, setDescription] = useState('');
  const [templateId, setTemplateId] = useState(templates[0]?.id || '');
  const [target, setTarget] = useState('Cloud Run (GCP)');
  const [modelId, setModelId] = useState('');
  const [availableModels, setAvailableModels] = useState<any[]>([]);

  useEffect(() => {
    if (token) {
      fetch('http://localhost:3001/api/factory/models', {
        headers: { 'Authorization': `Bearer ${token}` }
      })
        .then(res => res.json())
        .then(data => setAvailableModels(data))
        .catch(err => console.error('Failed to fetch models', err));
    }
  }, [token]);

  // Filter models based on template support
  const filteredModels = availableModels.filter(m => {
    const template = templates.find(t => t.id === templateId);
    if (!template) return true;
    // If template doesn't specify supported models, allow all
    if (!(template as any).supportedModels) return true;
    return (template as any).supportedModels.includes(m.id);
  });

  return (
    <div className="max-w-3xl mx-auto space-y-8">
      <div className="text-center">
        <h2 className="text-3xl font-bold mb-2">BeMore</h2>
        <p className="text-white/50 text-lg">Build and run BeMore experiences with shared Prismtek product infrastructure.</p>
      </div>

      <div className="bg-[#0f0f0f] border border-white/10 p-8 rounded-2xl space-y-6">
        <div className="space-y-2">
          <label className="text-sm font-medium text-white/70">What would you like to build?</label>
          <textarea 
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            className="w-full bg-black/50 border border-white/10 rounded-xl p-4 h-32 focus:outline-none focus:border-blue-500/50 transition-colors placeholder:text-white/20"
            placeholder="e.g. A customer support agent that integrates with Slack and handles refund requests..."
          />
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="space-y-2">
            <label className="text-sm font-medium text-white/70">Base Template</label>
            <select 
              value={templateId}
              onChange={(e) => setTemplateId(e.target.value)}
              className="w-full bg-black/50 border border-white/10 rounded-xl p-3 focus:outline-none focus:border-blue-500/50 transition-colors"
            >
              {templates.map(t => (
                <option key={t.id} value={t.id}>{t.name}</option>
              ))}
            </select>
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium text-white/70">AI Model</label>
            <select 
              value={modelId}
              onChange={(e) => setModelId(e.target.value)}
              className="w-full bg-black/50 border border-white/10 rounded-xl p-3 focus:outline-none focus:border-blue-500/50 transition-colors"
            >
              <option value="">Default (Template Optimized)</option>
              {filteredModels.map(m => (
                <option key={m.id} value={m.id}>{m.name} ({m.parameters})</option>
              ))}
            </select>
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium text-white/70">Deployment Target</label>
            <select 
              value={target}
              onChange={(e) => setTarget(e.target.value)}
              className="w-full bg-black/50 border border-white/10 rounded-xl p-3 focus:outline-none focus:border-blue-500/50 transition-colors"
            >
              <option>Cloud Run (GCP)</option>
              <option>Vercel</option>
              <option>Edge (Local)</option>
            </select>
          </div>
        </div>

        <button 
          disabled={generating || !description}
          onClick={() => onGenerate(description, templateId, target, modelId)}
          className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-blue-600/50 disabled:cursor-not-allowed text-white py-4 rounded-xl font-bold text-lg flex items-center justify-center gap-2 transition-all active:scale-[0.98]"
        >
          {generating ? <Loader2 size={20} className="animate-spin" /> : <Zap size={20} />}
          {generating ? 'Generating...' : 'Generate Application'}
        </button>

        {currentJob && (
          <div className="space-y-2">
            <div className="flex justify-between text-xs font-medium text-white/50">
              <span>{currentJob.status === 'completed' ? 'Generation Complete' : 'Generating Application...'}</span>
              <span>{currentJob.progress}%</span>
            </div>
            <div className="w-full bg-white/5 rounded-full h-1.5 overflow-hidden">
              <motion.div 
                className="bg-blue-500 h-full"
                initial={{ width: 0 }}
                animate={{ width: `${currentJob.progress}%` }}
              />
            </div>
          </div>
        )}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <FeatureHighlight 
          icon={<Shield className="text-blue-400" />} 
          title="Safe by Default" 
          description="All generated apps include built-in security and sandboxing." 
        />
        <FeatureHighlight 
          icon={<Zap className="text-yellow-400" />} 
          title="Fast Deployment" 
          description="One-click deployment to your preferred cloud provider." 
        />
      </div>
    </div>
  );
}

function FeatureHighlight({ icon, title, description }: { icon: React.ReactNode, title: string, description: string }) {
  return (
    <div className="flex gap-4 p-4 bg-white/5 rounded-xl border border-white/10">
      <div className="mt-1">{icon}</div>
      <div>
        <h4 className="font-bold text-sm">{title}</h4>
        <p className="text-xs text-white/40 leading-relaxed">{description}</p>
      </div>
    </div>
  );
}

function SandboxView({ user, token }: { user: any, token: string | null }) {
  const [sessions, setSessions] = useState<any[]>([]);
  const [workspaces, setWorkspaces] = useState<any[]>([]);
  const [selectedWorkspace, setSelectedWorkspace] = useState<string>('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (user) {
      const q = query(collection(db, 'workspaces'), where('ownerId', '==', user.uid));
      const unsubscribe = onSnapshot(q, (snapshot) => {
        setWorkspaces(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
      });
      return () => unsubscribe();
    }
  }, [user]);

  const fetchSessions = async () => {
    if (!token) return;
    try {
      const res = await fetch('http://localhost:3001/api/sandbox/sessions', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      const data = await res.json();
      setSessions(data);
    } catch (err) {
      console.error(err);
    }
  };

  useEffect(() => {
    if (token) {
      fetchSessions();
    }
  }, [token]);

  const handleLaunch = async () => {
    if (!selectedWorkspace || !token) return;
    setLoading(true);
    try {
      await fetch('http://localhost:3001/api/sandbox/launch', {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ workspaceId: selectedWorkspace })
      });
      await fetchSessions();
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold">Sandboxed Runtime</h2>
        <div className="flex gap-2">
          <select 
            value={selectedWorkspace}
            onChange={(e) => setSelectedWorkspace(e.target.value)}
            className="bg-black/50 border border-white/10 rounded-lg px-3 py-2 text-sm focus:outline-none focus:border-blue-500/50 transition-colors"
          >
            <option value="">Select Workspace</option>
            {workspaces.map(ws => (
              <option key={ws.id} value={ws.id}>{ws.name}</option>
            ))}
          </select>
          <button className="bg-white/5 hover:bg-white/10 text-white px-4 py-2 rounded-lg font-medium transition-colors">
            Reset Environment
          </button>
          <button 
            onClick={handleLaunch}
            disabled={loading || !selectedWorkspace}
            className="bg-blue-600 hover:bg-blue-700 disabled:bg-blue-600/50 text-white px-4 py-2 rounded-lg font-medium transition-colors flex items-center gap-2"
          >
            {loading ? <Loader2 size={18} className="animate-spin" /> : <PlusCircle size={18} />}
            New Session
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
        {sessions.map(session => (
          <div key={session.id} className="bg-[#0f0f0f] border border-white/10 p-4 rounded-xl flex items-center justify-between">
            <div>
              <div className="text-sm font-bold">{session.id}</div>
              <div className="text-xs text-white/40">Expires: {new Date(session.expiresAt).toLocaleTimeString()}</div>
            </div>
            <div className="flex items-center gap-3">
              <span className="text-[10px] px-2 py-0.5 bg-green-500/10 text-green-400 rounded-full uppercase font-bold">{session.status}</span>
              <a href={session.url} target="_blank" rel="noopener noreferrer" className="text-blue-400 text-xs hover:underline">Connect</a>
              <button 
                onClick={async () => {
                  await fetch(`http://localhost:3001/api/sandbox/sessions/${session.id}`, {
                    method: 'DELETE',
                    headers: { 'Authorization': `Bearer ${token}` }
                  });
                  fetchSessions();
                }}
                className="text-red-500/60 hover:text-red-500 transition-colors"
              >
                <LogOut size={14} />
              </button>
            </div>
          </div>
        ))}
      </div>

      <div className="bg-black rounded-xl border border-white/10 overflow-hidden h-[500px] flex flex-col">
        <div className="bg-[#0f0f0f] border-b border-white/10 p-3 flex items-center gap-4">
          <div className="flex gap-1.5">
            <div className="w-3 h-3 rounded-full bg-red-500/50" />
            <div className="w-3 h-3 rounded-full bg-yellow-500/50" />
            <div className="w-3 h-3 rounded-full bg-green-500/50" />
          </div>
          <div className="text-xs font-mono text-white/40">prismtek-sandbox-v1.0.4</div>
        </div>
        <div className="flex-1 p-6 font-mono text-sm text-green-400/90 overflow-y-auto space-y-2">
          {sessions.length > 0 && sessions[0].logs ? (
            sessions[0].logs.map((log: string, i: number) => (
              <p key={i} className={log.startsWith('#') ? 'text-white/40' : 'text-white'}>{log}</p>
            ))
          ) : (
            <p className="text-white/40"># No active session logs. Launch a new session to begin.</p>
          )}
          {sessions.length > 0 && (
            <>
              <p><span className="text-blue-400">prismtek@sandbox</span>:<span className="text-yellow-400">~</span>$ bemore status</p>
              <p className="text-white">BeMore runtime - Active</p>
              <p className="text-white">Uptime: 0h 14m</p>
              <p className="text-white">Memory: 124MB / 512MB</p>
              <p><span className="text-blue-400">prismtek@sandbox</span>:<span className="text-yellow-400">~</span>$ _</p>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
