import sys, re; sys.path.insert(0,'.')
from mpq import MPQ
D = '/sessions/rcw-01nx1lyqyzzumfoxddiqwcrx/mnt/ChromieCraft_3.3.5a/Data/'
for o in ['common.MPQ','common-2.MPQ','expansion.MPQ','lichking.MPQ','patch.MPQ','patch-2.MPQ','patch-3.MPQ']:
    lf = MPQ(D+o).read('(listfile)')
    if not lf: continue
    h=[l for l in lf.decode('latin1').split('\r\n') if re.search(r'guildemblem', l, re.I)]
    print(o, len(h), h[:12], h[-4:])
