const fs=require("fs"), path=require("path");
const fmt=require("@wowserhq/format");
const blp=process.argv[2];
try{
  const b=new fmt.Blp();
  b.load(blp);
  console.log("Blp loaded:", JSON.stringify({w:b.width,h:b.height,format:b.format,alphaBits:b.alphaBits,mipmaps:b.mipmaps}));
  const img=b.getImage(0);
  console.log("image:", img? JSON.stringify({w:img.width,h:img.height,format:img.format}) : "null");
}catch(e){ console.error("ERR:", e.message); }