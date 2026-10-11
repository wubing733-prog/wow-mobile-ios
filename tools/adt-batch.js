// Batch: all shadowfang ADT root tiles -> OBJ with vertex normals.
const fs=require("fs"),path=require("path");
function rev(id){return id.split("").reverse().join("");}
function chunks(buf){const out=[];let o=0;while(o+8<=buf.length){const id=rev(buf.toString("ascii",o,o+4));const size=buf.readUInt32LE(o+4);if(size>buf.length-o-8)break;out.push({id,size,data:buf.subarray(o+8,o+8+size)});o+=8+size;}return out;}
function parseMcnk(d){const posX=d.readFloatLE(0x68),posY=d.readFloatLE(0x6C),posZ=d.readFloatLE(0x70);const cs=chunks(d.subarray(0x80));const mcvt=cs.find(c=>c.id==="MCVT");if(!mcvt)return null;const h=new Float32Array(145);for(let i=0;i<145;i++)h[i]=mcvt.data.readFloatLE(i*4);return{posX,posY,posZ,h};}
const dir=process.argv[2], out=process.argv[3];
const STEP=533.33333/128;
const V=[],N=[],F=[];
for(const f of fs.readdirSync(dir)){
  if(!/^shadowfang_\d+_\d+\.adt$/.test(f))continue;
  const cs=chunks(fs.readFileSync(path.join(dir,f)));
  for(const c of cs.filter(x=>x.id==="MCNK")){
    const m=parseMcnk(c.data); if(!m)continue;
    // build 17x17 height grid (outer rows 9 cols, inner rows 8 cols) -> normalize to 17x17
    const H=[];
    let k=0;
    for(let r=0;r<17;r++){const cols=(r%2===0)?9:8;const row=[];for(let cc=0;cc<cols;cc++)row.push(m.h[k++]);H.push(row);}
    const base=V.length;
    for(let r=0;r<17;r++){const cols=(r%2===0)?9:8;
      for(let cc=0;cc<cols;cc++){
        const gx=(r%2===0?cc*2:cc*2+1), gy=r;
        const x=m.posX+gx*STEP, y=m.posY+gy*STEP, z=m.posZ+H[r][cc];
        V.push([x,y,z]);
        const xl=Math.max(0,gx-1),xr=Math.min(16,gx+1),yd=Math.max(0,gy-1),yu=Math.min(16,gy+1);
        const hL=m.posZ+H[gy][Math.min(xl,H[gy].length-1)], hR=m.posZ+H[gy][Math.min(xr,H[gy].length-1)];
        const hD=m.posZ+H[yd][Math.min(cc,H[yd].length-1)], hU=m.posZ+H[yu][Math.min(cc,H[yu].length-1)];
        const nx=-(hR-hL)/(2*STEP), ny=-(hU-hD)/(2*STEP), nz=1;
        const len=Math.hypot(nx,ny,nz);
        N.push([nx/len,ny/len,nz/len]);
      }
    }
    const rowStart=[];let acc=base;
    for(let r=0;r<17;r++){rowStart.push(acc);acc+=(r%2===0)?9:8;}
    for(let r=0;r<16;r++){const a0=rowStart[r],a1=rowStart[r+1];const n0=(r%2===0)?9:8,n1=((r+1)%2===0)?9:8;const cells=Math.min(n0,n1)-1;
      for(let cc=0;cc<cells;cc++){const p00=a0+cc,p01=a0+cc+1,p10=a1+cc,p11=a1+cc+1;
        F.push([p00,p10,p01]);F.push([p01,p10,p11]);}}
  }
}
const lines=["# shadowfang terrain","o terrain"];
for(const v of V) lines.push("v "+v[0].toFixed(2)+" "+v[1].toFixed(2)+" "+v[2].toFixed(2));
for(const n of N) lines.push("vn "+n[0].toFixed(4)+" "+n[1].toFixed(4)+" "+n[2].toFixed(4));
for(const f of F) lines.push("f "+(f[0]+1)+"//"+(f[0]+1)+" "+(f[1]+1)+"//"+(f[1]+1)+" "+(f[2]+1)+"//"+(f[2]+1));
fs.writeFileSync(out,lines.join("\n"));
console.log("verts:",V.length,"faces:",F.length,"->",out);