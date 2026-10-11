const fs=require("fs");
const b=fs.readFileSync(process.argv[2]);
let md=b;
if(b.toString("ascii",0,4)==="MD21"){const s=b.readUInt32LE(4);md=b.subarray(8,8+s);}
console.log("MD20 len:",md.length,"version:",md.readUInt32LE(4));
for(let off=0x48; off<0x140; off+=8){
  const c=md.readUInt32LE(off), o=md.readUInt32LE(off+4);
  const ok = (o>0 && o<md.length && c>0 && c<1000000 && o+c*4<=md.length*2);
  console.log(`  @0x${off.toString(16)} count=${c} offset=${o} ${ok?"<-- plausible":""}`);
}