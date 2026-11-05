# Об'єм бінарного STL (мм³); немає файлу = порожній результат CGAL = 0. Виклик: stl_volume.py <stl> <ім'я> <максимум>; FAIL, якщо об'єм більший.
import os, struct, sys
f, name, mx = sys.argv[1], sys.argv[2], float(sys.argv[3])
v = 0.0
if os.path.exists(f):
    d = open(f, 'rb').read()
    for i in range(struct.unpack('<I', d[80:84])[0]):
        a = struct.unpack('<9f', d[84 + i * 50 + 12:84 + i * 50 + 48])
        v += (a[0] * (a[4] * a[8] - a[5] * a[7]) - a[1] * (a[3] * a[8] - a[5] * a[6]) + a[2] * (a[3] * a[7] - a[4] * a[6])) / 6
print(f"{'FAIL' if abs(v) > mx else 'ok  '} {name:28s} {v:10.2f}  (<= {mx})")
