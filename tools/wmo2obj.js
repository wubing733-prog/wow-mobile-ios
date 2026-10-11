// WMO -> OBJ with UVs (MOGP header 0x44; subchunks follow)
const fs = require("fs"), path = require("path");
function rev(id){return id.split("").reverse().join("");}
function chunks(buf, off, lim){const out=[];let o=off;while(o+8<=lim){const raw=buf.toString("ascii",o,o+4);const id=rev(raw);const size=buf.readUInt32LE(o+4);if(size>lim-o-8)break;out.push({id,size,off:o+8,data:buf.subarray(o+8,o+8+size)});o+=8+size;}return out;}
function groupMesh(buf){
  const top=chunks(buf,0,buf.length);
  const mogp=top.find(c=>c.id==="MOGP");
  if(!mogp) return null;
  const inner=chunks(buf,mogp.off+0x44,mogp.off+mogp.size);
  return {movt:inner.find(c=>c.id==="MOVT"),movi:inner.find(c=>c.id==="MOVI"),motv:inner.find(c=>c.id==="MOTV")};
}
const rootWmo=process.argv[2], outObj=process.argv[3];
const dir=path.dirname(rootWmo), base=path.basename(rootWmo,".wmo");
const rootChunks=chunks(fs.readFileSync(rootWma=rootWmo),0,fs.statSync(rootWmo).size);
const mogi=rootChunks.find(c=>c.id==="MOGI");
const groupCount=mogi?Math.floor(mogi.size/32):0;
const lines=["# wmo "+base,"o "+base];
let vbase=0,nv=0,nf=0;
for(let gi=0;gi<groupCount;gi++){
  const gp=path.join(dir,base+"_"+String(gi).padStart(3,"0")+".wmo");
  if(!fs.existsSync(gp))continue;
  const m=groupMesh(fs.readFileSync(gp));
  if(!m||!m.movt||!m.movi)continue;
  const vc=Math.floor(m.movt.size/12);
  for(let i=0;i<vc;i++) lines.push("v "+m.movt.data.readFloatLE(i*12).toFixed(3)+" "+m.movt.data.readFloatLE(i*12+4).toFixed(3)+" "+m.movt.data.readFloatLE(i*12+8).toFixed(3));
  if(m.motv){const uc=Math.floor(m.motv.size/8);for(let i=0;i<uc;i++) lines.push("vt "+m.motv.data.readFloatLE(i*8).toFixed(5)+" "+m.motv.data.readFloatLE(i*8+4).toFixed(5));}
  const hasUV=!!m.motv;
  const ic=Math.floor(m.movi.size/2);
  for(let i=0;i+2<ic;i+=3){
    const a=vbase+m.movi.data.readUInt16LE(i*2)+1,b=vbase+m.movi.data.readUInt16LE((i+1)*2)+1,c=vbase+m.movi.data.readUInt16LE((i+2)*2)+1;
    lines.push(hasUV?("f "+a+"/"+a+" "+b+"/"+b+" "+c+"/"+c):("f "+a+" "+b+" "+c));
  }
  vbase+=vc;nv+=vc;nf+=Math.floor(ic/3);
}
fs.writeFileSync(outObj,lines.join("\n"));
console.log("verts:",nv,"faces:",nf,"->",outObj);