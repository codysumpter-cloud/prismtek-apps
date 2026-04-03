import { motion } from 'motion/react';
import { Book, Terminal, Cpu, Zap, Shield, Smartphone, Github, ExternalLink } from 'lucide-react';
import ReactMarkdown from 'react-markdown';

const DOCS_CONTENT = `
# Edge Skill Development Guide

Welcome to the AI Edge Gallery developer documentation. This guide will help you build, optimize, and deploy AI skills that run entirely on-device.

## 🚀 Quickstart: Omni-BMO on iPhone 15 Pro

The **Omni-BMO** project demonstrates how to run a high-performance LLM (Gemma-2B) locally on mobile hardware.

### 1. Prerequisites
- **Hardware:** iPhone 15 Pro / Pro Max (A17 Pro Chip)
- **Software:** iOS 17.4+
- **Tools:** Xcode 15, MLC LLM, Ollama (for local testing)

### 2. Model Selection
For the iPhone 15 Pro, we recommend **Gemma-2B-IT** quantized to 4-bit (q4f16_1). This provides the best balance of speed and intelligence.

### 3. Implementation Steps
\`\`\`bash
# Clone the Omni-BMO repository
git clone https://github.com/codysumpter-cloud/omni-bmo.git

# Install dependencies
cd omni-bmo
npm install

# Build for iOS using MLC LLM
python3 -m mlc_llm.build --model gemma-2b-it --target ios
\`\`\`

## 🛠️ Skill Architecture

Every edge skill consists of three core components:

### Triggers
Triggers define when your skill should activate.
- **Wake Word:** "Hey BMO", "Computer", etc.
- **Intent Matching:** Natural language processing to identify user goals.
- **Sensor Events:** Camera motion, location changes, or biometric data.

### Logic (The "Brain")
This is where the AI model processes input.
- **Local Inference:** Running models on the NPU/GPU.
- **Context Management:** Maintaining state across interactions.

### Responses
How the skill interacts back with the user.
- **TTS (Text-to-Speech):** Local voice synthesis.
- **UI Updates:** Real-time visual feedback.
- **Device Actions:** Controlling hardware (lights, volume, apps).

## 🔒 Privacy & Security
Edge skills are private by design. 
- **Zero Cloud:** No data leaves the device.
- **Sandboxed:** Skills run in isolated environments.
- **Permissions:** Users must explicitly grant access to camera/mic.

## 📈 Optimization Tips
1. **Quantization:** Always use 4-bit or 8-bit quantization for edge models.
2. **Batching:** Avoid batching for real-time interactions to minimize latency.
3. **NPU Acceleration:** Use CoreML (iOS) or NNAPI (Android) for maximum efficiency.
`;

export default function Documentation() {
  return (
    <div className="max-w-4xl mx-auto px-4 py-12">
      <div className="flex items-center gap-4 mb-12">
        <div className="p-4 rounded-2xl edge-gradient">
          <Book className="w-8 h-8 text-white" />
        </div>
        <div>
          <h2 className="text-4xl font-display font-bold">Documentation</h2>
          <p className="text-slate-400">Master the art of edge AI development.</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
        {/* Sidebar */}
        <div className="md:col-span-1 space-y-4">
          <div className="glass-panel p-4 sticky top-24">
            <h4 className="text-xs font-bold uppercase tracking-widest text-slate-500 mb-4">On this page</h4>
            <nav className="space-y-2">
              {['Quickstart', 'Architecture', 'Privacy', 'Optimization'].map(item => (
                <a key={item} href={`#${item.toLowerCase()}`} className="block text-sm text-slate-400 hover:text-edge-blue transition-colors">
                  {item}
                </a>
              ))}
            </nav>
            <div className="mt-8 pt-8 border-t border-white/5">
              <a 
                href="https://github.com/codysumpter-cloud/omni-bmo" 
                target="_blank"
                className="flex items-center gap-2 text-xs font-bold text-edge-blue hover:underline"
              >
                <Github className="w-4 h-4" />
                Omni-BMO Repo
                <ExternalLink className="w-3 h-3" />
              </a>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="md:col-span-3">
          <div className="glass-panel p-8 md:p-12 prose prose-invert prose-slate max-w-none">
            <ReactMarkdown>
              {DOCS_CONTENT}
            </ReactMarkdown>
          </div>
        </div>
      </div>
    </div>
  );
}
