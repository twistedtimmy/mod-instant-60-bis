import sys, struct; sys.path.insert(0,'.')
from mpq import MPQ
D = '/sessions/rcw-01nx1lyqyzzumfoxddiqwcrx/mnt/ChromieCraft_3.3.5a/Data/'
for o in ['enUS/patch-enUS-3.MPQ','patch-3.MPQ','enUS/patch-enUS-2.MPQ','patch-2.MPQ','enUS/patch-enUS.MPQ','patch.MPQ','lichking.MPQ','expansion.MPQ','enUS/locale-enUS.MPQ','common.MPQ']:
    d = MPQ(D+o).read('DBFilesClient\\ItemDisplayInfo.dbc')
    if d: break
_,n,nf,rs,ss = struct.unpack_from('<4sIIII', d, 0)
base=20; strs=base+n*rs
def st(o): e=d.index(b'\0',strs+o); return d[strs+o:e].decode('latin1')
icon={}
for i in range(n):
    r=struct.unpack_from('<%dI'%nf,d,base+i*rs); icon[r[0]]=st(r[5])
print('16161 icon', icon.get(16161))
target=icon[16161]
disps={k for k,v in icon.items() if v.lower()==target.lower()}
items=[l.split() for l in open('item_ids.txt')]
c=[int(x[0]) for x in items if int(x[3]) in disps]
print(len(c)); open('charter_cands.txt','w').write(','.join(map(str,c))); print(c[:50])
import re
pref=[]
for pat in [r'^inv_letter_17$', r'^inv_misc_note_0[1-6]$', r'^inv_letter_', r'^inv_scroll_0[1-9]$', r'^inv_misc_book_']:
    ds={k for k,v in icon.items() if re.search(pat, v.lower())}
    for x in items:
        i=int(x[0])
        if int(x[3]) in ds and i not in pref: pref.append(i)
print('total cands', len(pref))
open('cands_ordered.txt','w').write(','.join('(%d,%d)'%(i,k) for k,i in enumerate(pref)))
