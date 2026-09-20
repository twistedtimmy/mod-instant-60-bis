import sys, io, re, os; sys.path.insert(0,'.')
from mpq import MPQ
from PIL import Image, ImageDraw
m = MPQ('/sessions/rcw-01nx1lyqyzzumfoxddiqwcrx/mnt/ChromieCraft_3.3.5a/Data/common.MPQ')
lf = m.read('(listfile)').decode('latin1').split('\r\n')
ems = sorted({int(re.search(r'Emblem_(\d+)_', l).group(1)) for l in lf if re.search(r'GuildEmblems\\Emblem_\d+_15_TU_U', l, re.I)})
bgs = sorted({int(re.search(r'Background_(\d+)_', l, re.I).group(1)) for l in lf if re.search(r'GuildEmblems\\Background_\d+_TU_U', l, re.I)})
print(len(ems), ems[:5], ems[-5:], len(bgs))
cell=64; cols=16
sheet=Image.new('RGB',(cols*cell,((len(ems)+cols-1)//cols)*cell),(90,90,90)); dr=ImageDraw.Draw(sheet)
for k,e in enumerate(ems):
    name=[l for l in lf if re.search(r'GuildEmblems\\Emblem_%02d_15_TU_U\.blp$'%e, l, re.I)]
    if not name: continue
    d=m.read(name[0]); import struct, numpy as np
    w,h=struct.unpack_from('<II',d,12); off=struct.unpack_from('<I',d,20)[0]
    pal=np.frombuffer(d[148:148+1024],np.uint8).reshape(256,4)
    idx=np.frombuffer(d[off:off+w*h],np.uint8); al=np.frombuffer(d[off+w*h:off+2*w*h],np.uint8)
    rgb=pal[idx][:,[2,1,0]].reshape(h,w,3)
    raw=Image.fromarray(np.dstack([rgb,al.reshape(h,w)]).astype(np.uint8),'RGBA')
    im=raw.resize((cell,cell//2*2 if False else cell)); a=im.split()[3]
    x,y=(k%cols)*cell,(k//cols)*cell; sheet.paste(Image.new('RGB',(cell,cell),(255,255,255)),(x,y),a)
    dr.text((x+2,y+2),str(e),fill=(255,255,0))
out=os.path.expanduser('~/mnt/azerothcore/zc_map_work'); sheet.save(out+'/emblems.png')
sheet=Image.new('RGB',(cols*cell,((len(bgs)+cols-1)//cols)*cell)); dr=ImageDraw.Draw(sheet)
for k,b in enumerate(bgs):
    name=[l for l in lf if re.search(r'GuildEmblems\\Background_%02d_TU_U\.blp$'%b, l, re.I)]
    im=Image.open(io.BytesIO(m.read(name[0]))).convert('RGB').resize((cell,cell))
    x,y=(k%cols)*cell,(k//cols)*cell; sheet.paste(im,(x,y)); dr.text((x+2,y+2),str(b),fill=(255,255,255))
sheet.save(out+'/backgrounds.png')
