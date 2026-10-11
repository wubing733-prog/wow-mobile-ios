// Extract .skin files matching a set of M2 basenames.
const fs=require("fs"),path=require("path");
const {Storage}=require("@jamiephan/casclib");
(async()=>{
  const m2dir=process.argv[2], outDir=process.argv[3];
  const bases=new Set();
  for(const f of fs.readdirSync(m2dir,{recursive:true})){
    const n=String(f).toLowerCase();
    if(n.endsWith(".m2")) bases.add(path.basename(n,".m2"));
  }
  console.log("m2 basenames:",bases.size);
  const s=await Storage.openAsync("Z:\\World of Warcraft");
  const lf=path.join(__dirname,"community-listfile.csv");
  const hits=s.findFilesMatching(/\.skin$/i, lf);
  console.log("skin candidates:",hits.length);
  let ok=0;
  for(const h of hits){
    const bn=path.basename(h.fileName.toLowerCase(),".skin").replace(/\d\d$/,"");
    if(!bases.has(bn)) continue;
    const dest=path.join(outDir,h.fileName.replace(/\\/g,"/"));
    fs.mkdirSync(path.dirname(dest),{recursive:true});
    try{ s.extractFile(h.fileName,dest); ok++; }catch(e){}
  }
  console.log("extracted skins:",ok);
  s.close();
})().catch(e=>{console.error("ERR",e.message);process.exit(1);});