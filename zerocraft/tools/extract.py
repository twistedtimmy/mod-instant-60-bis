import sys, io; sys.path.insert(0,'.')
from mpq import MPQ
from PIL import Image
D = '/sessions/rcw-01nx1lyqyzzumfoxddiqwcrx/mnt/ChromieCraft_3.3.5a/Data/'
m = MPQ(D+'enUS/locale-enUS.MPQ')
import os
out = os.path.expanduser('~/mnt/azerothcore/zc_map_work'); os.makedirs(out, exist_ok=True)
for base in ['World','Azeroth']:
    tiles=[]
    for i in range(1,13):
        d = m.read('Interface\\WorldMap\\%s\\%s%d.blp' % (base, base, i))
        open(os.path.join(out, '%s%d.blp' % (base,i)),'wb').write(d)
        tiles.append(Image.open(io.BytesIO(d)).convert('RGBA'))
    w,h = tiles[0].size
    img = Image.new('RGBA',(w*4,h*3))
    for i,t in enumerate(tiles): img.paste(t,((i%4)*w,(i//4)*h))
    img.save(os.path.join(out, base+'.png')); print(base, tiles[0].size, tiles[0].mode, img.size)
    print(open(os.path.join(out, '%s1.blp'%base),'rb').read(24))
