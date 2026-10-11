const path = require("path");
const { Storage } = require("@jamiephan/casclib");
(async () => {
  const s = await Storage.openAsync("Z:\\World of Warcraft");
  const lf = path.join(__dirname, "community-listfile.csv");
  const hits = s.findFilesMatching(/dbfilesclient\\map\.db2$/i, lf);
  console.log("hits:", hits.length);
  console.log("sample:", JSON.stringify(hits[0], null, 2));
  s.close();
})().catch(e => console.error("ERR", e.message));