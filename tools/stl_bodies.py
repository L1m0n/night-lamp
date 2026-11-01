# Кількість окремих тіл у бінарному STL (вершини, спільні для трикутників, з'єднують їх).
# Друкована деталь має бути одним тілом. Виклик: python3 -I tools/stl_bodies.py a.stl ...; падає, якщо тіл > 1.
import struct, sys

def bodies(path):
    d = open(path, 'rb').read()
    n = struct.unpack('<I', d[80:84])[0]
    par = {}
    def root(x):
        while par.setdefault(x, x) != x:
            par[x] = par[par[x]]
            x = par[x]
        return x
    for i in range(n):
        o = 84 + i * 50 + 12
        v = [tuple(round(c, 4) for c in struct.unpack('<3f', d[o + j * 12:o + j * 12 + 12])) for j in range(3)]
        for w in v[1:]:
            par[root(w)] = root(v[0])
    return len({root(x) for x in par})

bad = [(p, b) for p in sys.argv[1:] if (b := bodies(p)) != 1]
for p, b in bad:
    print(f"ERROR: {p}: {b} тіл замість 1")
sys.exit(1 if bad else 0)
