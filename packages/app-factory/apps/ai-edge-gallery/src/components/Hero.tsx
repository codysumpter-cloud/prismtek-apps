import { motion } from 'motion/react';
import { Cpu, Zap, Shield, Globe } from 'lucide-react';

export default function Hero() {
  return (
    <section className="relative pt-20 pb-16 overflow-hidden">
      {/* Background Glow */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-full max-w-4xl h-96 bg-edge-blue/20 blur-[120px] rounded-full -z-10" />
      
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
        >
          <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-edge-blue/10 text-edge-blue border border-edge-blue/20 mb-6">
            <Zap className="w-3 h-3 mr-1" />
            Next-Gen Edge Intelligence
          </span>
          <h1 className="text-5xl md:text-7xl font-display font-bold tracking-tight mb-6">
            Experience AI at the <br />
            <span className="text-gradient">Edge of Possibility</span>
          </h1>
          <p className="text-lg md:text-xl text-slate-400 max-w-2xl mx-auto mb-10 leading-relaxed">
            Explore a curated collection of high-performance AI models optimized for local execution. 
            Privacy-first, low-latency, and incredibly powerful.
          </p>
        </motion.div>

        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="grid grid-cols-2 md:grid-cols-4 gap-4 max-w-3xl mx-auto"
        >
          {[
            { icon: Shield, label: 'Privacy First' },
            { icon: Zap, label: 'Low Latency' },
            { icon: Globe, label: 'Offline Ready' },
            { icon: Cpu, label: 'NPU Optimized' },
          ].map((item, i) => (
            <div key={i} className="glass-panel p-4 flex flex-col items-center justify-center gap-2">
              <item.icon className="w-5 h-5 text-edge-blue" />
              <span className="text-xs font-medium text-slate-300">{item.label}</span>
            </div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}
