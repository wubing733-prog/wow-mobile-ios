// BLP -> PNG batch converter
const fs=require("fs"), path=require("path");
const fmt=require("@wowserhq/format");
const { PNG }=require("pngjs");
const srcDir=process.argv[2], outDir=process.argv[3];
function walk(d,acc){for(const e of fs.readdirSync(d,{withFileTypes:true})){const p=path.join(d,e.name);if(e.isDirectory())walk(p,acc);else if(/\.blp$/i.test(e.name))acc.push(p);}return acc;}
const files=walk(srcDir,[]);
console.log("blp files:",files.length);
let ok=0,fail=0;
for(const f of files){
  try{
    const b=new fmt.Blp(); b.load(f);
    const img=b.getImage(0);
    const w=img.width,h=img.height,d=img.data;
    const png=new PNG({width:w,height:h});
    const n=w*h;
    for(let i=0;i<n;i++){
      const o=i*4;
      png.data[o]=d[o]; png.data[o+1]=d[o+1]; png.data[o+2]=d[o+2]; png.data[o+3]=d[o+3];
    }
    const rel=path.relative(srcDir,f).replace(/\.blp$/i,".png");
    const dst=path.join(outDir,rel);
    fs.mkdirSync(path.dirname(dst),{recursive:true});
    fs.writeFileSync(dst,PNG.sync.write(png));
    ok++;
  }catch(e){fail++;if(fail<=3)console.error("  FAIL",path.basename(f),e.message);}
}
console.log("converted",ok,"failed",fail);