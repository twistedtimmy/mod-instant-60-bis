import sys, struct, json; sys.path.insert(0,'.')
from mpq import MPQ
D='/sessions/rcw-01nx1lyqyzzumfoxddiqwcrx/mnt/ChromieCraft_3.3.5a/Data/'
ORDER=['enUS/patch-enUS-3.MPQ','patch-3.MPQ','enUS/patch-enUS-2.MPQ','patch-2.MPQ','enUS/patch-enUS.MPQ','patch.MPQ','enUS/lichking-locale-enUS.MPQ','enUS/expansion-locale-enUS.MPQ','enUS/locale-enUS.MPQ']
def get(name):
    for o in ORDER:
        try: d=MPQ(D+o).read(name)
        except Exception: d=None
        if d: return d
def rows(d):
    _,n,nf,rs,ss=struct.unpack_from('<4sIIII',d,0); strs=20+n*rs
    st=lambda o: d[strs+o:d.index(b'\0',strs+o)].decode('utf8','replace')
    return [struct.unpack_from('<%dI'%nf,d,20+i*rs) for i in range(n)], st, nf
f=lambda u: struct.unpack('<f',struct.pack('<I',u))[0]
w,st,nf=rows(get('DBFilesClient\\WorldMapArea.dbc'))
print('WMA fields',nf)
maps={}
for r in w:
    if r[1] in (0,1,530):
        maps[st(r[3])]=(r[1],round(f(r[4]),1),round(f(r[5]),1),round(f(r[6]),1),round(f(r[7]),1))
print(len(maps), list(maps.items())[:5])
# use the client's (patched) TaxiNodes from patch-Z if present
z=MPQ(D+'patch-Z.MPQ').read('DBFilesClient\\TaxiNodes.dbc') or get('DBFilesClient\\TaxiNodes.dbc')
t,st2,_=rows(z)
bad=('Quest','Programmer','Transport','TEST','Test',' - ','->','Development','Generic','Filming','Prologue')
allowed530={'Silvermoon City','Tranquillien','Blood Watch','The Exodar'}
nodes={}
for r in t:
    nm=st2(r[5]).split(',')[0].strip()
    if not nm or not (r[22] or r[23]) or any(b in nm for b in bad): continue
    if r[1]==530 and nm not in allowed530: continue
    if r[1] not in (0,1,530): continue
    nodes[r[0]]=(nm,r[1],round(f(r[2]),1),round(f(r[3]),1))
print(len(nodes))
json.dump({'maps':maps,'nodes':nodes},open('terr.json','w'))
