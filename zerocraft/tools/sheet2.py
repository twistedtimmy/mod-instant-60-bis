import sys, io, re, os, struct, numpy as np; sys.path.insert(0,'.')
from mpq import MPQ
from PIL import Image, ImageDraw
m = MPQ('/sessions/rcw-01nx1lyqyzzumfoxddiqwcrx/mnt/ChromieCraft_3.3.5a/Data/common.MPQ')
def dec(n):
    d=m.read(n)
    w,h=struct.unpack_from('<II',d,12); off=struct.unpack_from('<I',d,20)[0]
    al=np.frombuffer(d[off+w*h:off+2*w*h],np.uint8).reshape(h,w)
    return al
cw,ch=96,90; cols=17
rows=(170+cols-1)//cols
sheet=Image.new('L',(cols*cw,rows*ch),60); dr=ImageDraw.Draw(sheet)
for e in range(170):
    try:
        a=np.vstack([dec('textures\\GuildEmblems\\Emblem_%02d_15_TU_U.blp'%e), dec('textures\\GuildEmblems\\Emblem_%02d_15_TL_U.blp'%e)])
    except Exception as ex:
        continue
    im=Image.fromarray(a).resize((72,54))
    x,y=(e%cols)*cw,(e//cols)*ch
    sheet.paste(Image.new('L',(72,54),255),(x+12,y+2),im)
    dr.text((x+40,y+72),str(e),fill=255)
sheet.save(os.path.expanduser('~/mnt/azerothcore/zc_map_work/emblems.png'))
