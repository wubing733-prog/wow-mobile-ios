const fs=require("fs"),path=require("path");
const {Storage}=require("@jamiephan/casclib");
(async()=>{
  const s=await Storage.openAsync("Z:\\World of Warcraft");
  const lf=path.join(__dirname,"community-listfile.csv");
  const tests=["world\\wmo\\azeroth\\buildings\\duskwood_barn\\duskwood_barn.wmo",
               "world/wmo/azeroth/buildings/duskwood_barn/duskwood_barn.wmo",
               "world\\wmo\\shadowfang\\shadowfang.wmo"];
  for(const t of tests){
    console.log("exists("+t+") =", s.fileExists(t), "| hasFile =", s.hasFile(t));
  }
  // find any wmo under shadowfang
  const hits=s.findFilesMatching(/shadowfang.*\.wmo$/i, lf);
  console.log("listfile wmo matching shadowfang:", hits.length);
  for(const h of hits.slice(0,10)) console.log("   ", h.fileName, "| exists:", s.fileExists(h.fileName));
  // find any wmo at all
  const all=s.findFilesMatching(/\.wmo$/i, lf);
  console.log("total wmo in listfile:", all.length);
  let ex=0; for(const h of all.slice(0,200)) if(s.fileExists(h.fileName)) ex++;
  console.log("of first 200, exists:", ex);
  s.close();
})().catch(e=>{console.error("ERR",e.message);process.exit(1);});