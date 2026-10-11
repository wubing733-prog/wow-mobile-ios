const fs=require("fs");
const b=fs.readFileSync(process.argv[2]);
let md=b;
if(b.toString("ascii",0,4)==="MD21"){const s=b.readUInt32LE(4);md=b.subarray(8,8+s);}
console.log("len",md.length,"ver",md.readUInt32LE(4));
for(let off=0x48; off<=0xA0; off+=4){
  console.log(`  @0x${off.toString(16)} = ${md.readUInt32LE(off)}`);
}
// search whole file for a plausible vertex array: count N, offset O, O+N*48<=len, N>10
console.log("--- 全文件搜 (count,offset) 满足 O+N*48<=len ---");
for(let off=0; off<0x200; off+=4){
  const c=md.readUInt32LE(off), o=md.readUInt32LE(off+4);
  if(c>10 && c<200000 && o>0 && o+c*48<=md.length) console.log(`  @0x${off.toString(16)} count=${c} offset=${o}`);
}