import { readFileSync } from "node:fs";

const PNG_SIGNATURE = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);

export function readPngInfo(filePath) {
  const buffer = readFileSync(filePath);
  if (buffer.length < 33 || !buffer.subarray(0, 8).equals(PNG_SIGNATURE)) {
    throw new Error(`${filePath} is not a PNG file`);
  }

  const ihdrLength = buffer.readUInt32BE(8);
  const ihdrType = buffer.subarray(12, 16).toString("ascii");
  if (ihdrLength !== 13 || ihdrType !== "IHDR") {
    throw new Error(`${filePath} has an invalid PNG IHDR chunk`);
  }

  const width = buffer.readUInt32BE(16);
  const height = buffer.readUInt32BE(20);
  const bitDepth = buffer.readUInt8(24);
  const colorType = buffer.readUInt8(25);
  const hasAlphaChannel = colorType === 4 || colorType === 6;
  const hasTransparencyChunk = buffer.includes(Buffer.from("tRNS"));

  return {
    width,
    height,
    bitDepth,
    colorType,
    hasAlpha: hasAlphaChannel || hasTransparencyChunk
  };
}
