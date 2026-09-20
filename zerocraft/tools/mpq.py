import struct, zlib, bz2, os

def _crypt_table():
    t = [0]*0x500; seed = 0x00100001
    for i in range(0x100):
        idx = i
        for _ in range(5):
            seed = (seed*125+3) % 0x2AAAAB; a = (seed & 0xFFFF) << 16
            seed = (seed*125+3) % 0x2AAAAB; b = seed & 0xFFFF
            t[idx] = a | b; idx += 0x100
    return t
CT = _crypt_table()

def hs(s, t):
    s1, s2 = 0x7FED7FED, 0xEEEEEEEE
    for ch in s.upper().replace('/', '\\'):
        c = ord(ch)
        s1 = CT[(t << 8) + c] ^ ((s1 + s2) & 0xFFFFFFFF)
        s2 = (c + s1 + s2 + (s2 << 5) + 3) & 0xFFFFFFFF
    return s1

def decrypt(data, key):
    n = len(data)//4; out = bytearray(); s2 = 0xEEEEEEEE
    vals = struct.unpack('<%dI' % n, data[:n*4])
    res = []
    for v in vals:
        s2 = (s2 + CT[0x400 + (key & 0xFF)]) & 0xFFFFFFFF
        d = v ^ ((key + s2) & 0xFFFFFFFF)
        res.append(d)
        key = ((((~key) << 0x15) + 0x11111111) | (key >> 0x0B)) & 0xFFFFFFFF
        s2 = (d + s2 + (s2 << 5) + 3) & 0xFFFFFFFF
    return struct.pack('<%dI' % n, *res) + data[n*4:]

def encrypt(data, key):
    n = len(data)//4; s2 = 0xEEEEEEEE
    vals = struct.unpack('<%dI' % n, data[:n*4]); res = []
    for d in vals:
        s2 = (s2 + CT[0x400 + (key & 0xFF)]) & 0xFFFFFFFF
        res.append(d ^ ((key + s2) & 0xFFFFFFFF))
        key = ((((~key) << 0x15) + 0x11111111) | (key >> 0x0B)) & 0xFFFFFFFF
        s2 = (d + s2 + (s2 << 5) + 3) & 0xFFFFFFFF
    return struct.pack('<%dI' % n, *res) + data[n*4:]

class MPQ:
    def __init__(self, path):
        self.f = open(path, 'rb'); f = self.f
        off = 0
        while True:
            f.seek(off); m = f.read(4)
            if m == b'MPQ\x1a': break
            off += 512
        self.base = off
        h = f.read(28)
        (hsize, asize, ver, sshift, htpos, btpos, htn, btn) = struct.unpack('<IIHHIIII', h)
        self.sector = 512 << sshift
        hi_ht = hi_bt = 0
        if ver >= 1:
            f.seek(off+32); ext = f.read(12)
            _hibt, hi_ht, hi_bt = struct.unpack('<QHH', ext)
        f.seek(off + htpos + (hi_ht << 32)); ht = decrypt(f.read(htn*16), hs('(hash table)', 3))
        f.seek(off + btpos + (hi_bt << 32)); bt = decrypt(f.read(btn*16), hs('(block table)', 3))
        self.ht = [struct.unpack_from('<IIHHI', ht, i*16) for i in range(htn)]
        self.bt = [struct.unpack_from('<IIII', bt, i*16) for i in range(btn)]

    def find(self, name):
        n = len(self.ht); i = hs(name, 0) & (n-1); a = hs(name, 1); b = hs(name, 2)
        for _ in range(n):
            e = self.ht[i]
            if e[4] == 0xFFFFFFFF: return None
            if e[0] == a and e[1] == b and e[4] != 0xFFFFFFFE:
                return self.bt[e[4]]
            i = (i+1) & (n-1)
        return None

    def read(self, name):
        blk = self.find(name)
        if not blk: return None
        off, csize, fsize, flags = blk
        if not flags & 0x80000000 or flags & 0x02000000: return None
        if flags & 0x00010000: raise Exception('encrypted file not supported: ' + name)
        self.f.seek(self.base + off); raw = self.f.read(csize)
        if not (flags & 0x00000200 or flags & 0x00000100):
            return raw[:fsize]
        def dec(chunk, expect):
            if len(chunk) >= expect: return chunk[:expect]
            if flags & 0x00000100: raise Exception('implode not supported')
            m = chunk[0]; d = chunk[1:]
            if m == 0x02: return zlib.decompress(d)
            if m == 0x10: return bz2.decompress(d)
            raise Exception('compression %02x not supported' % m)
        if flags & 0x01000000:
            return dec(raw, fsize)
        ns = (fsize + self.sector - 1)//self.sector
        offs = struct.unpack_from('<%dI' % (ns+1), raw, 0)
        out = bytearray()
        for i in range(ns):
            expect = min(self.sector, fsize - i*self.sector)
            out += dec(raw[offs[i]:offs[i+1]], expect)
        return bytes(out)

def write_mpq(path, files):
    """files: dict name -> bytes. Stored uncompressed, format v1."""
    names = list(files.keys()) + ['(listfile)']
    data = dict(files); data['(listfile)'] = ('\r\n'.join(files.keys()) + '\r\n').encode()
    htn = 16
    while htn < len(names)*2: htn *= 2
    body = bytearray(); blocks = []
    pos = 32
    for n in names:
        d = data[n]; blocks.append((pos, len(d), len(d), 0x80000000 | 0x01000000)); body += d; pos += len(d)
    ht = [(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFF, 0xFFFF, 0xFFFFFFFF)] * htn
    for bi, n in enumerate(names):
        i = hs(n, 0) & (htn-1)
        while ht[i][4] != 0xFFFFFFFF: i = (i+1) & (htn-1)
        ht[i] = (hs(n, 1), hs(n, 2), 0, 0, bi)
    htb = b''.join(struct.pack('<IIHHI', *e) for e in ht)
    btb = b''.join(struct.pack('<IIII', *b) for b in blocks)
    htpos = pos; btpos = pos + len(htb)
    total = btpos + len(btb)
    hdr = struct.pack('<4sIIHHIIII', b'MPQ\x1a', 32, total, 0, 3, htpos, btpos, htn, len(blocks))
    with open(path, 'wb') as f:
        f.write(hdr); f.write(body)
        f.write(encrypt(htb, hs('(hash table)', 3))); f.write(encrypt(btb, hs('(block table)', 3)))
