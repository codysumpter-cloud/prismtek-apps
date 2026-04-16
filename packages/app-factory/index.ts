import { exec } from 'child_process';
import { promisify } from 'util';
import { AppTemplate, AppGenerationJob, AIModel } from '@prismtek/core';

const execAsync = promisify(exec);

export interface ScaffoldingOptions {
  description: string;
  templateId: string;
  target: string;
  env?: Record<string, string>;
  modelId?: string;
}

export class AppFactory {
  private templates: Map<string, AppTemplate> = new Map();
  private jobs: Map<string, AppGenerationJob> = new Map();
  private models: Map<string, AIModel> = new Map();

  constructor() {
    this.registerTemplate({
      id: 'bmo-stack-full',
      name: 'BMO Stack Full',
      description: 'Complete BMO Stack deployment with agent framework and local model support.',
      repoUrl: 'https://github.com/codysumpter-cloud/bmo-stack',
      version: '2.0.0',
      supportedModels: ['gemma4-e2b', 'gemma4-2b', 'gemma4-7b', 'gemma4-27b', 'nemotron3-120b', 'nemotron3-8b']
    });
    this.registerTemplate({
      id: 'prismtek-site-pro',
      name: 'Prismtek Site Pro',
      description: 'Advanced site template based on the Prismtek-site repository.',
      repoUrl: 'https://github.com/prismtek-dev/prismtek-site',
      version: '1.5.0',
      supportedModels: ['gemma4-7b', 'gemma4-27b']
    });
    this.registerTemplate({
      id: 'bmo-agent',
      name: 'BMO Agent',
      description: 'AI agent framework with wake-word support and character customization.',
      repoUrl: 'https://github.com/codysumpter-cloud/omni-bmo',
      version: '1.0.0'
    });
    this.registerTemplate({
      id: 'bemore-runtime-harness',
      name: 'BeMore Runtime Harness',
      description: 'High-performance runtime harness for BeMore-style agents.',
      repoUrl: 'https://github.com/ultraworkers/claw-code',
      version: '2.4.0'
    });

    // Register Models
    this.registerModel({
      id: 'gemma4-e2b',
      name: 'Gemma 4 E2B',
      provider: 'Google',
      parameters: '2B',
      description: 'Optimized for edge and browser-based inference.',
      isFree: true
    });
    this.registerModel({
      id: 'gemma4-2b',
      name: 'Gemma 4 2B',
      provider: 'Google',
      parameters: '2B',
      description: 'Lightweight model for mobile and edge devices.',
      isFree: true
    });
    this.registerModel({
      id: 'gemma4-7b',
      name: 'Gemma 4 7B',
      provider: 'Google',
      parameters: '7B',
      description: 'Balanced performance for general-purpose AI tasks.',
      isFree: true
    });
    this.registerModel({
      id: 'gemma4-27b',
      name: 'Gemma 4 27B',
      provider: 'Google',
      parameters: '27B',
      description: 'High-performance model for complex reasoning and coding.',
      isFree: true
    });
    this.registerModel({
      id: 'nemotron3-120b',
      name: 'Nemotron-3 120B Super Cloud',
      provider: 'NVIDIA',
      parameters: '120B',
      description: 'High-performance model for complex reasoning and cloud-scale apps.',
      isFree: true
    });
    this.registerModel({
      id: 'nemotron3-8b',
      name: 'Nemotron-3 8B',
      provider: 'NVIDIA',
      parameters: '8B',
      description: 'Efficient model for real-time applications and low-latency tasks.',
      isFree: true
    });
  }

  registerTemplate(template: AppTemplate) {
    this.templates.set(template.id, template);
  }

  registerModel(model: AIModel) {
    this.models.set(model.id, model);
  }

  getTemplates(): AppTemplate[] {
    return Array.from(this.templates.values());
  }

  getModels(): AIModel[] {
    return Array.from(this.models.values());
  }

  async generate(options: ScaffoldingOptions): Promise<AppGenerationJob> {
    const template = this.templates.get(options.templateId);
    if (!template) {
      throw new Error(`Template ${options.templateId} not found`);
    }

    const jobId = `job_${Math.random().toString(36).substring(2, 9)}`;
    const job: AppGenerationJob = {
      id: jobId,
      workspaceId: `ws_${Math.random().toString(36).substring(2, 9)}`,
      templateId: options.templateId,
      status: 'queued',
      progress: 0
    };

    this.jobs.set(jobId, job);
    this.processJob(jobId, options);

    return job;
  }

  private async processJob(jobId: string, options: ScaffoldingOptions) {
    const job = this.jobs.get(jobId);
    if (!job) return;

    try {
      job.status = 'processing';
      const template = this.templates.get(options.templateId);
      const targetDir = `generated/${job.workspaceId}`;

      console.log(`Processing real generation job ${jobId}...`);
      
      // Step 1: Clone repository
      job.progress = 10;
      await execAsync(`mkdir -p ${targetDir} && git clone ${template?.repoUrl} ${targetDir}`);
      
      // Step 2: Configure environment
      job.progress = 40;
      await execAsync(`cd ${targetDir} && echo "Generating ${options.description}..." > .generation_meta`);
      
      // Step 3: Run setup (simulation of nemoclaw onboard)
      job.progress = 70;
      await execAsync(`sleep 2`); 

      job.status = 'completed';
      job.progress = 100;
      console.log(`Job ${jobId} completed successfully. Workspace created at ${targetDir}`);
    } catch (error) {
      console.error(`Generation job ${jobId} failed: ${error}`);
      if (job) job.status = 'failed';
    }
  }

  async getJobStatus(jobId: string): Promise<AppGenerationJob | undefined> {
    return this.jobs.get(jobId);
  }
}
