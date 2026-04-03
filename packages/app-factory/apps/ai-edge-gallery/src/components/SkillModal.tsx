import { motion, AnimatePresence } from 'motion/react';
import { X, Zap, Cpu, Shield, MessageSquare, Send, Loader2 } from 'lucide-react';
import { AISkill } from '../constants';
import { useState, useRef, useEffect } from 'react';
import { GoogleGenAI } from '@google/genai';
import ReactMarkdown from 'react-markdown';
import { cn } from '../lib/utils';

interface SkillModalProps {
  skill: AISkill | null;
  onClose: () => void;
}

export default function SkillModal({ skill, onClose }: SkillModalProps) {
  const [prompt, setPrompt] = useState('');
  const [messages, setMessages] = useState<{ role: 'user' | 'ai'; content: string }[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  if (!skill) return null;

  const handleAsk = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!prompt.trim() || isLoading) return;

    const userMsg = prompt;
    setPrompt('');
    setMessages(prev => [...prev, { role: 'user', content: userMsg }]);
    setIsLoading(true);

    try {
      const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
      const response = await ai.models.generateContent({
        model: 'gemini-3-flash-preview',
        contents: [
          {
            role: 'user',
            parts: [{ text: `You are an expert in Edge AI. The user is asking about the skill: "${skill.title}". 
            Description: ${skill.description}. 
            Details: ${skill.details}.
            
            User question: ${userMsg}` }]
          }
        ],
        config: {
          systemInstruction: "You are a helpful assistant for the AI Edge Gallery. Provide concise, technical, yet accessible information about edge AI skills."
        }
      });

      setMessages(prev => [...prev, { role: 'ai', content: response.text || 'Sorry, I could not generate a response.' }]);
    } catch (error) {
      console.error('Gemini Error:', error);
      setMessages(prev => [...prev, { role: 'ai', content: 'Error connecting to the AI service. Please check your API key.' }]);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          onClick={onClose}
          className="absolute inset-0 bg-slate-950/80 backdrop-blur-sm"
        />
        
        <motion.div
          initial={{ opacity: 0, scale: 0.9, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.9, y: 20 }}
          className="relative w-full max-w-4xl max-h-[90vh] glass-panel overflow-hidden flex flex-col md:flex-row"
        >
          <button 
            onClick={onClose}
            className="absolute top-4 right-4 p-2 rounded-full bg-white/5 hover:bg-white/10 transition-colors z-10"
          >
            <X className="w-5 h-5" />
          </button>

          {/* Info Side */}
          <div className="w-full md:w-1/2 p-8 border-b md:border-b-0 md:border-r border-white/10 overflow-y-auto">
            <div className="flex items-center gap-3 mb-6">
              <div className="p-3 rounded-xl bg-edge-blue/10 text-edge-blue">
                <Zap className="w-6 h-6" />
              </div>
              <h2 className="text-2xl font-display font-bold">{skill.title}</h2>
            </div>

            <div className="space-y-6">
              <div>
                <h4 className="text-xs font-bold uppercase tracking-widest text-slate-500 mb-2">Overview</h4>
                <p className="text-slate-300 leading-relaxed">{skill.description}</p>
              </div>

              <div>
                <h4 className="text-xs font-bold uppercase tracking-widest text-slate-500 mb-2">Technical Details</h4>
                <p className="text-slate-400 text-sm leading-relaxed">{skill.details}</p>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="p-4 rounded-xl bg-white/5 border border-white/5">
                  <div className="flex items-center gap-2 text-edge-blue mb-1">
                    <Cpu className="w-4 h-4" />
                    <span className="text-xs font-bold uppercase">Complexity</span>
                  </div>
                  <span className="text-sm font-medium">{skill.complexity}</span>
                </div>
                <div className="p-4 rounded-xl bg-white/5 border border-white/5">
                  <div className="flex items-center gap-2 text-edge-purple mb-1">
                    <Zap className="w-4 h-4" />
                    <span className="text-xs font-bold uppercase">Latency</span>
                  </div>
                  <span className="text-sm font-medium font-mono">{skill.latency}</span>
                </div>
              </div>

              <div className="p-4 rounded-xl bg-emerald-500/5 border border-emerald-500/10 flex gap-3">
                <Shield className="w-5 h-5 text-emerald-400 shrink-0" />
                <div>
                  <h5 className="text-xs font-bold text-emerald-400 uppercase mb-1">Edge Privacy</h5>
                  <p className="text-xs text-slate-400">This model runs entirely on your device. No data is transmitted to external servers for inference.</p>
                </div>
              </div>
            </div>
          </div>

          {/* Chat Side */}
          <div className="w-full md:w-1/2 flex flex-col bg-slate-900/50">
            <div className="p-4 border-b border-white/5 flex items-center gap-2">
              <MessageSquare className="w-4 h-4 text-edge-blue" />
              <span className="text-sm font-medium">Ask about this skill</span>
            </div>

            <div 
              ref={scrollRef}
              className="flex-1 overflow-y-auto p-6 space-y-4 min-h-[300px]"
            >
              {messages.length === 0 && (
                <div className="h-full flex flex-col items-center justify-center text-center p-6 opacity-40">
                  <MessageSquare className="w-12 h-12 mb-4" />
                  <p className="text-sm">Ask anything about how this model works or how to implement it.</p>
                </div>
              )}
              {messages.map((msg, i) => (
                <div key={i} className={cn(
                  "flex flex-col max-w-[85%]",
                  msg.role === 'user' ? "ml-auto items-end" : "mr-auto items-start"
                )}>
                  <div className={cn(
                    "p-3 rounded-2xl text-sm",
                    msg.role === 'user' 
                      ? "bg-edge-blue text-white rounded-tr-none" 
                      : "bg-white/10 text-slate-200 rounded-tl-none"
                  )}>
                    <div className="markdown-body prose prose-invert prose-sm max-w-none">
                      <ReactMarkdown>
                        {msg.content}
                      </ReactMarkdown>
                    </div>
                  </div>
                </div>
              ))}
              {isLoading && (
                <div className="flex items-center gap-2 text-slate-500 text-xs animate-pulse">
                  <Loader2 className="w-3 h-3 animate-spin" />
                  AI is thinking...
                </div>
              )}
            </div>

            <form onSubmit={handleAsk} className="p-4 border-t border-white/5 flex gap-2">
              <input
                type="text"
                value={prompt}
                onChange={(e) => setPrompt(e.target.value)}
                placeholder="Ask a question..."
                className="flex-1 bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-sm focus:outline-none focus:border-edge-blue/50 transition-colors"
              />
              <button 
                type="submit"
                disabled={isLoading || !prompt.trim()}
                className="p-2 rounded-xl bg-edge-blue text-white disabled:opacity-50 disabled:cursor-not-allowed hover:bg-edge-blue/80 transition-colors"
              >
                <Send className="w-5 h-5" />
              </button>
            </form>
          </div>
        </motion.div>
      </div>
    </AnimatePresence>
  );
}
