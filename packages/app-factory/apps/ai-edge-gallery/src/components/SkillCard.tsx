import { motion } from 'motion/react';
import * as Icons from 'lucide-react';
import { AISkill } from '../constants';
import { cn } from '../lib/utils';

interface SkillCardProps {
  skill: AISkill;
  onClick: () => void;
}

export default function SkillCard({ skill, onClick }: SkillCardProps) {
  // @ts-ignore - dynamic icon lookup
  const Icon = Icons[skill.icon] || Icons.Cpu;

  return (
    <motion.div
      whileHover={{ y: -5 }}
      whileTap={{ scale: 0.98 }}
      onClick={onClick}
      className="glass-panel p-6 cursor-pointer group transition-all hover:border-edge-blue/30 hover:bg-white/10"
    >
      <div className="flex justify-between items-start mb-4">
        <div className="p-3 rounded-xl bg-edge-blue/10 text-edge-blue group-hover:bg-edge-blue group-hover:text-white transition-colors">
          <Icon className="w-6 h-6" />
        </div>
        <span className={cn(
          "text-[10px] font-bold uppercase tracking-wider px-2 py-1 rounded-md",
          skill.complexity === 'High' ? "bg-red-500/10 text-red-400" : 
          skill.complexity === 'Medium' ? "bg-amber-500/10 text-amber-400" : 
          "bg-emerald-500/10 text-emerald-400"
        )}>
          {skill.complexity}
        </span>
      </div>
      
      <h3 className="text-xl font-display font-semibold mb-2 group-hover:text-edge-blue transition-colors">
        {skill.title}
      </h3>
      <p className="text-sm text-slate-400 line-clamp-2 mb-4">
        {skill.description}
      </p>
      
      <div className="flex items-center justify-between pt-4 border-t border-white/5">
        <span className="text-xs font-mono text-slate-500">{skill.category}</span>
        <div className="flex items-center gap-1 text-xs font-mono text-edge-blue">
          <Icons.Zap className="w-3 h-3" />
          {skill.latency}
        </div>
      </div>
    </motion.div>
  );
}
