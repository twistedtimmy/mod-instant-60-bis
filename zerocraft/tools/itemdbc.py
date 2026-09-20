import sys, struct; sys.path.insert(0,'.')
from mpq import MPQ
D = '/sessions/rcw-01nx1lyqyzzumfoxddiqwcrx/mnt/ChromieCraft_3.3.5a/Data/'
for o in ['enUS/patch-enUS-3.MPQ','patch-3.MPQ','enUS/patch-enUS-2.MPQ','patch-2.MPQ','enUS/patch-enUS.MPQ','patch.MPQ','enUS/lichking-locale-enUS.MPQ','lichking.MPQ','enUS/expansion-locale-enUS.MPQ','expansion.MPQ','enUS/locale-enUS.MPQ','common-2.MPQ','common.MPQ']:
    m = MPQ(D+o); d = m.read('DBFilesClient\\Item.dbc')
    if d: print('from', o); break
_,n,nf,rs,ss = struct.unpack_from('<4sIIII', d, 0)
rows = [struct.unpack_from('<%dI'%nf, d, 20+i*rs) for i in range(n)]
disp = {r[0]: r[5] for r in rows}
print(n, nf, 'charter 5863 display', disp.get(5863), 'banner 23701', disp.get(23701))
c = [r[0] for r in rows if r[5] == disp[5863]]
print(len(c), c[:80])
open('item_ids.txt','w').write('\n'.join('%d %d %d %d'%(r[0],r[1],r[2],r[5]) for r in rows))
