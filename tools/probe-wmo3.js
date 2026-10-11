const fmt = require("@wowserhq/format");
const p = process.argv[2];
try {
  const root = new fmt.MapObj();
  root.load(p);
  console.log("OK version:", root.version, "groups:", root.groupInfo.length, "materials:", root.materials.length);
  for (const g of root.groupInfo.slice(0,5)) console.log("   group:", g.name, "flags:", g.flags);
} catch (e) { console.error("ERR:", e.message); }