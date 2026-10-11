// CASC extraction helper — uses @jamiephan/casclib with the community listfile.
// usage: node extract-casc.js <regex> <outDir> [limit]
const path = require("path");
const fs = require("fs");
const { Storage } = require("@jamiephan/casclib");

const STORAGE = "Z:\\World of Warcraft";
const LISTFILE = path.join(__dirname, "community-listfile.csv");

(async () => {
  const pattern = process.argv[2];
  const outDir = process.argv[3];
  const limit = process.argv[4] ? parseInt(process.argv[4], 10) : 0;
  if (!pattern || !outDir) { console.error("usage: node extract-casc.js <regex> <outDir> [limit]"); process.exit(2); }
  fs.mkdirSync(outDir, { recursive: true });

  const s = await Storage.openAsync(STORAGE);
  console.log("storage:", JSON.stringify(s.getProductInfo()), "files:", s.getTotalFileCount());

  const hits = s.findFilesMatching(new RegExp(pattern, "i"), LISTFILE);
  console.log("matched:", hits.length);
  const targets = limit > 0 ? hits.slice(0, limit) : hits;

  let ok = 0, fail = 0;
  for (const h of targets) {
    const name = h.fileName;
    const dest = path.join(outDir, name.replace(/\\/g, "/"));
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    try { s.extractFile(name, dest); ok++; }
    catch (e) { fail++; if (fail <= 5) console.error("  FAIL", name, e.message); }
  }
  console.log("extracted:", ok, "failed:", fail);
  s.close();
})().catch(e => { console.error("ERROR:", e && e.message ? e.message : e); process.exit(1); });