import type { ContentPack } from "./content";

export interface LocalAdapterManifest {
  id: string;
  name: string;
  version: string;
  mode: "local-only";
  allowedInputs: readonly string[];
}

export interface LocalAdapterSource {
  name: string;
  bytes: Uint8Array;
  userProvided: true;
}

export interface LocalAdapterResult {
  pack: ContentPack;
  warnings: string[];
}

export interface LocalContentAdapter {
  manifest: LocalAdapterManifest;
  validate(source: LocalAdapterSource): Promise<boolean>;
  convert(source: LocalAdapterSource): Promise<LocalAdapterResult>;
}

export class LocalAdapterRegistry {
  private adapters = new Map<string, LocalContentAdapter>();

  register(adapter: LocalContentAdapter) {
    if (adapter.manifest.mode !== "local-only") {
      throw new Error(`Adapter ${adapter.manifest.id} must be local-only.`);
    }
    this.adapters.set(adapter.manifest.id, adapter);
  }

  get(id: string) {
    return this.adapters.get(id);
  }

  list() {
    return [...this.adapters.values()];
  }
}

export const adapterSafetyRules = Object.freeze({
  noBundledThirdPartyFiles: true,
  noBundledThirdPartyAssets: true,
  noServerSideConversion: true,
  noAssetRedistribution: true,
  userProvidedInputOnly: true,
});
