#!/usr/bin/env bash
# Збирає всі STL лампи в case/stl/. Падає на першій помилці або порушеному assert.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p case/stl case/stl/mold
for p in shade_top base bay_ring puck_core chassis reflector column knob_v1_carriage knob_v1_guide knob_v2_cap dimmer \
         batteries pcb pot_v1 pot_v2; do
  echo "== $p"
  openscad --hardwarnings --export-format binstl -o "case/stl/$p.stl" -D "part=\"$p\"" case/lamp.scad
done
# частини форми для відливки — в окремій теці (не потрапляють у assets/models.js: це не частини лампи)
# (штирі mold_pin зроблені разом із mold_core, окремо не друкуються; puck_core лежить у case/stl разом з іншими)
for p in mold_outer_a mold_outer_b mold_core usb_core; do
  echo "== $p"
  openscad --hardwarnings --export-format binstl -o "case/stl/mold/$p.stl" -D "part=\"$p\"" case/lamp.scad
done
# пробна чаша з пластику (отвори під вплавлення вставок) — окремо, не частина лампи
mkdir -p case/stl/test
openscad --hardwarnings --export-format binstl -o case/stl/test/base_plastic.stl -D 'part="base_plastic"' case/lamp.scad
# друковані деталі — кожна одним тілом (макети покупних деталей не перевіряємо)
python3 -I tools/stl_bodies.py case/stl/{shade_top,base,bay_ring,puck_core,chassis,reflector,column,knob_v1_carriage,knob_v1_guide,knob_v2_cap,dimmer}.stl case/stl/mold/*.stl case/stl/test/*.stl
bash tools/check_mold.sh
# 49.4 = cut_z + top_wall: пласка полиця над манжетою, друкується з підтримкою
python3 -I tools/overhangs.py case/stl/shade_top.stl 30 49.4
python3 -I tools/stl2js.py case/stl assets/models.js
