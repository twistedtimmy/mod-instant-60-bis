import sys; sys.path.insert(0,'.')
from mpq import MPQ
D = '/sessions/rcw-01nx1lyqyzzumfoxddiqwcrx/mnt/ChromieCraft_3.3.5a/Data/'
order = ['enUS/patch-enUS-3.MPQ','patch-3.MPQ','enUS/patch-enUS-2.MPQ','patch-2.MPQ','enUS/patch-enUS.MPQ','patch.MPQ',
         'enUS/lichking-locale-enUS.MPQ','lichking.MPQ','enUS/expansion-locale-enUS.MPQ','expansion.MPQ','enUS/locale-enUS.MPQ','common-2.MPQ','common.MPQ']
names = ['Interface\\WorldMap\\World\\World1.blp','Interface\\WorldMap\\World\\World5.blp','Interface\\WorldMap\\Cosmic\\Cosmic1.blp']
for o in order:
    m = MPQ(D+o)
    print(o, [ (n.split('\\')[-1], m.find(n)) for n in names])
