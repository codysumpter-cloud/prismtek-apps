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
  ChevronRight,
  Loader2,
  CreditCard,
  ShieldCheck,
  CheckCircle2
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

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
  const [token, setToken] = useState<string | null>(localStorage.getItem('prismtek_token'));
  const [activeTab, setActiveTab] = useState('dashboard');
  const [templates, setTemplates] = useState<Template[]>([]);
  const [generating, setGenerating] = useState(false);
  const [currentJob, setCurrentJob] = useState<Job | null>(null);

  useEffect(() => {
    if (token) {
      fetchTemplates();
    }
  }, [token]);

  const fetchTemplates = async () => {
    try {
      const res = await fetch('http://localhost:3001/api/factory/templates', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.status === 401 || res.status === 403) {
        handleLogout();
        return;
      }
      const data = await res.json();
      setTemplates(data);
    } catch (err) {
      console.error('Failed to fetch templates', err);
    }
  };

  const handleLogin = (userData: any, userToken: string) => {
    setUser(userData);
    setToken(userToken);
    localStorage.setItem('prismtek_token', userToken);
  };

  const handleLogout = () => {
    setUser(null);
    setToken(null);
    localStorage.removeItem('prismtek_token');
  };

  const isAdmin = user?.role === 'admin' || user?.email === 'Cody.Sumpter@gmail.com';

  const handleGenerate = async (description: string, templateId: string, target: string) => {
    setGenerating(true);
    try {
      const res = await fetch('http://localhost:3001/api/factory/generate', {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ description, templateId, target })
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

  if (!token) {
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
            <span className="font-bold text-xl tracking-tight">Prismtek</span>
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
              icon={<PlusCircle size={20} />} 
              label="App Factory" 
              active={activeTab === 'factory'} 
              onClick={() => setActiveTab('factory')}
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
              {activeTab === 'dashboard' && <DashboardView />}
              {activeTab === 'workspaces' && <WorkspacesView token={token} />}
              {activeTab === 'factory' && (
                <AppFactoryView 
                  templates={templates} 
                  onGenerate={handleGenerate} 
                  generating={generating}
                  currentJob={currentJob}
                />
              )}
              {activeTab === 'sandbox' && <SandboxView token={token} />}
              {activeTab === 'billing' && <BillingView />}
              {activeTab === 'admin' && <AdminView />}
            </motion.div>
          </AnimatePresence>
        </div>
      </main>
    </div>
  );
}

function AuthView({ onLogin }: { onLogin: (user: any, token: string) => void }) {
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    const endpoint = isLogin ? '/api/auth/login' : '/api/auth/register';
    try {
      const res = await fetch(`http://localhost:3001${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password, name })
      });
      const data = await res.json();
      if (res.ok) {
        onLogin(data.user, data.token);
      } else {
        setError(data.error || 'Something went wrong');
      }
    } catch (err) {
      setError('Failed to connect to server');
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
          <span className="font-bold text-2xl tracking-tight text-white">Prismtek</span>
        </div>

        <h2 className="text-xl font-bold text-center mb-2">{isLogin ? 'Welcome Back' : 'Create Account'}</h2>
        <p className="text-white/40 text-center text-sm mb-8">
          {isLogin ? 'Sign in to manage your AI agents' : 'Join Prismtek to build production-grade apps'}
        </p>

        <form onSubmit={handleSubmit} className="space-y-4">
          {!isLogin && (
            <div className="space-y-1">
              <label className="text-xs font-medium text-white/50 ml-1">Full Name</label>
              <input 
                type="text" 
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
                className="w-full bg-black/50 border border-white/10 rounded-xl px-4 py-3 focus:outline-none focus:border-blue-500/50 transition-colors text-white"
                placeholder="John Doe"
              />
            </div>
          )}
          <div className="space-y-1">
            <label className="text-xs font-medium text-white/50 ml-1">Email Address</label>
            <input 
              type="email" 
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              className="w-full bg-black/50 border border-white/10 rounded-xl px-4 py-3 focus:outline-none focus:border-blue-500/50 transition-colors text-white"
              placeholder="name@example.com"
            />
          </div>
          <div className="space-y-1">
            <label className="text-xs font-medium text-white/50 ml-1">Password</label>
            <input 
              type="password" 
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              className="w-full bg-black/50 border border-white/10 rounded-xl px-4 py-3 focus:outline-none focus:border-blue-500/50 transition-colors text-white"
              placeholder="••••••••"
            />
          </div>

          {error && <p className="text-red-500 text-xs text-center">{error}</p>}

          <button 
            disabled={loading}
            className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-blue-600/50 text-white py-3 rounded-xl font-bold transition-all active:scale-[0.98] flex items-center justify-center gap-2"
          >
            {loading && <Loader2 size={18} className="animate-spin" />}
            {isLogin ? 'Sign In' : 'Create Account'}
          </button>
        </form>

        <div className="mt-6 text-center">
          <button 
            onClick={() => setIsLogin(!isLogin)}
            className="text-sm text-blue-400 hover:text-blue-300 transition-colors"
          >
            {isLogin ? "Don't have an account? Sign Up" : "Already have an account? Sign In"}
          </button>
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

function AdminView() {
  return (
    <div className="space-y-8">
      <h2 className="text-2xl font-bold">Platform Administration</h2>
      
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <AdminStat label="Total Users" value="1,284" trend="+12%" />
        <AdminStat label="Active Sessions" value="84" trend="+5%" />
        <AdminStat label="App Generations" value="3,492" trend="+24%" />
        <AdminStat label="System Load" value="14%" trend="-2%" />
      </div>

      <div className="bg-[#0f0f0f] border border-white/10 rounded-2xl overflow-hidden">
        <div className="p-6 border-b border-white/10 flex items-center justify-between">
          <h3 className="font-bold">Recent System Events</h3>
          <button className="text-xs text-blue-400 hover:underline">View All Logs</button>
        </div>
        <div className="divide-y divide-white/5">
          <AdminLog event="New User Registration" user="sarah.j@example.com" time="2m ago" />
          <AdminLog event="Sandbox Launch" user="mike.r@prismtek.dev" time="5m ago" />
          <AdminLog event="App Generation Success" user="dev-team-alpha" time="12m ago" />
          <AdminLog event="System Backup Completed" user="System" time="1h ago" />
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

function AdminLog({ event, user, time }: { event: string, user: string, time: string }) {
  return (
    <div className="p-4 flex items-center justify-between hover:bg-white/5 transition-colors">
      <div className="flex items-center gap-3">
        <div className="w-2 h-2 rounded-full bg-blue-500" />
        <div>
          <p className="text-sm font-medium">{event}</p>
          <p className="text-xs text-white/40">{user}</p>
        </div>
      </div>
      <span className="text-xs text-white/40">{time}</span>
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

function DashboardView() {
  return (
    <div className="space-y-8">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <StatCard title="Active Workspaces" value="12" icon={<Box className="text-blue-400" />} />
        <StatCard title="Total Apps Built" value="48" icon={<Zap className="text-yellow-400" />} />
        <StatCard title="Sandbox Hours" value="1,240" icon={<Activity className="text-green-400" />} />
      </div>

      <section>
        <h2 className="text-xl font-bold mb-4">Recent Activity</h2>
        <div className="bg-[#0f0f0f] border border-white/10 rounded-xl overflow-hidden">
          <ActivityItem title="OpenClaw Instance Launched" time="2 minutes ago" status="success" />
          <ActivityItem title="BMO Agent Scaffolding" time="45 minutes ago" status="success" />
          <ActivityItem title="Sandbox Security Audit" time="2 hours ago" status="warning" />
          <ActivityItem title="New User Registration" time="5 hours ago" status="success" />
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

function WorkspacesView({ token }: { token: string }) {
  const [workspaces, setWorkspaces] = useState<any[]>([]);

  useEffect(() => {
    fetch('http://localhost:3001/api/workspaces', {
      headers: { 'Authorization': `Bearer ${token}` }
    })
      .then(res => res.json())
      .then(data => setWorkspaces(data))
      .catch(err => console.error(err));
  }, [token]);

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
          <WorkspaceCard key={ws.id} name={ws.name} template={ws.template} status={ws.status} />
        ))}
      </div>
    </div>
  );
}

function WorkspaceCard({ name, template, status }: { name: string, template: string, status: string }) {
  return (
    <div className="bg-[#0f0f0f] border border-white/10 p-6 rounded-xl hover:border-white/20 transition-all cursor-pointer group">
      <div className="flex items-center justify-between mb-4">
        <div className="w-10 h-10 bg-white/5 rounded-lg flex items-center justify-center group-hover:bg-blue-600/20 group-hover:text-blue-400 transition-colors">
          <Box size={20} />
        </div>
        <span className={`text-xs px-2 py-1 rounded-full ${
          status === 'Running' ? 'bg-green-500/10 text-green-400' : 'bg-white/10 text-white/40'
        }`}>
          {status}
        </span>
      </div>
      <h3 className="font-bold mb-1">{name}</h3>
      <p className="text-sm text-white/40">{template}</p>
    </div>
  );
}

function AppFactoryView({ templates, onGenerate, generating, currentJob }: { 
  templates: Template[], 
  onGenerate: (desc: string, templateId: string, target: string) => void,
  generating: boolean,
  currentJob: Job | null
}) {
  const [description, setDescription] = useState('');
  const [templateId, setTemplateId] = useState(templates[0]?.id || '');
  const [target, setTarget] = useState('Cloud Run (GCP)');

  return (
    <div className="max-w-3xl mx-auto space-y-8">
      <div className="text-center">
        <h2 className="text-3xl font-bold mb-2">Enterprise App Factory</h2>
        <p className="text-white/50 text-lg">Generate production-grade applications in seconds.</p>
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

        <div className="grid grid-cols-2 gap-4">
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
          onClick={() => onGenerate(description, templateId, target)}
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

function SandboxView({ token }: { token: string }) {
  const [sessions, setSessions] = useState<any[]>([]);

  useEffect(() => {
    fetch('http://localhost:3001/api/sandbox/sessions', {
      headers: { 'Authorization': `Bearer ${token}` }
    })
      .then(res => res.json())
      .then(data => setSessions(data))
      .catch(err => console.error(err));
  }, [token]);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold">Sandboxed Runtime</h2>
        <div className="flex gap-2">
          <button className="bg-white/5 hover:bg-white/10 text-white px-4 py-2 rounded-lg font-medium transition-colors">
            Reset Environment
          </button>
          <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors">
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
            <a href={session.url} target="_blank" rel="noopener noreferrer" className="text-blue-400 text-xs hover:underline">Connect</a>
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
          <p className="text-white/40"># Initializing Prismtek Sandbox...</p>
          <p className="text-white/40"># Mounting virtual filesystem...</p>
          <p className="text-white/40"># Loading OpenClaw harness...</p>
          <p className="text-white/40"># Environment ready.</p>
          <p><span className="text-blue-400">prismtek@sandbox</span>:<span className="text-yellow-400">~</span>$ openclaw status</p>
          <p className="text-white">OpenClaw v2.4.0 - Active</p>
          <p className="text-white">Uptime: 0h 14m</p>
          <p className="text-white">Memory: 124MB / 512MB</p>
          <p><span className="text-blue-400">prismtek@sandbox</span>:<span className="text-yellow-400">~</span>$ _</p>
        </div>
      </div>
    </div>
  );
}
