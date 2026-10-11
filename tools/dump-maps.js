const path = require("path");
const fs = require("fs");
const { Storage } = require("@jamiephan/casclib");
(async () => {
  const s = await Storage.openAsync("Z:\\World of Warcraft");
  const lf = path.join(__dirname, "community-listfile.csv");
  const hits = s.findFilesMatching(/^world[\\\/]maps[\\\/][^\\\/]+[\\\/][^\\\/]+\.(adt|wdt)$/i, lf);
  const dirs = new Map();
  for (const h of hits) {
    const m = h.fileName.replace(/\\/g, "/").match(/^world\/maps\/([^\/]+)\//i);
    if (!m) continue;
    const d = m[1].toLowerCase();
    if (!dirs.has(d)) dirs.set(d, { n: 0, size: 0 });
    const e = dirs.get(d); e.n++; e.size += h.fileSize || 0;
  }
  const named = [...dirs.entries()].filter(([d]) => !/^\d+$/.test(d)).sort((a,b) => b[1].size - a[1].size);
  const lines = named.map(([d,e]) => d + "," + e.n + "," + e.size);
  fs.writeFileSync(path.join(__dirname, "map-dirs.csv"), "dir,files,bytes\n" + lines.join("\n"));
  console.log("wrote map-dirs.csv:", named.length, "entries");
  s.close();
})().catch(e => console.error("ERR", e.message));