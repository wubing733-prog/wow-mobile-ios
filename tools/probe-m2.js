const fs=require("fs");
const b=fs.readFileSync(process.argv[2]);
console.log("magic:", b.toString("ascii",0,4));
console.log("version:", b.readUInt32LE(4));
console.log("first 64 bytes hex:", b.subarray(0,64).toString("hex"));
// MD20 header: name(64) then globalFlags(4) ... let's dump a few u32
for(let i=0;i<12;i++) console.log(`  u32[${i}] @${8+i*4} = ${b.readUInt32LE(8+i*4)}`);