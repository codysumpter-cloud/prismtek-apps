export const runtimeConfig = {
  useReferenceTestAssets:
    location.hostname === "localhost" &&
    new URLSearchParams(location.search).get("referenceAssets") === "true"
};

if (runtimeConfig.useReferenceTestAssets) {
  console.warn("Reference test assets enabled for local development only. Never use in release builds.");
}
