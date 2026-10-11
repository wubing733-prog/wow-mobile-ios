const fs=require("fs"),path=require("path");
function rev(id){return id.split("").reverse().join("");}
function chunks(buf){const out=[];let o=0;while(o+8<=buf.length){const id=rev(buf.toString("ascii",o,o+4));const size=buf.readUInt32LE(o+4);if(size>buf.length-o-8)break;out.push({id,size,data:buf.subarray(o+8,o+8+size)});o+=8+size;}return out;}
const dir=process.argv[2];
const wmoIds=new Set(), m2Ids=new Set();
for(const f of fs.readdirSync(dir)){
  if(!/^shadowfang_.*_obj0\.adt$/.test(f))continue;
  const cs=chunks(fs.readFileSync(path.join(dir,f)));
  const modf=cs.find(c=>c.id==="MODF");
  if(modf) for(let i=0;i+64<=modf.size;i+=64) wmoIds.add(modf.data.readUInt32LE(i));
  const mddf=cs.find(c=>c.id==="MDDF");
  if(mddf) for(let i=0;i+36<=mddf.size;i+=36) m2Ids.add(mddf.data.readUInt32LE(i));
}
console.log("distinct WMO ids:", wmoIds.size, " distinct M2 ids:", m2Ids.size);
fs.writeFileSync(path.join(__dirname,"shadowfang-wmo-ids.json"), JSON.stringify([...wmoIds]));
fs.writeFileSync(path.join(__dirname,"shadowfang-m2-ids.json"), JSON.stringify([...m2Ids]));
console.log("wmo ids:", [...wmoIds].slice(0,20).join(","));