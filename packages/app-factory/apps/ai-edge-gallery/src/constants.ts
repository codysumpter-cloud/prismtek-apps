export interface AISkill {
  id: string;
  title: string;
  description: string;
  icon: string;
  category: 'Vision' | 'Language' | 'Audio' | 'Generative' | 'Assistant';
  complexity: 'Low' | 'Medium' | 'High';
  latency: string;
  details: string;
  isTemplate?: boolean;
}

export const AI_SKILLS: AISkill[] = [
  {
    id: 'omni-bmo',
    title: 'Omni-BMO Assistant',
    description: 'A personalized, voice-activated edge assistant inspired by BMO. Optimized for iPhone 15 Pro.',
    icon: 'Bot',
    category: 'Assistant',
    complexity: 'High',
    latency: '< 50ms',
    details: 'Based on Gemma-2B-IT. Features wake-word detection, local STT/TTS, and personality-driven responses. Designed to run entirely on-device using Apple Neural Engine.',
    isTemplate: true
  },
  {
    id: 'object-detection',
    title: 'Real-time Object Detection',
    description: 'Identify and locate multiple objects in video streams with high precision and low latency.',
    icon: 'Scan',
    category: 'Vision',
    complexity: 'Medium',
    latency: '< 30ms',
    details: 'Utilizes optimized SSD-MobileNet architectures for edge deployment. Capable of detecting 80+ common object categories in real-time on mobile devices.'
  },
  {
    id: 'sentiment-analysis',
    title: 'On-Device Sentiment Analysis',
    description: 'Analyze text emotion and intent locally without sending data to the cloud.',
    icon: 'MessageSquareHeart',
    category: 'Language',
    complexity: 'Low',
    latency: '< 5ms',
    details: 'Powered by a quantized BERT-tiny model. Ideal for privacy-first applications like personal journals or local customer feedback processing.'
  },
  {
    id: 'image-generation',
    title: 'Edge Image Synthesis',
    description: 'Generate high-quality images from text prompts using optimized diffusion models.',
    icon: 'ImagePlus',
    category: 'Generative',
    complexity: 'High',
    latency: '2-5s',
    details: 'Leverages Stable Diffusion Turbo or similar distilled models. Optimized for NPU/GPU acceleration on edge hardware.'
  },
  {
    id: 'speech-to-text',
    title: 'Multilingual Transcription',
    description: 'Convert spoken language into text across 50+ languages with automatic punctuation.',
    icon: 'Mic',
    category: 'Audio',
    complexity: 'Medium',
    latency: '< 100ms',
    details: 'Based on OpenAI Whisper (base/small) or similar transformer-based speech models, optimized for low-power inference.'
  },
  {
    id: 'pose-estimation',
    title: 'Human Pose Tracking',
    description: 'Track 17+ keypoints of the human body for fitness, gaming, or gesture control.',
    icon: 'Accessibility',
    category: 'Vision',
    complexity: 'Medium',
    latency: '< 20ms',
    details: 'Uses MoveNet or BlazePose models. Highly robust to occlusion and varying lighting conditions.'
  },
  {
    id: 'text-summarization',
    title: 'Smart Summarization',
    description: 'Condense long documents into concise summaries while preserving key information.',
    icon: 'FileText',
    category: 'Language',
    complexity: 'Medium',
    latency: '< 500ms',
    details: 'Employs lightweight T5 or BART models fine-tuned for summarization tasks on mobile-class hardware.'
  }
];
