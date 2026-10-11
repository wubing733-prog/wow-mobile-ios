const fs = require("fs"), path = require("path");
const io = require("@wowserhq/io");
const fmt = require("@wowserhq/format");
console.log("IoMode =", JSON.stringify(io.IoMode));
console.log("openStream type =", typeof io.openStream);
const p = process.argv[2];
console.log("path arg type:", typeof p, JSON.stringify(p));
try {
  const st = io.openStream(p);
  console.log("stream ok:", typeof st, "eof:", st.eof);
  const root = new fmt.MapObj();
  root.load(st);
  console.log("WMO version:", root.version, "groups:", root.groupInfo.length, "materials:", root.materials.length);
} catch (e) { console.error("ERR:", e.message); }