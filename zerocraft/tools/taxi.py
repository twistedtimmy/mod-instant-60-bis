import sys, struct; sys.path.insert(0,'.')
from mpq import MPQ
D = '/sessions/rcw-01nx1lyqyzzumfoxddiqwcrx/mnt/ChromieCraft_3.3.5a/Data/'
order=['enUS/patch-enUS-3.MPQ','patch-3.MPQ','enUS/patch-enUS-2.MPQ','patch-2.MPQ','enUS/patch-enUS.MPQ','patch.MPQ','enUS/lichking-locale-enUS.MPQ','lichking.MPQ','enUS/expansion-locale-enUS.MPQ','expansion.MPQ','enUS/locale-enUS.MPQ','common-2.MPQ','common.MPQ']
def get(n):
    for o in order:
        d=MPQ(D+o).read(n)
        if d: return o,d
for n in ['DBFilesClient\\TaxiNodes.dbc','DBFilesClient\\TaxiPath.dbc']:
    o,d=get(n); open(n.split('\\')[1],'wb').write(d); print(n,'from',o,struct.unpack_from('<4sIIII',d,0))
d=open('TaxiNodes.dbc','rb').read(); _,n,nf,rs,ss=struct.unpack_from('<4sIIII',d,0); strs=20+n*rs
def st(o): e=d.index(b'\0',strs+o); return d[strs+o:e].decode()
names={}
for i in range(n):
    r=struct.unpack_from('<I I f f f I', d, 20+i*rs); names[r[0]]=st(struct.unpack_from('<I',d,20+i*rs+20)[0])
    if r[0] in (25,32,80,23,55,179): print(r[0], names[r[0]], struct.unpack_from('<2I', d, 20+i*rs+rs-8))
p=open('TaxiPath.dbc','rb').read(); _,pn,pf,prs,_=struct.unpack_from('<4sIIII',p,0)
for i in range(pn):
    pid,a,b,c=struct.unpack_from('<4I',p,20+i*prs)
    if a in (25,32,80) or b in (25,32,80): print('path',a,names.get(a),'->',b,names.get(b))
