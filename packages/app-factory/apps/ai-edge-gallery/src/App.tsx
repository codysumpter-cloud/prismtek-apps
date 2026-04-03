import { useState } from 'react';
import Header from './components/Header';
import Hero from './components/Hero';
import SkillCard from './components/SkillCard';
import SkillModal from './components/SkillModal';
import SkillBuilder from './components/SkillBuilder';
import Documentation from './components/Documentation';
import { AI_SKILLS, AISkill } from './constants';
import { motion, AnimatePresence } from 'motion/react';
import { Search, Filter, LayoutGrid, PenTool, BookOpen } from 'lucide-react';

type Tab = 'showcase' | 'builder' | 'docs';

export default function App() {
  const [activeTab, setActiveTab] = useState<Tab>('showcase');
  const [selectedSkill, setSelectedSkill] = useState<AISkill | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [activeCategory, setActiveCategory] = useState<string>('All');

  const categories = ['All', 'Vision', 'Language', 'Audio', 'Generative', 'Assistant'];

  const filteredSkills = AI_SKILLS.filter(skill => {
    const matchesSearch = skill.title.toLowerCase().includes(searchQuery.toLowerCase()) || 
                         skill.description.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = activeCategory === 'All' || skill.category === activeCategory;
    return matchesSearch && matchesCategory;
  });

  return (
    <div className="min-h-screen bg-slate-950">
      <Header />
      
      <main className="pt-16">
        {/* Tab Navigation */}
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-8">
          <div className="flex items-center justify-center gap-1 p-1 bg-white/5 border border-white/10 rounded-2xl w-fit mx-auto">
            <button
              onClick={() => setActiveTab('showcase')}
              className={`flex items-center gap-2 px-6 py-2.5 rounded-xl text-sm font-medium transition-all ${
                activeTab === 'showcase' ? "bg-edge-blue text-white shadow-lg shadow-edge-blue/20" : "text-slate-400 hover:text-white"
              }`}
            >
              <LayoutGrid className="w-4 h-4" />
              Showcase
            </button>
            <button
              onClick={() => setActiveTab('builder')}
              className={`flex items-center gap-2 px-6 py-2.5 rounded-xl text-sm font-medium transition-all ${
                activeTab === 'builder' ? "bg-edge-blue text-white shadow-lg shadow-edge-blue/20" : "text-slate-400 hover:text-white"
              }`}
            >
              <PenTool className="w-4 h-4" />
              Skill Builder
            </button>
            <button
              onClick={() => setActiveTab('docs')}
              className={`flex items-center gap-2 px-6 py-2.5 rounded-xl text-sm font-medium transition-all ${
                activeTab === 'docs' ? "bg-edge-blue text-white shadow-lg shadow-edge-blue/20" : "text-slate-400 hover:text-white"
              }`}
            >
              <BookOpen className="w-4 h-4" />
              Documentation
            </button>
          </div>
        </div>

        <AnimatePresence mode="wait">
          {activeTab === 'showcase' && (
            <motion.div
              key="showcase"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              transition={{ duration: 0.3 }}
            >
              <Hero />

              <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-24">
                {/* Controls */}
                <div className="flex flex-col md:flex-row gap-4 mb-12 items-center justify-between">
                  <div className="relative w-full md:w-96">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-500" />
                    <input
                      type="text"
                      placeholder="Search skills..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="w-full bg-white/5 border border-white/10 rounded-xl pl-10 pr-4 py-2.5 text-sm focus:outline-none focus:border-edge-blue/50 transition-colors"
                    />
                  </div>

                  <div className="flex items-center gap-2 overflow-x-auto w-full md:w-auto pb-2 md:pb-0">
                    {categories.map(cat => (
                      <button
                        key={cat}
                        onClick={() => setActiveCategory(cat)}
                        className={`px-4 py-2 rounded-xl text-xs font-bold uppercase tracking-wider transition-all whitespace-nowrap ${
                          activeCategory === cat 
                            ? "bg-edge-blue text-white" 
                            : "bg-white/5 text-slate-400 hover:bg-white/10"
                        }`}
                      >
                        {cat}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Grid */}
                {filteredSkills.length > 0 ? (
                  <motion.div 
                    layout
                    className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6"
                  >
                    {filteredSkills.map((skill) => (
                      <SkillCard 
                        key={skill.id} 
                        skill={skill} 
                        onClick={() => setSelectedSkill(skill)}
                      />
                    ))}
                  </motion.div>
                ) : (
                  <div className="text-center py-20">
                    <p className="text-slate-500">No skills found matching your criteria.</p>
                  </div>
                )}
              </section>
            </motion.div>
          )}

          {activeTab === 'builder' && (
            <motion.div
              key="builder"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              transition={{ duration: 0.3 }}
            >
              <SkillBuilder />
            </motion.div>
          )}

          {activeTab === 'docs' && (
            <motion.div
              key="docs"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              transition={{ duration: 0.3 }}
            >
              <Documentation />
            </motion.div>
          )}
        </AnimatePresence>
      </main>

      <footer className="border-t border-white/5 py-12 bg-slate-950">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <p className="text-sm text-slate-500">
            © 2026 AI Edge Gallery. Built for the future of decentralized intelligence.
          </p>
        </div>
      </footer>

      <SkillModal 
        skill={selectedSkill} 
        onClose={() => setSelectedSkill(null)} 
      />
    </div>
  );
}
