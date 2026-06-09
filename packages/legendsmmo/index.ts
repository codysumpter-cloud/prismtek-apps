export interface RomAdapterManifest {
  id: string;
  name: string;
  version: string;
}

export interface CreatureRecord {
  id: string;
  name: string;
}

export interface ItemRecord {
  id: string;
  name: string;
}

export interface MapRecord {
  id: string;
  name: string;
}

export interface RomAdapter {
  manifest: RomAdapterManifest;

  validate(source: Uint8Array): Promise<boolean>;

  listCreatures(): Promise<CreatureRecord[]>;
  listItems(): Promise<ItemRecord[]>;
  listMaps(): Promise<MapRecord[]>;
}

export class LocalAdapterRegistry {
  private adapters = new Map<string, RomAdapter>();

  register(adapter: RomAdapter) {
    this.adapters.set(adapter.manifest.id, adapter);
  }

  get(id: string) {
    return this.adapters.get(id);
  }

  list() {
    return [...this.adapters.values()];
  }
}
