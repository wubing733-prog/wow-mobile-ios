const fs=require("fs");
const b=fs.readFileSync(process.argv[2]);
let md=b;
if(b.toString("ascii",0,4)==="MD21"){const s=b.readUInt32LE(4);md=b.subarray(8,8+s);}
console.log("len",md.length,"ver",md.readUInt32LE(4));
// find (count,offset) where offset+count*48 <= len and count>0
for(let off=0x40; off<0x120; off+=4){
  const c=md.readUInt32LE(off), o=md.readUInt32LE(off+4);
  if(c>0 && c<100000 && o>0 && o<md.length && o+c*48<=md.length){
    console.log(`  candidate @0x${off.toString(16)}: count=${c} offset=${o} end=${o+c*48}`);
  }
}