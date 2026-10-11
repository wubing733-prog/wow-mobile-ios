// Reorient WoW Z-up OBJ to Godot Y-up and center at origin (preserves vt/vn).
const fs=require("fs");
const src=process.argv[2], dst=process.argv[3];
const s=fs.readFileSync(src,"utf8").split("\n");
let mn=[1e18,1e18,1e18],mx=[-1e18,-1e18,-1e18];
const vs=[],vts=[],vns=[],ff=[];
for(const l of s){
  if(l.startsWith("v ")){const a=l.split(" ");const x=+a[1],y=+a[2],z=+a[3];if(!isFinite(x))continue;vs.push([x,y,z]);
    mn[0]=Math.min(mn[0],x);mn[1]=Math.min(mn[1],y);mn[2]=Math.min(mn[2],z);mx[0]=Math.max(mx[0],x);mx[1]=Math.max(mx[1],y);mx[2]=Math.max(mx[2],z);}
  else if(l.startsWith("vt ")) vts.push(l);
  else if(l.startsWith("vn ")){const a=l.split(" ");const x=+a[1],y=+a[2],z=+a[3];vns.push([x,z,-y]);}
  else if(l.startsWith("f ")) ff.push(l);
}
const cx=(mn[0]+mx[0])/2, cy=(mn[1]+mx[1])/2, cz=(mn[2]+mx[2])/2;
const out=["# reoriented z-up -> y-up, centered","o mesh"];
for(const [x,y,z] of vs) out.push("v "+((x-cx).toFixed(3))+" "+((z-cz).toFixed(3))+" "+((-(y-cy)).toFixed(3)));
for(const l of vts) out.push(l);
for(const n of vns) out.push("vn "+n[0].toFixed(4)+" "+n[1].toFixed(4)+" "+n[2].toFixed(4));
for(const l of ff) out.push(l);
fs.writeFileSync(dst,out.join("\n"));
console.log("wrote",dst,"verts",vs.length,"uvs",vts.length,"norms",vns.length,"faces",ff.length);