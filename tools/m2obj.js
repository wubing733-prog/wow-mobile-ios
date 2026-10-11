// M2 -> OBJ: unwrap MD21, parse M2 via @wowserhq/format, parse .skin indices directly.
const fs=require("fs"), path=require("path");
const fmt=require("@wowserhq/format");

const m2Path=process.argv[2], skinPath=process.argv[3], outObj=process.argv[4];
const raw=fs.readFileSync(m2Path);
let payload=raw;
if(raw.toString("ascii",0,4)==="MD21"){ const size=raw.readUInt32LE(4); payload=raw.subarray(8,8+size); }
if(payload.toString("ascii",0,4)!=="MD20") throw new Error("not MD20");
const ab=payload.buffer.slice(payload.byteOffset, payload.byteOffset+payload.byteLength);
const model=new fmt.M2Model();
model.load(ab);
const vbuf=Buffer.from(model.vertices);
const nv=Math.floor(vbuf.length/48);

// skin: SKIN magic then arrays; vertices @0x04/0x08, indices @0x0C/0x10
const sb=fs.readFileSync(skinPath);
if(sb.toString("ascii",0,4)!=="SKIN") throw new Error("not SKIN");
const idxCount=sb.readUInt32LE(0x0C), idxOff=sb.readUInt32LE(0x10);
const lines=["# m2 "+path.basename(m2Path),"o m2"];
for(let i=0;i<nv;i++){const o=i*48; lines.push("v "+vbuf.readFloatLE(o).toFixed(3)+" "+vbuf.readFloatLE(o+4).toFixed(3)+" "+vbuf.readFloatLE(o+8).toFixed(3));}
for(let i=0;i<nv;i++){const o=i*48; lines.push("vt "+vbuf.readFloatLE(o+32).toFixed(5)+" "+vbuf.readFloatLE(o+36).toFixed(5));}
let nf=0;
for(let i=0;i+2<idxCount;i+=3){
  const o=idxOff+i*2;
  if(o+6>sb.length) break;
  const a=sb.readUInt16LE(o),b=sb.readUInt16LE(o+2),c=sb.readUInt16LE(o+4);
  if(a<nv&&b<nv&&c<nv){ lines.push("f "+(a+1)+"/"+(a+1)+" "+(b+1)+"/"+(b+1)+" "+(c+1)+"/"+(c+1)); nf++; }
}
fs.writeFileSync(outObj,lines.join("\n"));
console.log(path.basename(m2Path),"verts",nv,"tris",nf);