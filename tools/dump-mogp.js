const fs=require("fs");
function rev(id){return id.split("").reverse().join("");}
function chunks(buf,off,lim){const out=[];let o=off;while(o+8<=lim){const raw=buf.toString("ascii",o,o+4);const id=rev(raw);const size=buf.readUInt32LE(o+4);if(size>lim-o-8)break;out.push({id,size,off:o+8});o+=8+size;}return out;}
const buf=fs.readFileSync(process.argv[2]);
const top=chunks(buf,0,buf.length);
console.log("top:",top.map(c=>c.id+"("+c.size+")").join(" "));
const mogp=top.find(c=>c.id==="MOGP");
if(mogp){
  console.log("MOGP off:",mogp.off,"size:",mogp.size);
  const inner=chunks(buf,mogp.off+0x44,mogp.off+mogp.size);
  console.log("inner(after 0x44):",inner.map(c=>c.id+"("+c.size+")").join(" "));
  const inner2=chunks(buf,mogp.off,mogp.off+mogp.size);
  console.log("inner(from 0):",inner2.map(c=>c.id+"("+c.size+")").join(" "));
}