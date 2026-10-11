const path = require("path");
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
  console.log("named map dirs:", named.length);
  for (const [d, e] of named.slice(0, 60)) console.log("  " + d.padEnd(30) + " files=" + String(e.n).padStart(5) + " size=" + (e.size/1048576).toFixed(1) + "MB");
  s.close();
})().catch(e => console.error("ERR", e.message));