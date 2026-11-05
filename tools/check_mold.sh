#!/usr/bin/env bash
# Перевірка форми для відливки (CGAL-об'єми, мм³): частини не перетинаються з основою й одна з одною,
# між формою й основою немає щілин, порожнина сердечника ніде не виходить до бетону,
# puck_core виймається вниз, usb_core — вбік +X без зачеплення за бетон.
set -euo pipefail
cd "$(dirname "$0")/.."
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
L="$PWD/case/lamp.scad"
N=0; PIDS=()
chk() {  # ім'я  вираз  максимум; порожній результат CGAL ("object is empty") = 0, будь-яка інша помилка openscad — збій
  N=$((N + 1))
  printf 'include <%s>\n%s\n' "$L" "$2" > "$T/$1.scad"
  ( set -e
    if ! openscad --export-format binstl -o "$T/$1.stl" -D 'part="none"' "$T/$1.scad" >/dev/null 2>"$T/$1.err"; then
      grep -q "Current top level object is empty" "$T/$1.err" || { echo "FAIL $1: помилка openscad"; exit 1; }
    fi
    python3 -I tools/stl_volume.py "$T/$1.stl" "$1" "$3" ) > "$T/$1.out" &
  PIDS+=($!)
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
# сердечник піднімається без зачепів за бетон (усі кроки, з бортиком, штирями, пазами)
for h in 0.5 1 2 5 10 30; do chk "lift_$h" "intersection(){ base(); translate([0, 0, $h]) mold_core(); }" 1.5; done
# вставка бортика (реальний OD) цілком у половині A: B її не торкається, поза A лишається тільки отвір під вплавлення
for sx in -1 1; do
  ins="translate([$sx * mold_tab_x, mold_tab_y, cut_z - insert[1]]) cylinder(d = insert[0], h = insert[1], \$fn = 48)"
  chk "tab_in_B_$sx" "intersection(){ $ins; mold_outer(-1); }" 0.05
  chk "tab_out_A_$sx" "difference(){ $ins; mold_outer(1); translate([$sx * mold_tab_x, mold_tab_y, cut_z - 9]) cylinder(d = insert[0] - 0.4, h = 10, \$fn = 48); }" 0.5
done
FAILED=0; for p in "${PIDS[@]}"; do wait "$p" || FAILED=1; done
cat "$T"/*.out | sort
OK=$(cat "$T"/*.out | grep -c '^ok' || true)
echo "перевірок: $N, ok: $OK"
[ "$FAILED" = 0 ] && [ "$OK" = "$N" ]
