const fs=require("fs");
const b=fs.readFileSync(process.argv[2]);
console.log("len",b.length,"magic",b.toString("ascii",0,4));
for(let off=0; off<0x60; off+=4){
  console.log(`  @0x${off.toString(16)} = ${b.readUInt32LE(off)}`);
}
// find plausible uint16 index arrays
console.log("--- 候选 (count,offset) for uint16 arrays ---");
for(let off=0; off<0x60; off+=4){
  const c=b.readUInt32LE(off), o=b.readUInt32LE(off+4);
  if(c>0 && c<2000000 && o>0 && o+c*2<=b.length) console.log(`  @0x${off.toString(16)} count=${c} offset=${o}`);
}