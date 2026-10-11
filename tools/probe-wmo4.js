const fmt = require("@wowserhq/format");
const p = process.argv[2];
try {
  const root = new fmt.MapObj();
  root.load(p);
  console.log("OK", root.version);
} catch (e) { console.error("ERR:", e.message); console.error(e.stack); }