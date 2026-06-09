import type { ContentPack } from "../content";
import { validateContentPack } from "../content";
import type { LocalAdapterResult, LocalAdapterSource, LocalContentAdapter } from "../localAdapter";

export class JsonContentPackAdapter implements LocalContentAdapter {
  manifest = {
    id: "json-content-pack",
    name: "JSON Content Pack",
    version: "0.1.0",
    mode: "local-only" as const,
    allowedInputs: ["application/json", ".json"],
  };

  async validate(source: LocalAdapterSource): Promise<boolean> {
    try {
      const pack = parseJsonPack(source.bytes);
      return validateContentPack(pack).length === 0;
    } catch {
      return false;
    }
  }

  async convert(source: LocalAdapterSource): Promise<LocalAdapterResult> {
    const pack = parseJsonPack(source.bytes);
    const errors = validateContentPack(pack);
    if (errors.length > 0) {
      throw new Error(`Invalid LegendsMMO content pack: ${errors.join("; ")}`);
    }
    return { pack, warnings: [] };
  }
}

function parseJsonPack(bytes: Uint8Array): ContentPack {
  const text = new TextDecoder().decode(bytes);
  return JSON.parse(text) as ContentPack;
}
