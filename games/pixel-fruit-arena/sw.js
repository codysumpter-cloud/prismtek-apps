const CACHE_NAME = "pixel-fruit-arena-v2-playable";
const ASSETS = [
  "./",
  "./index.html",
  "./src/main.js",
  "./src/assets/assetManifest.js",
  "./src/fruits/fruits.js",
  "./src/stages/skyRuins.js",
  "./src/characters/characterCreator.js",
  "./src/systems/matchSystem.js",
  "./src/systems/runtimeConfig.js",
  "./src/combat/combatStyles.js",
  "./src/combat/combatSystem.js",
  "./src/multiplayer/input.js",
  "./src/ui/dom.js",
  "./src/ui/renderer.js",
  "./src/ui/styles.css",
  "./data/fruits/fruits.json",
  "./data/stages/sky_ruins.json",
  "./assets/characters/prismtek_placeholder.svg",
  "./assets/characters/prismtek_placeholder_character.json"
];

self.addEventListener("install", (event) => {
  event.waitUntil(caches.open(CACHE_NAME).then((cache) => cache.addAll(ASSETS)));
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(caches.keys().then((keys) => Promise.all(keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key)))));
  self.clients.claim();
});

self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") return;
  event.respondWith(
    fetch(event.request).then((response) => {
      if (response.ok) {
        const copy = response.clone();
        caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copy));
      }
      return response;
    }).catch(() => caches.match(event.request))
  );
});
