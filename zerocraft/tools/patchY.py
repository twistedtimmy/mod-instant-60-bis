import sys, struct; sys.path.insert(0,'.')
from mpq import MPQ, write_mpq
D = '/sessions/rcw-01nx1lyqyzzumfoxddiqwcrx/mnt/ChromieCraft_3.3.5a/Data/'
ORDER=['enUS/patch-enUS-3.MPQ','patch-3.MPQ','enUS/patch-enUS-2.MPQ','patch-2.MPQ','enUS/patch-enUS.MPQ','patch.MPQ','enUS/lichking-locale-enUS.MPQ','lichking.MPQ','enUS/expansion-locale-enUS.MPQ','expansion.MPQ','enUS/locale-enUS.MPQ','common-2.MPQ','common.MPQ']
def get(name):
    for o in ORDER:
        try: d=MPQ(D+o).read(name)
        except Exception as e: d=None
        if d: print(name,'from',o); return bytearray(d)
    raise SystemExit('not found '+name)
allids=[int(x) for x in open('free_ids.txt').read().strip().split(',')]
scrolls=allids[:80]
books=allids[80:]
# ItemDisplayInfo.dbc: new displays = an existing model with a new icon
#   68800 Frostmourne (Frozen Rune Weapon icon), 68801 Doomhammer (Thrall's own model 65921)
FM_DISPLAY=68800
DH_DISPLAY=68801
NEWDISP=[(FM_DISPLAY,46609,b'Spell_DeathKnight_FrozenRuneWeapon'),(DH_DISPLAY,65921,b'INV_Hammer_09')]
di=get('DBFilesClient\\ItemDisplayInfo.dbc')
_,dn,dnf,drs,dss=struct.unpack_from('<4sIIII',di,0)
rows={struct.unpack_from('<I',di,20+i*drs)[0]:bytearray(di[20+i*drs:20+(i+1)*drs]) for i in range(dn)}
dstr=bytearray(di[20+dn*drs:])
add=b''
for nid,src,icon in NEWDISP:
    r=bytearray(rows[src]); off=len(dstr); dstr+=icon+b'\0'
    struct.pack_into('<I',r,0,nid); struct.pack_into('<I',r,5*4,off); add+=bytes(r)
di=bytearray(di[:20+dn*drs])+add+dstr
struct.pack_into('<II',di,4,dn+len(NEWDISP),dnf); struct.pack_into('<I',di,16,len(dstr))
print('new displays',[d[0] for d in NEWDISP])
# Item.dbc
it=get('DBFilesClient\\Item.dbc')
_,n,nf,rs,ss=struct.unpack_from('<4sIIII',it,0)
done=0
for i in range(n):
    o=20+i*rs; r=list(struct.unpack_from('<%dI'%nf,it,o))
    if r[0] in scrolls: r[5]=4775; done+=1
    elif r[0] in books: r[5]=918; done+=1
    elif r[0]==36942: r[3],r[4],r[5]=0xFFFFFFFF,1,FM_DISPLAY; done+=1
    elif r[0]==14156: r[1],r[2],r[5],r[6]=1,0,22485,18; done+=1
    else: continue
    struct.pack_into('<%dI'%nf,it,o,*r)
print('item rows patched',done)
# brand-new item slots for NPC Books (60001-60400): appended as extra Item.dbc rows
NEWBOOKS=list(range(60001,60401))
have={struct.unpack_from('<I',it,20+i*rs)[0] for i in range(n)}
extra=b''.join(struct.pack('<%dI'%nf,b,15,0,0xFFFFFFFF,1,918,0,0) for b in NEWBOOKS if b not in have)
extra+=b''.join(struct.pack('<%dI'%nf,b,15,0,0xFFFFFFFF,1,d,0,0) for b,d in ((60401,20195),(60402,19238),(60403,8572),(60404,20254),(60405,1644),(60406,26595),(60407,13435),(60408,7913),(60409,20621),(60410,7840),(60419,13435)) if b not in have)
extra+=b''.join(struct.pack('<%dI'%nf,b,2,4,0xFFFFFFFF,1,DH_DISPLAY,21,3) for b in (60411,) if b not in have)   # Doomhammer: 1H main-hand mace
extra+=b''.join(struct.pack('<%dI'%nf,b,15,0,0xFFFFFFFF,1,918,0,0) for b in range(64000,66000) if b not in have)   # NPC: <name> items
# ZeroCraft legendaries from NPC-only weapon models: (id, class, subclass, material, display, invtype, sheath)
LEGENDS=[(60412,2,6,1,37410,17,2),(60413,4,6,1,48907,14,4),(60414,2,5,2,37525,17,1),(60415,2,1,1,46963,17,1),
         (60416,2,6,1,45598,17,2),(60417,2,6,1,46753,17,2),(60418,2,7,1,4290,13,3)]
extra+=b''.join(struct.pack('<%dI'%nf,b,c,s,0xFFFFFFFF,m,dp,inv,sh) for b,c,s,m,dp,inv,sh in LEGENDS if b not in have)
extra+=b''.join(struct.pack('<%dI'%nf,b,15,0,0xFFFFFFFF,1,(20219 if b<61020 else 7913),0,0) for b in range(61000,63500) if b not in have)
cnt=len(extra)//rs
it=bytearray(it[:20+n*rs]+extra+it[20+n*rs:])
struct.pack_into('<I',it,4,n+cnt)
print('new item rows',cnt)
# Spell.dbc: new tooltip for spell 42362 (used by all Builder's Scrolls)
sp=get('DBFilesClient\\Spell.dbc')
_,n,nf,rs,ss=struct.unpack_from('<4sIIII',sp,0)
strs=20+n*rs
texts={42362:b'Unroll the scroll and mark a spot on the ground. Choose what to build from the list, or clear away something you built nearby.\0',
       22275:b'Pick a spot on the ground and it is built there.\0',
       16872:b'Lists everything your guild built nearby. Click one to destroy it.\0',
       37435:b'Read the scroll to learn a forbidden technique. The scroll crumbles once learned.\0',
       67285:b'Place it right in front of you. Click it afterwards to move, turn, resize or pick it up.\0',
       24612:b'Moves whatever you chose with "Place it" to the spot you click. Works on furniture and on your NPCs, and sets the second point of a patrol.\0',
       35070:b'Click a spot on the ground and your troops march there.\0',
       21342:b'Unroll the scroll and build right in front of you. Choose what to build from the list, or clear away something you built nearby.\0'}
offs={}
for sid,t in texts.items():
    offs[sid]=ss+len(sp)-(20+n*rs+ss); sp+=t
for i in range(n):
    o=20+i*rs
    sid=struct.unpack_from('<I',sp,o)[0]
    if sid in offs:
        struct.pack_into('<I',sp,o+170*4,offs[sid]); print('spell patched',sid)
struct.pack_into('<I',sp,16,len(sp)-(20+n*rs))
# professions leave the spellbook (Profession Master NPCs open them instead). Client-only "hidden" flag;
# the skills and recipes are untouched. Actions you cast on things stay: Fishing, Disenchant, Prospecting, Milling, Wormholes.
sla=get('DBFilesClient\\SkillLineAbility.dbc')
_,ln,lnf,lrs,lss=struct.unpack_from('<4sIIII',sla,0)
PROF={164,165,171,182,185,186,197,202,333,356,393,755,773,129}
profsp={struct.unpack_from('<I',sla,20+i*lrs+8)[0] for i in range(ln) if struct.unpack_from('<I',sla,20+i*lrs+4)[0] in PROF}
KEEP=('Fishing','Disenchant','Prospecting','Milling','Wormhole')
spstr=20+n*rs
hidden=0
for i in range(n):
    o=20+i*rs
    sid=struct.unpack_from('<I',sp,o)[0]
    if sid not in profsp: continue
    attr=struct.unpack_from('<I',sp,o+16)[0]
    if attr&0xA0: continue
    no=struct.unpack_from('<I',sp,o+136*4)[0]
    nm=bytes(sp[spstr+no:sp.index(b'\0',spstr+no)]).decode('latin1')
    if nm.startswith(KEEP): continue
    struct.pack_into('<I',sp,o+16,attr|0x80); hidden+=1
print('profession spells hidden from spellbook',hidden)
write_mpq(D+'patch-Y.new',{'DBFilesClient\\ItemDisplayInfo.dbc':bytes(di),'DBFilesClient\\Item.dbc':bytes(it),'DBFilesClient\\Spell.dbc':bytes(sp)})
print('written')
