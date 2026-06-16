#!/usr/bin/env node
import { stdin, stdout } from 'node:process';
import {
  CANONICAL_ANIMATION_SLOTS,
  buildAnimationManifest,
  buildGenerationPrompt,
  buildProviderJob,
  sliceSpriteSheetGrid,
  validateAnimationManifest,
  validateSpriteSheetGrid
} from '../../../packages/pixel-asset-pipeline/src/index.mjs';

const TOOLS = [
  {
    name: 'validate_pixel_asset',
    description: 'Validate a pixel-art sprite sheet grid and Prismtek runtime frame constraints.',
    inputSchema: {
      type: 'object',
      additionalProperties: false,
      properties: {
        imageWidth: { type: 'integer', minimum: 1 },
        imageHeight: { type: 'integer', minimum: 1 },
        frameWidth: { type: 'integer', default: 64 },
        frameHeight: { type: 'integer', default: 64 },
        margin: { type: 'integer', default: 0 },
        spacing: { type: 'integer', default: 0 }
      },
      required: ['imageWidth', 'imageHeight']
    }
  },
  {
    name: 'slice_sprite_sheet',
    description: 'Return frame rectangles for a sprite sheet without touching binary image bytes.',
    inputSchema: {
      type: 'object',
      additionalProperties: false,
      properties: {
        imageWidth: { type: 'integer', minimum: 1 },
        imageHeight: { type: 'integer', minimum: 1 },
        frameWidth: { type: 'integer', default: 64 },
        frameHeight: { type: 'integer', default: 64 },
        margin: { type: 'integer', default: 0 },
        spacing: { type: 'integer', default: 0 }
      },
      required: ['imageWidth', 'imageHeight']
    }
  },
  {
    name: 'build_animation_manifest',
    description: 'Build a Prismtek pixel asset manifest from sprite sheet dimensions, animation frame indexes, and provenance.',
    inputSchema: {
      type: 'object',
      additionalProperties: true,
      properties: {
        variantId: { type: 'string' },
        displayName: { type: 'string' },
        sheetPath: { type: 'string' },
        imageWidth: { type: 'integer' },
        imageHeight: { type: 'integer' },
        frameWidth: { type: 'integer', default: 64 },
        frameHeight: { type: 'integer', default: 64 },
        animations: { type: 'array' },
        provenance: { type: 'object' }
      },
      required: ['imageWidth', 'imageHeight']
    }
  },
  {
    name: 'validate_animation_manifest',
    description: 'Validate the lightweight Prismtek pixel asset manifest shape.',
    inputSchema: {
      type: 'object',
      additionalProperties: true,
      properties: { manifest: { type: 'object' } },
      required: ['manifest']
    }
  },
  {
    name: 'build_generation_prompt',
    description: 'Create a safe provider prompt for original Prismtek pixel-art sprite sheets.',
    inputSchema: {
      type: 'object',
      additionalProperties: false,
      properties: {
        subject: { type: 'string' },
        style: { type: 'string' },
        palette: { type: 'string' },
        frameWidth: { type: 'integer', default: 64 },
        frameHeight: { type: 'integer', default: 64 },
        animationSlots: { type: 'array', items: { type: 'string' } },
        referenceNotes: { type: 'string' }
      }
    }
  },
  {
    name: 'build_provider_job',
    description: 'Create a provider-neutral generation job for Pixellab/OpenAI/local/manual backends without storing secrets.',
    inputSchema: {
      type: 'object',
      additionalProperties: true,
      properties: {
        provider: { type: 'string' },
        subject: { type: 'string' },
        mode: { type: 'string' },
        frameWidth: { type: 'integer', default: 64 },
        frameHeight: { type: 'integer', default: 64 }
      }
    }
  },
  {
    name: 'list_animation_slots',
    description: 'List the canonical Prismtek/Buddy animation slot IDs.',
    inputSchema: { type: 'object', additionalProperties: false, properties: {} }
  }
];

const handlers = {
  initialize: () => ({
    protocolVersion: '2024-11-05',
    serverInfo: { name: 'prismtek-pixel-forge-mcp', version: '0.1.0' },
    capabilities: { tools: {} }
  }),
  'tools/list': () => ({ tools: TOOLS }),
  'tools/call': ({ name, arguments: args = {} } = {}) => callTool(name, args)
};

function callTool(name, args) {
  switch (name) {
    case 'validate_pixel_asset':
      return textResult(validateSpriteSheetGrid(args));
    case 'slice_sprite_sheet':
      return textResult(sliceSpriteSheetGrid(args));
    case 'build_animation_manifest':
      return textResult(buildAnimationManifest(args));
    case 'validate_animation_manifest':
      return textResult(validateAnimationManifest(args.manifest));
    case 'build_generation_prompt':
      return textResult({ prompt: buildGenerationPrompt(args) });
    case 'build_provider_job':
      return textResult(buildProviderJob(args));
    case 'list_animation_slots':
      return textResult({ slots: CANONICAL_ANIMATION_SLOTS });
    default:
      throw new Error(`Unknown tool: ${name}`);
  }
}

function textResult(value) {
  return { content: [{ type: 'text', text: JSON.stringify(value, null, 2) }] };
}

let buffer = '';
stdin.setEncoding('utf8');
stdin.on('data', (chunk) => {
  buffer += chunk;
  let newlineIndex;
  while ((newlineIndex = buffer.indexOf('\n')) >= 0) {
    const line = buffer.slice(0, newlineIndex).trim();
    buffer = buffer.slice(newlineIndex + 1);
    if (line) handleLine(line);
  }
});

function handleLine(line) {
  let request;
  try {
    request = JSON.parse(line);
    const handler = handlers[request.method];
    if (!handler) throw new Error(`Unsupported method: ${request.method}`);
    const result = handler(request.params ?? {});
    write({ jsonrpc: '2.0', id: request.id, result });
  } catch (error) {
    write({
      jsonrpc: '2.0',
      id: request?.id ?? null,
      error: { code: -32000, message: error instanceof Error ? error.message : String(error) }
    });
  }
}

function write(payload) {
  stdout.write(`${JSON.stringify(payload)}\n`);
}
