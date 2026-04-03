import { motion } from 'motion/react';
import { Cpu, Github, Menu } from 'lucide-react';

export default function Header() {
  return (
    <header className="fixed top-0 left-0 right-0 z-40 bg-slate-950/50 backdrop-blur-md border-b border-white/5">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg edge-gradient flex items-center justify-center">
              <Cpu className="w-5 h-5 text-white" />
            </div>
            <span className="text-xl font-display font-bold tracking-tight">
              AI Edge<span className="text-edge-blue">Gallery</span>
            </span>
          </div>

          <nav className="hidden md:flex items-center gap-8">
            <a href="#" className="text-sm font-medium text-slate-300 hover:text-white transition-colors">Showcase</a>
            <a href="#" className="text-sm font-medium text-slate-300 hover:text-white transition-colors">Benchmarks</a>
            <a href="#" className="text-sm font-medium text-slate-300 hover:text-white transition-colors">Docs</a>
          </nav>

          <div className="flex items-center gap-4">
            <a 
              href="https://github.com" 
              target="_blank" 
              rel="noopener noreferrer"
              className="p-2 rounded-full hover:bg-white/5 transition-colors"
            >
              <Github className="w-5 h-5 text-slate-400" />
            </a>
            <button className="md:hidden p-2 rounded-full hover:bg-white/5 transition-colors">
              <Menu className="w-5 h-5 text-slate-400" />
            </button>
            <button className="hidden md:block px-4 py-2 rounded-xl bg-white/5 border border-white/10 text-sm font-medium hover:bg-white/10 transition-colors">
              Get Started
            </button>
          </div>
        </div>
      </div>
    </header>
  );
}
