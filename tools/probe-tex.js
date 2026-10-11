const path=require("path");
const {Storage}=require("@jamiephan/casclib");
(async()=>{
  const s=await Storage.openAsync("Z:\\World of Warcraft");
  const lf=path.join(__dirname,"community-listfile.csv");
  // find any tileset blp that actually exists
  const hits=s.findFilesMatching(/^tileset[\\\/].*\.blp$/i, lf);
  console.log("tileset blp in listfile:", hits.length);
  let ex=0, exNames=[];
  for(const h of hits){ if(s.fileExists(h.fileName)){ ex++; if(exNames.length<8) exNames.push(h.fileName); } if(ex>=8) break; }
  console.log("first existing:", exNames.join("\n  "));
  // check by data id
  for(const id of [188802,186982,250464]){
    const h=hits.find(x=>x.fileDataId===id);
    console.log("id",id,"->",h?h.fileName:"(not in listfile)","exists:",h?s.fileExists(h.fileName):"-");
  }
  s.close();
})().catch(e=>{console.error("ERR",e.message);process.exit(1);});