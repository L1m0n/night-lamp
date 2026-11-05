#!/usr/bin/env bash
# Перевірка форми для відливки (CGAL-об'єми, мм³): частини не перетинаються з основою й одна з одною,
# між формою й основою немає щілин, порожнина сердечника ніде не виходить до бетону,
# puck_core виймається вниз, usb_core — вбік +X без зачеплення за бетон.
set -euo pipefail
cd "$(dirname "$0")/.."
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
L="$PWD/case/lamp.scad"
chk() {  # ім'я  вираз  максимум
  printf 'include <%s>\n%s\n' "$L" "$2" > "$T/$1.scad"
  ( if ! openscad --export-format binstl -o "$T/$1.stl" -D 'part="none"' "$T/$1.scad" >/dev/null 2>"$T/$1.err" && ! grep -q "object is empty" "$T/$1.err"; then echo "FAIL $1: помилка openscad"; exit 0; fi
    python3 -I tools/stl_volume.py "$T/$1.stl" "$1" "$3" ) > "$T/$1.out" &
}
for m in 'mold_outer(1)' 'mold_outer(-1)' 'mold_core()' 'puck_core()' 'usb_core()'; do chk "base_x_$m" "intersection(){ base(); $m; }" 1.5; done
chk o_ab    'intersection(){ mold_outer(1); mold_outer(-1); }' 1.5
for o in 1 -1; do for m in 'mold_core()' 'puck_core()' 'usb_core()'; do chk "o${o}_x_$m" "intersection(){ mold_outer($o); $m; }" 1.5; done; done
chk core_puck 'intersection(){ mold_core(); puck_core(); }' 1.5
chk core_usb  'intersection(){ mold_core(); usb_core(); }' 1.5
chk puck_usb  'intersection(){ puck_core(); usb_core(); }' 1.5
# щілини між формою й основою: лише кільце зазору 0.1 мм у гнізді каналу (~2.5)
chk gap 'difference(){ rotate_extrude() base_outer_2d(cut_z); base(); mold_core(true); puck_core(); usb_core(); insert_holes(); }' 5
# порожнина сердечника (без випусків) не ближче 1 мм до бетону ні в одному з 6 напрямків
for d in '1,0,0' '-1,0,0' '0,1,0' '0,-1,0' '0,0,1' '0,0,-1'; do chk "void_$d" "intersection(){ translate([$d]) difference(){ mold_core(true); mold_core(false, false); } base(); }" 0.5; done
chk pull_down 'intersection(){ base(); union(){ for (i = [1 : 25]) translate([0, 0, -i]) puck_core(); } }' 1.5
chk pull_x    'intersection(){ base(); union(){ for (i = [1 : 12]) translate([i, 0, 0]) usb_core(); } }' 1.5
wait
cat "$T"/*.out | sort
! grep -q FAIL "$T"/*.out
