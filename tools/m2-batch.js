// Batch M2 -> OBJ for all models that have a matching skin.
const fs=require("fs"), path=require("path");
const {execFileSync}=require("child_process");
const m2dir=process.argv[2], skindir=process.argv[3], outdir=process.argv[4];
fs.mkdirSync(outdir,{recursive:true});
const skins=new Map();
for(const f of fs.readdirSync(skindir,{recursive:true})){
  const n=String(f).toLowerCase();
  if(!n.endsWith(".skin"))continue;
  const b=path.basename(n,".skin").replace(/\d\d$/,"");
  if(!skins.has(b)) skins.set(b, path.join(skindir,String(f)));
}
let ok=0,fail=0;
for(const f of fs.readdirSync(m2dir,{recursive:true})){
  const n=String(f).toLowerCase();
  if(!n.endsWith(".m2"))continue;
  const b=path.basename(n,".m2");
  const sk=skins.get(b);
  if(!sk) continue;
  const out=path.join(outdir, b+".obj");
  try{
    execFileSync(process.execPath,[path.join(__dirname,"m2obj.js"), path.join(m2dir,String(f)), sk, out],{stdio:"pipe"});
    ok++;
  }catch(e){ fail++; }
}
console.log("converted",ok,"failed",fail,"->",outdir);