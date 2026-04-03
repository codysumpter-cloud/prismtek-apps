import { motion } from 'motion/react';
import { Plus, Play, Save, Code, Zap, MessageSquare, Globe, Terminal } from 'lucide-react';
import { useState } from 'react';
import { cn } from '../lib/utils';

interface SkillTrigger {
  type: 'voice' | 'text' | 'event';
  value: string;
}

interface SkillResponse {
  type: 'speech' | 'text' | 'action';
  content: string;
}

export default function SkillBuilder() {
  const [name, setName] = useState('My New Skill');
  const [triggers, setTriggers] = useState<SkillTrigger[]>([{ type: 'text', value: 'hello' }]);
  const [responses, setResponses] = useState<SkillResponse[]>([{ type: 'text', content: 'Hi there!' }]);
  const [isTesting, setIsTesting] = useState(false);

  const addTrigger = () => setTriggers([...triggers, { type: 'text', value: '' }]);
  const addResponse = () => setResponses([...responses, { type: 'text', content: '' }]);

  return (
    <div className="max-w-5xl mx-auto px-4 py-12">
      <div className="flex justify-between items-center mb-8">
        <div>
          <h2 className="text-3xl font-display font-bold mb-2">Skill Builder</h2>
          <p className="text-slate-400">Define triggers, responses, and logic for your edge AI skill.</p>
        </div>
        <div className="flex gap-3">
          <button className="px-4 py-2 rounded-xl bg-white/5 border border-white/10 text-sm font-medium hover:bg-white/10 transition-colors flex items-center gap-2">
            <Save className="w-4 h-4" />
            Save Draft
          </button>
          <button className="px-4 py-2 rounded-xl bg-edge-blue text-white text-sm font-medium hover:bg-edge-blue/80 transition-colors flex items-center gap-2">
            <Zap className="w-4 h-4" />
            Deploy to Edge
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Editor */}
        <div className="lg:col-span-2 space-y-8">
          <div className="glass-panel p-6">
            <label className="block text-xs font-bold uppercase tracking-widest text-slate-500 mb-4">Skill Name</label>
            <input 
              type="text" 
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full bg-slate-900 border border-white/10 rounded-xl px-4 py-3 text-lg font-display focus:outline-none focus:border-edge-blue/50"
            />
          </div>

          {/* Triggers */}
          <div className="glass-panel p-6">
            <div className="flex justify-between items-center mb-6">
              <label className="text-xs font-bold uppercase tracking-widest text-slate-500">Triggers</label>
              <button 
                onClick={addTrigger}
                className="p-1.5 rounded-lg bg-edge-blue/10 text-edge-blue hover:bg-edge-blue hover:text-white transition-all"
              >
                <Plus className="w-4 h-4" />
              </button>
            </div>
            <div className="space-y-4">
              {triggers.map((trigger, i) => (
                <div key={i} className="flex gap-3">
                  <select 
                    value={trigger.type}
                    onChange={(e) => {
                      const newTriggers = [...triggers];
                      newTriggers[i].type = e.target.value as any;
                      setTriggers(newTriggers);
                    }}
                    className="bg-slate-900 border border-white/10 rounded-xl px-3 py-2 text-sm focus:outline-none"
                  >
                    <option value="text">Text Match</option>
                    <option value="voice">Wake Word</option>
                    <option value="event">System Event</option>
                  </select>
                  <input 
                    type="text" 
                    placeholder="e.g. 'Hey BMO'"
                    value={trigger.value}
                    onChange={(e) => {
                      const newTriggers = [...triggers];
                      newTriggers[i].value = e.target.value;
                      setTriggers(newTriggers);
                    }}
                    className="flex-1 bg-slate-900 border border-white/10 rounded-xl px-4 py-2 text-sm focus:outline-none"
                  />
                </div>
              ))}
            </div>
          </div>

          {/* Responses */}
          <div className="glass-panel p-6">
            <div className="flex justify-between items-center mb-6">
              <label className="text-xs font-bold uppercase tracking-widest text-slate-500">Responses</label>
              <button 
                onClick={addResponse}
                className="p-1.5 rounded-lg bg-edge-purple/10 text-edge-purple hover:bg-edge-purple hover:text-white transition-all"
              >
                <Plus className="w-4 h-4" />
              </button>
            </div>
            <div className="space-y-4">
              {responses.map((resp, i) => (
                <div key={i} className="flex gap-3">
                  <select 
                    value={resp.type}
                    onChange={(e) => {
                      const newResponses = [...responses];
                      newResponses[i].type = e.target.value as any;
                      setResponses(newResponses);
                    }}
                    className="bg-slate-900 border border-white/10 rounded-xl px-3 py-2 text-sm focus:outline-none"
                  >
                    <option value="text">Text Output</option>
                    <option value="speech">TTS Speech</option>
                    <option value="action">Device Action</option>
                  </select>
                  <input 
                    type="text" 
                    placeholder="Response content..."
                    value={resp.content}
                    onChange={(e) => {
                      const newResponses = [...responses];
                      newResponses[i].content = e.target.value;
                      setResponses(newResponses);
                    }}
                    className="flex-1 bg-slate-900 border border-white/10 rounded-xl px-4 py-2 text-sm focus:outline-none"
                  />
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Sidebar / Preview */}
        <div className="space-y-8">
          <div className="glass-panel p-6 bg-edge-blue/5 border-edge-blue/20">
            <h4 className="text-sm font-bold mb-4 flex items-center gap-2">
              <Play className="w-4 h-4 text-edge-blue" />
              Live Preview
            </h4>
            <div className="bg-slate-950 rounded-xl p-4 h-48 mb-4 font-mono text-xs text-slate-400 overflow-y-auto">
              {isTesting ? (
                <div className="space-y-2">
                  <div className="text-edge-blue">[System] Initializing Gemma-2B...</div>
                  <div className="text-emerald-400">[System] Model loaded on NPU.</div>
                  <div className="text-white">User: {triggers[0].value}</div>
                  <div className="text-edge-purple">BMO: {responses[0].content}</div>
                </div>
              ) : (
                <div className="h-full flex items-center justify-center italic opacity-50">
                  Click 'Test Skill' to run simulation
                </div>
              )}
            </div>
            <button 
              onClick={() => setIsTesting(!isTesting)}
              className={cn(
                "w-full py-2 rounded-xl text-sm font-bold transition-all",
                isTesting ? "bg-red-500/10 text-red-400 border border-red-500/20" : "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20"
              )}
            >
              {isTesting ? 'Stop Simulation' : 'Test Skill'}
            </button>
          </div>

          <div className="glass-panel p-6">
            <h4 className="text-sm font-bold mb-4 flex items-center gap-2">
              <Code className="w-4 h-4 text-slate-400" />
              Export Config
            </h4>
            <pre className="bg-slate-950 rounded-xl p-4 text-[10px] font-mono text-slate-500 overflow-x-auto">
{`{
  "name": "${name}",
  "version": "1.0.0",
  "triggers": ${JSON.stringify(triggers, null, 2)},
  "responses": ${JSON.stringify(responses, null, 2)}
}`}
            </pre>
          </div>
        </div>
      </div>
    </div>
  );
}
