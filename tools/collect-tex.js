const fs=require("fs"),path=require("path");
function rev(id){return id.split("").reverse().join("");}
function chunks(buf,off,lim){const out=[];let o=off;while(o+8<=lim){const id=rev(buf.toString("ascii",o,o+4));const size=buf.readUInt32LE(o+4);if(size>lim-o-8)break;out.push({id,size,off:o+8,data:buf.subarray(o+8,o+8+size)});o+=8+size;}return out;}
const dir=process.argv[2];
const ids=new Set();
let files=0;
for(const f of fs.readdirSync(dir)){
  if(!/_tex0\.adt$/.test(f))continue;
  files++;
  const p=path.join(dir,f);
  const cs=chunks(fs.readFileSync(p),0,fs.statSync(p).size);
  const mdid=cs.find(c=>c.id==="MDID");
  if(mdid) for(let i=0;i+4<=mdid.size;i+=4) ids.add(mdid.data.readUInt32LE(i));
}
console.log("tex0 files:",files,"distinct tex ids:",ids.size);
fs.writeFileSync(path.join(__dirname,"shadowfang-tex-ids.json"),JSON.stringify([...ids]));
console.log([...ids].slice(0,30).join(","));