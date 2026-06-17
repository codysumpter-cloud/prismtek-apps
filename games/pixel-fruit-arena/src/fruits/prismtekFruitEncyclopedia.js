import r1 from "./encyclopediaRows1.js";
import r2 from "./encyclopediaRows2.js";
import r3 from "./encyclopediaRows3.js";
import r4 from "./encyclopediaRows4.js";
import r5 from "./encyclopediaRows5.js";
import r6 from "./encyclopediaRows6.js";
import r7 from "./encyclopediaRows7.js";
import r8 from "./encyclopediaRows8.js";
import r9 from "./encyclopediaRows9.js";
import r10 from "./encyclopediaRows10.js";
import r11 from "./encyclopediaRows11.js";
import r12 from "./encyclopediaRows12.js";
import r13 from "./encyclopediaRows13.js";
import r14 from "./encyclopediaRows14.js";
import r15 from "./encyclopediaRows15.js";
import r16 from "./encyclopediaRows16.js";

const ROWS = [r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16].join(";");
const COLORS={elemental:"#ff6b35",body:"#ff8fab",force:"#9be564",space:"#7c5cff",beast:"#f77f00",metal:"#adb5bd",control:"#7209b7",spirit:"#2ec4b6",summon:"#2ec4b6",utility:"#00b4d8",sound:"#4cc9f0",time:"#80ffdb",defense:"#5d7190",explosive:"#ef476f",terrain:"#52b788",vision:"#ffd166",fate:"#c8b6ff",age:"#ffafcc",targeting:"#fb8500",hazard:"#b5e48c","gravity-dark":"#7c5cff"};
const KINDS={elemental:["projectile","dash","uppercut"],body:["melee","jump","heavy"],force:["pull","slam","uppercut"],space:["blink","burst","field"],beast:["melee","dash","heavy"],metal:["projectile","field","slam"],control:["pull","field","burst"],spirit:["projectile","field","burst"],summon:["projectile","field","burst"],utility:["projectile","dash","field"],sound:["beam","field","burst"],time:["beam","field","slam"],defense:["field","melee","burst"],explosive:["projectile","dash","burst"],terrain:["dash","projectile","slam"],vision:["beam","field","burst"],fate:["projectile","field","burst"],age:["melee","field","heavy"],targeting:["projectile","dash","beam"],hazard:["field","projectile","burst"],"gravity-dark":["pull","field","burst"]};
const VFX_ID={projectile:"fireball",dash:"flame_dash",uppercut:"burning_uppercut",melee:"stretch_punch",jump:"bounce_jump",heavy:"giant_fist",pull:"pull",slam:"slam",blink:"blink_dash",burst:"shadow_burst",field:"freeze_field",beam:"lightning_bolt",chain:"chain_shock"};
const BONUS={starter:0,common:0,rare:2,legendary:4,mythic:5};
const MOVES=["Strike","Step","Break"];

export const PRISMTEK_FRUIT_ENCYCLOPEDIA=ROWS.split(";").filter(Boolean).map(r=>{const [id,baseName,rarity,fruitClass,powerKey]=r.split(",");const kinds=KINDS[fruitClass]||KINDS.utility;const b=BONUS[rarity]??0;return {id,name:`${baseName} Fruit`,rarity,class:fruitClass,powerKey,color:COLORS[fruitClass]||COLORS.utility,icon:baseName[0],awakening:`${baseName} Overdrive`,awakeningEffect:"Temporarily intensifies movement, hitboxes, and arena-control.",abilities:MOVES.map((m,i)=>{const kind=kinds[i%kinds.length];return {id:VFX_ID[kind]||"hit",name:`${baseName} ${m}`,kind,damage:8+i*3+b,knockback:310+i*120+b*20,cooldown:Number((0.52+i*.27+b*.025).toFixed(2)),speed:["projectile","beam","dash","blink"].includes(kind)?520+i*90:undefined,range:["melee","heavy"].includes(kind)?90+i*20:undefined,vfx:kind};})};});
export const PRISMTEK_ENCYCLOPEDIA_FRUITS=Object.fromEntries(PRISMTEK_FRUIT_ENCYCLOPEDIA.map(f=>[f.id,f]));
export const listPrismtekFruits=()=>PRISMTEK_FRUIT_ENCYCLOPEDIA;
export const prismtekFruitById=id=>PRISMTEK_ENCYCLOPEDIA_FRUITS[id]??null;
