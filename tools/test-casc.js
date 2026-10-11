const { FS, MPQ } = require("@wowserhq/stormjs");

(async () => {
  const root = process.argv[2];
  try {
    FS.mkdir("/wow");
    FS.mount(FS.filesystems.NODEFS, { root }, "/wow");
    console.log("mounted:", root);
    const mpq = await MPQ.open("/wow", "r");
    console.log("MPQ.open OK");
    console.log("files:", mpq.getFileCount());
    console.log("hasFile(World of Warcraft Launcher.exe):", mpq.hasFile("World of Warcraft Launcher.exe"));
    mpq.close();
  } catch (e) {
    console.log("ERROR:", e && e.message ? e.message : String(e));
  }
})();