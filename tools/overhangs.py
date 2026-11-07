# Площі граней, що в перевернутому друці нависають (нормаль у моделі дивиться вгору в межах 30° від осі z),
# згруповані по висоті (0.1 мм) і по чверті кола — щоб 4 однакові ламелі рахувались окремо.
# Виклик: python3 -I tools/overhangs.py a.stl max_mm2 [z ...]; падає, якщо група нижче z=174.3 (заглиблення/торець) більша за max_mm2.
# Додаткові z — свідомо прийняті нависання під підтримку (полиця над манжетою).
import math, struct, sys
from collections import defaultdict

FREE_Z = 174.3
path, limit = sys.argv[1], float(sys.argv[2])
allow = {round(float(x), 1) for x in sys.argv[3:]}
d = open(path, 'rb').read()
groups = defaultdict(float)
for i in range(struct.unpack('<I', d[80:84])[0]):
    v = struct.unpack('<9f', d[84 + i * 50 + 12:84 + i * 50 + 48])
    a, b, c = (v[0:3]), (v[3:6]), (v[6:9])
    u = [b[k] - a[k] for k in range(3)]; w = [c[k] - a[k] for k in range(3)]
    n = (u[1] * w[2] - u[2] * w[1], u[2] * w[0] - u[0] * w[2], u[0] * w[1] - u[1] * w[0])
    area2 = math.sqrt(sum(x * x for x in n))
    if area2 > 0 and n[2] / area2 > math.cos(math.radians(30)):
        cx, cy = (a[0] + b[0] + c[0]) / 3, (a[1] + b[1] + c[1]) / 3
        groups[(round((a[2] + b[2] + c[2]) / 3, 1), int((math.degrees(math.atan2(cy, cx)) % 360) // 90))] += area2 / 2
bad = False
for (z, q), s in sorted(groups.items()):
    over = z < FREE_Z and z not in allow and s > limit
    bad |= over
    if s > 1 or over:
        print(f"z={z:7.1f} чверть {q}: {s:7.1f} мм²{'  <-- ПЕРЕВИЩЕНО' if over else ''}")
sys.exit(1 if bad else 0)
