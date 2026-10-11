// Minimal WoW ADT (split format, reversed FourCC) terrain -> OBJ converter.
const fs = require("fs");

function rev(id) { return id.split("").reverse().join(""); }
function readChunks(buf) {
  const out = []; let o = 0;
  while (o + 8 <= buf.length) {
    const raw = buf.toString("ascii", o, o + 4);
    const id = rev(raw);
    const size = buf.readUInt32LE(o + 4);
    if (size > buf.length - o - 8 || size < 0) break;
    out.push({ id, raw, data: buf.subarray(o + 8, o + 8 + size) });
    o += 8 + size;
  }
  return out;
}

function parseMcnk(d) {
  const idxX = d.readUInt32LE(0x04);
  const idxY = d.readUInt32LE(0x08);
  const posX = d.readFloatLE(0x68);
  const posY = d.readFloatLE(0x6C);
  const posZ = d.readFloatLE(0x70);
  const chunks = readChunks(d.subarray(0x80));
  const mcvt = chunks.find(c => c.id === "MCVT");
  if (!mcvt) return null;
  const heights = new Float32Array(145);
  for (let i = 0; i < 145; i++) heights[i] = mcvt.data.readFloatLE(i * 4);
  return { idxX, idxY, posX, posY, posZ, heights };
}

const buf = fs.readFileSync(process.argv[2]);
const outPath = process.argv[3];
const chunks = readChunks(buf);
const mcnks = chunks.filter(c => c.id === "MCNK").map(c => parseMcnk(c.data)).filter(Boolean);
console.log("MCNK chunks:", mcnks.length, "| top chunks:", chunks.slice(0,6).map(c=>c.id).join(","));
if (!mcnks.length) process.exit(1);

const STEP = 533.33333 / 128;
const lines = ["# wow adt terrain", "o terrain"];
let vcount = 0;
const faces = [];
for (const m of mcnks) {
  const base = vcount;
  // MCVT: 9x9 outer (every other) then 8x8 inner -> we emit a simple 9x9 grid from the 145 values
  // Layout: indices 0..8 row0 (9 outer), 9..16 row1 (8 inner), alternating
  const grid = [];
  let k = 0;
  for (let r = 0; r < 17; r++) {
    const cols = (r % 2 === 0) ? 9 : 8;
    for (let c = 0; c < cols; c++) {
      const x = m.posX + (r % 2 === 0 ? c * 2 : c * 2 + 1) * STEP;
      const y = m.posY + r * STEP;
      const z = m.posZ + m.heights[k++];
      lines.push("v " + x.toFixed(3) + " " + y.toFixed(3) + " " + z.toFixed(3));
      vcount++;
    }
  }
  // faces over the 16x16 cell grid using the emitted vertex rows
  const rowStart = [];
  let acc = base;
  for (let r = 0; r < 17; r++) { rowStart.push(acc); acc += (r % 2 === 0) ? 9 : 8; }
  for (let r = 0; r < 16; r++) {
    const a0 = rowStart[r], a1 = rowStart[r + 1];
    const n0 = (r % 2 === 0) ? 9 : 8, n1 = ((r + 1) % 2 === 0) ? 9 : 8;
    const cells = Math.min(n0, n1) - 1;
    for (let c = 0; c < cells; c++) {
      const p00 = a0 + c, p01 = a0 + c + 1, p10 = a1 + c, p11 = a1 + c + 1;
      faces.push([p00 + 1, p10 + 1, p01 + 1]);
      faces.push([p01 + 1, p10 + 1, p11 + 1]);
    }
  }
}
for (const f of faces) lines.push("f " + f[0] + " " + f[1] + " " + f[2]);
fs.writeFileSync(outPath, lines.join("\n"));
console.log("verts:", vcount, "faces:", faces.length, "->", outPath);