import sys, struct, re; sys.path.insert(0,'.')
from mpq import MPQ
D='/sessions/rcw-01nx1lyqyzzumfoxddiqwcrx/mnt/ChromieCraft_3.3.5a/Data/'
for o in ['enUS/patch-enUS-3.MPQ','patch-3.MPQ','enUS/patch-enUS-2.MPQ','patch-2.MPQ','enUS/patch-enUS.MPQ','patch.MPQ','lichking.MPQ','expansion.MPQ','enUS/locale-enUS.MPQ','common.MPQ']:
    d = MPQ(D+o).read('DBFilesClient\\ItemDisplayInfo.dbc')
    if d: break
_,n,nf,rs,ss = struct.unpack_from('<4sIIII', d, 0); strs=20+n*rs
def st(o): e=d.index(b'\0',strs+o); return d[strs+o:e].decode('latin1')
icon={}
for i in range(n):
    r=struct.unpack_from('<%dI'%nf,d,20+i*rs); icon[r[0]]=st(r[5]).lower()
items=[tuple(map(int,l.split())) for l in open('item_ids.txt')]
out=[]
for pat in [r'^inv_misc_horn_0[1-3]$', r'^inv_scroll_0[3-6]$', r'^inv_misc_note_0']:
    for (iid,_,_,disp) in items:
        if re.search(pat, icon.get(disp,'')) and iid not in [x[0] for x in out]: out.append((iid,disp))
print(len(out), out[:5])
open('recall_cands.txt','w').write(','.join('(%d,%d,%d)'%(i,dp,k) for k,(i,dp) in enumerate(out)))
