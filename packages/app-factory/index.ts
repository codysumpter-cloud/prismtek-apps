import { AppTemplate, AppGenerationJob } from '@prismtek/core';

export interface ScaffoldingOptions {
  description: string;
  templateId: string;
  target: string;
  env?: Record<string, string>;
}

export class AppFactory {
  private templates: Map<string, AppTemplate> = new Map();
  private jobs: Map<string, AppGenerationJob> = new Map();

  constructor() {
    this.registerTemplate({
      id: 'bmo-agent',
      name: 'BMO Agent',
      description: 'AI agent framework with wake-word support and character customization.',
      repoUrl: 'https://github.com/codysumpter-cloud/omni-bmo',
      version: '1.0.0'
    });
    this.registerTemplate({
      id: 'openclaw-harness',
      name: 'OpenClaw Harness',
      description: 'High-performance harness for Claude-style agents.',
      repoUrl: 'https://github.com/ultraworkers/claw-code',
      version: '2.4.0'
    });
    this.registerTemplate({
      id: 'omni-openclaw',
      name: 'Omni-OpenClaw Starter',
      description: 'Clean, brand-neutral starter for OpenClaw with local Omni models.',
      repoUrl: 'https://github.com/codysumpter-cloud/omni-openclaw-starter',
      version: '1.2.0'
    });
  }

  registerTemplate(template: AppTemplate) {
    this.templates.set(template.id, template);
  }

  getTemplates(): AppTemplate[] {
    return Array.from(this.templates.values());
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
      status: 'queued',
      progress: 0
    };

    this.jobs.set(jobId, job);

    // Simulate the scaffolding process in the background
    this.processJob(jobId, options);

    return job;
  }

  private async processJob(jobId: string, options: ScaffoldingOptions) {
    const job = this.jobs.get(jobId);
    if (!job) return;

    console.log(`Processing job ${jobId} for template ${options.templateId}`);
    job.status = 'processing';

    // Simulate scaffolding steps
    const steps = [
      'Cloning repository...',
      'Injecting environment variables...',
      'Configuring agent identity...',
      'Setting up storage hygiene...',
      'Building application...',
      'Finalizing workspace...'
    ];

    for (let i = 0; i < steps.length; i++) {
      await new Promise(resolve => setTimeout(resolve, 1000));
      job.progress = Math.round(((i + 1) / steps.length) * 100);
      console.log(`Job ${jobId}: ${steps[i]} (${job.progress}%)`);
    }

    job.status = 'completed';
    console.log(`Job ${jobId} completed successfully`);
  }

  async getJobStatus(jobId: string): Promise<AppGenerationJob | undefined> {
    return this.jobs.get(jobId);
  }
}
