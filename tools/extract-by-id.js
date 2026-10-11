// Extract by FileDataID using CASC name resolution (avoids stale listfile duplicate paths).
const fs=require("fs"),path=require("path");
const {Storage}=require("@jamiephan/casclib");
(async()=>{
  const ids=new Set(JSON.parse(fs.readFileSync(process.argv[2],"utf8")));
  const outDir=process.argv[3];
  fs.mkdirSync(outDir,{recursive:true});
  const s=await Storage.openAsync("Z:\\World of Warcraft");
  const lf=path.join(__dirname,"community-listfile.csv");
  const all=s.findFilesMatching(/\.(blp|wmo|m2|mdx|anim)$/i, lf);
  console.log("candidates:",all.length,"want ids:",ids.size);
  let ok=0,fail=0,miss=0;
  const done=new Set();
  for(const h of all){
    if(!ids.has(h.fileDataId)) continue;
    if(done.has(h.fileDataId)) continue;
    if(!s.fileExists(h.fileName)) continue;
    const dest=path.join(outDir,h.fileName.replace(/\\/g,"/"));
    fs.mkdirSync(path.dirname(dest),{recursive:true});
    try{ s.extractFile(h.fileName,dest); ok++; done.add(h.fileDataId); }
    catch(e){ fail++; if(fail<=3) console.error("  FAIL",h.fileName,e.message); }
  }
  for(const id of ids) if(!done.has(id)) miss++;
  console.log("extracted",ok,"failed",fail,"unresolved",miss);
  s.close();
})().catch(e=>{console.error("ERR",e.message);process.exit(1);});