const fs=require("fs");
for(const p of process.argv.slice(2)){
  const s=fs.readFileSync(p,"utf8").split("\n");
  let mn=[1e18,1e18,1e18],mx=[-1e18,-1e18,-1e18],n=0;
  for(const l of s){ if(l[0]!=="v"||l[1]!==" ")continue; const a=l.split(" "); const x=+a[1],y=+a[2],z=+a[3];
    if(!isFinite(x))continue; n++;
    mn[0]=Math.min(mn[0],x);mn[1]=Math.min(mn[1],y);mn[2]=Math.min(mn[2],z);
    mx[0]=Math.max(mx[0],x);mx[1]=Math.max(mx[1],y);mx[2]=Math.max(mx[2],z);}
  console.log(p.split("\\").pop(), "verts="+n, "min="+mn.map(v=>v.toFixed(1)).join(","), "max="+mx.map(v=>v.toFixed(1)).join(","));
}