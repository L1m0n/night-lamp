#!/usr/bin/env python3
"""Пакує STL (бінарний/текстовий) у assets/models.js. Використання: stl2js.py <stl_dir> <out.js>"""
import sys, os, re, struct, base64, glob

def read_stl(path):
    """Повертає плоский список координат (9 на трикутник), округлених до 0.01 мм."""
    d = open(path, 'rb').read()
    n = struct.unpack_from('<I', d, 80)[0] if len(d) >= 84 else -1
    if len(d) == 84 + 50 * n:  # бінарний
        v = []
        for i in range(n):
            v += struct.unpack_from('<9f', d, 84 + 50 * i + 12)
    else:  # текстовий
        v = [float(x) for x in re.findall(rb'vertex\s+(\S+)\s+(\S+)\s+(\S+)', d) for x in x]
    return [round(x, 2) + 0.0 for x in v]  # +0.0: прибирає -0.0

def bbox(v):
    return [(min(v[a::3]), max(v[a::3])) for a in range(3)]

def main(src, out):
    files = sorted(glob.glob(os.path.join(src, '*.stl')))
    assert files, 'немає STL у ' + src
    models, raw = {}, {}
    for f in files:
        name = os.path.splitext(os.path.basename(f))[0]
        raw[name] = v = read_stl(f)
        models[name] = (base64.b64encode(struct.pack('<%df' % len(v), *v)).decode(), len(v) // 9)
    with open(out, 'w') as o:
        o.write('// pos = base64 little-endian Float32 xyz, непроіндексовані трикутники (tri*9 float), мм; нормалі — computeVertexNormals()\n')
        o.write('window.LAMP_MODELS = {\n')
        o.write(',\n'.join('  %s: {pos: "%s", tri: %d}' % (k, p, t) for k, (p, t) in models.items()))
        o.write('\n};\n')
    # самоперевірка: розкодовуємо те, що записали у файл
    txt = open(out).read()
    print('%-18s %7s  %s' % ('модель', 'трик.', 'бокс x / y / z, мм'))
    for m in re.finditer(r'  (\w+): \{pos: "([^"]*)", tri: (\d+)\}', txt):
        k, b64, tri = m.group(1), m.group(2), int(m.group(3))
        blob = base64.b64decode(b64)
        assert len(blob) == tri * 36, k
        got = struct.unpack('<%df' % (tri * 9), blob)
        want = read_stl_raw(os.path.join(src, k + '.stl'))
        assert tri == len(want) // 9, k
        bg, bw = bbox(got), bbox(want)
        assert all(abs(a - b) <= 0.02 for g, w in zip(bg, bw) for a, b in zip(g, w)), (k, bg, bw)
        print('%-18s %7d  %s' % (k, tri, ' / '.join('%.2f..%.2f' % g for g in bg)))
    assert len(re.findall(r'tri: \d+', txt)) == len(files)
    print('%s: %.2f МБ' % (out, os.path.getsize(out) / 1e6))

def read_stl_raw(path):  # без округлення — еталон для порівняння
    d = open(path, 'rb').read()
    n = struct.unpack_from('<I', d, 80)[0]
    if len(d) == 84 + 50 * n:
        v = []
        for i in range(n):
            v += struct.unpack_from('<9f', d, 84 + 50 * i + 12)
        return v
    return [float(x) for t in re.findall(rb'vertex\s+(\S+)\s+(\S+)\s+(\S+)', d) for x in t]

if __name__ == '__main__':
    main(*sys.argv[1:3])
