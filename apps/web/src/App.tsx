import { useState } from 'react';
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
  ChevronRight
} from 'lucide-react';
import { motion } from 'motion/react';

export default function App() {
  const [activeTab, setActiveTab] = useState('dashboard');

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
          </nav>
        </div>

        <div className="mt-auto p-6 border-t border-white/10">
          <nav className="space-y-1">
            <SidebarItem icon={<Settings size={20} />} label="Settings" onClick={() => {}} />
            <SidebarItem icon={<LogOut size={20} />} label="Logout" onClick={() => {}} />
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
          {activeTab === 'dashboard' && <DashboardView />}
          {activeTab === 'workspaces' && <WorkspacesView />}
          {activeTab === 'factory' && <AppFactoryView />}
          {activeTab === 'sandbox' && <SandboxView />}
        </div>
      </main>
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

function WorkspacesView() {
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
        <WorkspaceCard name="Customer Support Bot" template="BMO Agent" status="Running" />
        <WorkspaceCard name="Data Analysis Tool" template="OpenClaw" status="Paused" />
        <WorkspaceCard name="Prismtek Site Dev" template="Static Site" status="Running" />
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

function AppFactoryView() {
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
            className="w-full bg-black/50 border border-white/10 rounded-xl p-4 h-32 focus:outline-none focus:border-blue-500/50 transition-colors placeholder:text-white/20"
            placeholder="e.g. A customer support agent that integrates with Slack and handles refund requests..."
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-2">
            <label className="text-sm font-medium text-white/70">Base Template</label>
            <select className="w-full bg-black/50 border border-white/10 rounded-xl p-3 focus:outline-none focus:border-blue-500/50 transition-colors">
              <option>BMO Agent</option>
              <option>OpenClaw Harness</option>
              <option>Omni-OpenClaw Starter</option>
            </select>
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium text-white/70">Deployment Target</label>
            <select className="w-full bg-black/50 border border-white/10 rounded-xl p-3 focus:outline-none focus:border-blue-500/50 transition-colors">
              <option>Cloud Run (GCP)</option>
              <option>Vercel</option>
              <option>Edge (Local)</option>
            </select>
          </div>
        </div>

        <button className="w-full bg-blue-600 hover:bg-blue-700 text-white py-4 rounded-xl font-bold text-lg flex items-center justify-center gap-2 transition-all active:scale-[0.98]">
          <Zap size={20} />
          Generate Application
        </button>
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

function SandboxView() {
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

      <div className="bg-black rounded-xl border border-white/10 overflow-hidden h-[600px] flex flex-col">
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
