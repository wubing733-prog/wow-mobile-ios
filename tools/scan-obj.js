const fs = require("fs"), path = require("path");
function rev(id){return id.split("").reverse().join("");}
function chunks(buf){const out=[];let o=0;while(o+8<=buf.length){const id=rev(buf.toString("ascii",o,o+4));const size=buf.readUInt32LE(o+4);if(size>buf.length-o-8)break;out.push({id,size,data:buf.subarray(o+8,o+8+size)});o+=8+size;}return out;}
const dir = process.argv[2];
let wmo=0, m2=0, tiles=0, nonEmpty=0;
for (const f of fs.readdirSync(dir)) {
  if (!/^shadowfang_\d+_\d+_obj0\.adt$/.test(f)) continue;
  tiles++;
  const cs = chunks(fs.readFileSync(path.join(dir,f)));
  const modf = cs.find(c=>c.id==="MODF");
  const mddf = cs.find(c=>c.id==="MDDF");
  const nw = modf ? Math.floor(modf.size/64) : 0;
  const nm = mddf ? Math.floor(mddf.size/36) : 0;
  if (nw||nm) { nonEmpty++; wmo+=nw; m2+=nm; if (nonEmpty<=10) console.log(`  ${f}: WMO=${nw} M2=${nm}`); }
}
console.log(`tiles=${tiles} nonEmpty=${nonEmpty} totalWMO=${wmo} totalM2=${m2}`);