import sys, re
sys.path.insert(0, '.')
from mpq import MPQ
D = '/sessions/rcw-01nx1lyqyzzumfoxddiqwcrx/mnt/ChromieCraft_3.3.5a/Data/'
order = ['enUS/patch-enUS-3.MPQ','patch-3.MPQ','enUS/patch-enUS-2.MPQ','patch-2.MPQ','enUS/patch-enUS.MPQ','patch.MPQ',
         'enUS/lichking-locale-enUS.MPQ','lichking.MPQ','enUS/expansion-locale-enUS.MPQ','expansion.MPQ','enUS/locale-enUS.MPQ','common-2.MPQ','common.MPQ']
for o in order:
    try:
        m = MPQ(D+o)
        lf = m.read('(listfile)')
        hits = [l for l in lf.decode('latin1').split('\r\n') if re.search(r'^interface\\worldmap\\world\\', l, re.I)] if lf else []
        print(o, len(hits), hits[:30])
    except Exception as e:
        print(o, 'ERR', e)
