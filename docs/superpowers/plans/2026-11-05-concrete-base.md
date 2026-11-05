# Бетонна основа і байонетне кільце — план реалізації

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Замінити друковану чашу + бетонну шайбу однією бетонною основою зі стінкою 5 мм, а байонет у стінці чаші — друкованим байонетним кільцем на гвинтах M3; під це — 4 комірки, шасі, відбивач, манжета плафона, форма для відливки і сторінки.

**Architecture:** Уся геометрія — параметрична в `case/lamp.scad`; «тести» — це `assert` у ньому (`openscad --hardwarnings` падає на порушенні), перевірка «одне тіло» `tools/stl_bodies.py` і нова перевірка нависань плафона. `tools/build.sh` збирає STL і пакує їх у `assets/models.js`, з якого малюють `render.html` і `parts-3d.html`.

**Tech Stack:** OpenSCAD (CLI), Python 3 (stdlib), three.js 0.147 на сторінках, GitHub Pages.

**Spec:** `docs/superpowers/specs/2026-11-05-concrete-base-design.md`

## Global Constraints

- Плафон: форма, шов `cut_z = 48.2` і стінка `top_wall = 1.2` — без змін. Змінюється лише манжета й ламелі.
- Бетонна основа — одна деталь від столу z=5 до `cut_z`; стінка `base_wall = 5`.
- Порожнина основи з ухилом `draft = 1` (градус) до відкритого верху — без піднутрень.
- Кільце — PETG, пригвинчується 4 гвинтами M3 з потайною головкою до 4 латунних вставок M3 (OD 4.6, довжина 5.7) у бетонних п'ятачках на 0°, 90°, 180°, 270°.
- 4 ламелі, поворот 30°, скіс пазу притягує плафон до краю, горбик-фіксатор у кінці.
- 4 комірки 60×20×8 (`layers = 2`), ≈3400 мА·год.
- Плафон друкується догори дриґом без високих підтримок (дозволено тільки заглиблення під дімер і ламелі ≤ 30 мм² кожна).
- Найвища друкована деталь ≤ 180 мм (Bambu A1 mini); кожна друкована деталь — одне тіло.
- Якщо вікно акумуляторів не сходиться із зазорами ≥ 0.3 — **зупинитись і спитати користувача**, не зменшувати кількість комірок.
- Тексти сторінок і коментарі — українською, у стилі файлів, що вже є.

## Review Focus

- Кут нижньої комірки впирається в заокруглення дна порожнини (найтісніше місце) — assert з фактичною порожниною з ухилом, а не з `in_r`.
- Шасі не проходить крізь кільце/повз п'ятачки при складанні зверху — assert на прохід.
- Сердечник форми не виймається (піднутрення) — assert, що радіус порожнини не зростає вгору ніде на z ∈ [дно, cut_z].
- Ламель не заходить у вхід пазу або паз прориває кільце (стінка за пазом < 1.2) — asserts на кільце.
- Плафон знову вимагає високих дерев підтримки — скрипт нависань у build.sh.

---

### Task 1: Бетонна основа `base` замість `bowl` + `puck`

**Files:**
- Modify: `case/lamp.scad` (параметри, похідні, asserts, модулі `bowl`, `puck`, `puck_void`, `puck_core`, `scene`, перемикач `part`)

**Interfaces:**
- Produces:
  - **на початку задачі**, щоб наступні задачі мали на що спиратися: `cut_z = 48.2` константою (замість похідної від відбивача), `lap = 5`, `ring_z0 = cut_z - lap`;
  - параметри `base_wall = 5`, `draft = 1`, `floor_z` (верх бетонного дна = `chassis_z`), `pad = [7, 7]` (п'ятачок: радіально, по висоті), `pad_a = [0, 90, 180, 270]`, `insert = [4.6, 5.7]` (латунна вставка: OD, довжина);
  - функція `cav_r(z)` — внутрішній радіус порожнини основи: `min(in_r(z) + wall - base_wall, cav_r_top - tan(draft) * (cut_z - z))`, де `cav_r_top = in_r(cut_z) + wall - base_wall`;
  - модулі `base()`, `base_void()` (порожнина + усе, що було в `puck_void()`), `insert_holes()`;
  - `part == "base"`; `bowl`, `puck` видалити; `puck_core` лишити як вкладиш форми (переїде в Task 4).
- Consumes: `shade_profile()`, `in_r()`, `puck_void()` (кишеня IP5306, зенківка USB-C, канал) — без змін у їхніх розмірах.

- [ ] **Step 1: Assert-и, що мають впасти**

Додати в блок asserts:

```scad
for (z = [floor_z : 0.5 : cut_z - 0.5]) assert(cav_r(z + 0.5) >= cav_r(z) - 1e-6, "порожнина основи має піднутрення: сердечник не вийде");
assert(pm_top + 3 <= floor_z, "бетон над кишенею IP5306 тонший за 3 мм");
```

- [ ] **Step 2: Запустити — падає на невідомих `cav_r`/`floor_z`**

Run: `openscad --hardwarnings -o /tmp/b.stl -D 'part="base"' case/lamp.scad`
Expected: помилка про невизначене `cav_r` / `floor_z`.

- [ ] **Step 3: Реалізувати `base()`**

Зовнішнє тіло — `rotate_extrude` огинаючої `shade_envelope()`, обрізаної `zslab(5, cut_z)` (шайбу під кільцем-дном заповнює бетон від z=5). Мінус `base_void()`: порожнина `rotate_extrude` профілю `[[0, floor_z], [cav_r(z), z]…, [0, cut_z+1]]` (крок 1 мм), плюс `puck_void()`, плюс канал `chan_d` від `puck_z[1]` до `floor_z + 1`. Плюс 4 п'ятачки: `arc_ring` по ±8° навколо кожного кута `pad_a`, від `cav_r - pad.x` до стінки, z від `ring_z0 - pad.y` до `ring_z0` (`ring_z0` з початку цієї задачі). Мінус `insert_holes()`: циліндр `d = insert[0]`, глибина `insert[1]` униз від верху п'ятачка, по центру п'ятачка. `floor_z = chassis_z` (число уточнить Task 2).

- [ ] **Step 4: Зібрати і перевірити**

Run: `openscad --hardwarnings -o case/stl/base.stl -D 'part="base"' case/lamp.scad && python3 -I tools/stl_bodies.py case/stl/base.stl`
Expected: без помилок; одне тіло; габарит ≈ Ø112, z 5…48.2.

- [ ] **Step 5: Commit** — `основа: бетонна відливка замість чаші й шайби`

---

### Task 2: 4 комірки, шасі, відбивач — вікно акумуляторів

**Files:**
- Modify: `case/lamp.scad` (`layers`, `chassis_z`, `deck_z`, `refl`, `refl_z`, `cut_z`, `pocket_r`, `chassis()`, asserts акумуляторів)

**Interfaces:**
- Consumes: `cav_r(z)`, `pad`, `pad_a`, `cut_z`, `lap`, `ring_z0` (Task 1).
- Produces: `layers = 2`; `deck_z` — підібраний так, щоб кут нижньої комірки влазив; `refl_z = bat_top`; `refl[0]` — під внутрішній радіус манжети.

- [ ] **Step 1: Assert-и вікна (мають впасти на поточних числах)**

```scad
assert(bat_corner + 0.3 <= cav_r(deck_z), "кут нижньої комірки впирається в заокруглення дна основи");
assert(bat_top + 0.3 <= ring_z0, "верхня комірка зачіпає байонетне кільце");
assert(chassis_d / 2 + chassis_fit <= cav_r(chassis_z), "шасі не лягає на дно основи");
for (a = pad_a) assert(chassis_pass_ok(a), "шасі не проходить повз п'ятачок при складанні");
assert(refl[0] / 2 + 0.3 <= sleeve_r - lap_t, "відбивач не влазить у манжету плафона");
```

`chassis_pass_ok(a)` — функція: шасі (з вирізами під п'ятачки, якщо вони є) не перетинає `cav_r(pad_z) - pad.x` на куті `a`. Простіше: вирізати в шасі 4 виїмки під п'ятачки й перевіряти `chassis_d/2 <= cav_r(z) - pad.x` поза виїмками — рішення за виконавцем, але assert має бути.

- [ ] **Step 2: Запустити — падає**

Run: `openscad --hardwarnings -o /tmp/c.stl -D 'part="chassis"' case/lamp.scad`
Expected: FAIL на одному з asserts вікна.

- [ ] **Step 3: Реалізувати**

`layers = 2`; `chassis_z = deck_z - chassis_t`; `deck_z` у межах ≈ 26.5…27.2 — підібрати найнижчий, що проходить перший assert, з запасом ≥ 0.3. `pocket_r = cav_r(deck_z) - 0.3`. Шасі: 4 виїмки під п'ятачки (якщо потрібні для проходу). `refl[0] = 2 * (sleeve_r - lap_t - 0.3)` округлено вниз до 0.5. Видалити старі asserts, що посилаються на `in_r` для акумуляторів/шасі/відбивача.

- [ ] **Step 4: Перевірити**

Run: `bash tools/build.sh` (після Task 3 — повністю; на цьому кроці можна лише `-D 'part="chassis"'` і `"batteries"`)
Expected: без помилок. **Якщо жоден `deck_z` не проходить обидва asserts вікна — зупинитись, записати фактичні числа і спитати користувача.**

- [ ] **Step 5: Commit** — `шасі: 4 комірки на бетонному дні`

---

### Task 3: Байонетне кільце `bay_ring` і манжета плафона

**Files:**
- Modify: `case/lamp.scad` (блок `/* [Байонет] */`, `sleeve_r`, `bay_*`, `shade_top()`, новий `bay_ring()`, asserts байонета)
- Create: `tools/overhangs.py`
- Modify: `tools/build.sh` (виклик `overhangs.py` для `shade_top`)

**Interfaces:**
- Produces:
  - `ring_t = 2.5` (висота кільця = `lap` з Task 1), `ring_r = [cav_r(cut_z) - ring_t, cav_r(ring_z0) - 0.1]` (внутрішній, зовнішній; кільце сідає в бетон з зазором 0.1);
  - `sleeve_r = ring_r[0] - lap_fit`; `bay = [10, 2, 1.0]`, `bay_n = 4`, `bay_turn = 30`, `bay_ramp = 0.6` (на скільки паз піднімається за поворот), `bump_h = 0.4`;
  - `bay_ring()`, `part == "bay_ring"`; 4 вушка всередину на `pad_a` з потайним отвором M3 (Ø3.4, зенківка 90° Ø6.5) над `insert_holes()`;
  - `tools/overhangs.py <stl> <max_mm2>` — друкує площі граней, що в перевернутому положенні нахилені менше 30° від горизонталі, згруповані по z; exit 1, якщо будь-яка група поза зонами `z ≥ plate_z[0] - 0.1` (заглиблення/торець) має площу > `max_mm2`.
- Consumes: `cav_r()`, `pad_a`, `insert`, `top_in`, `top_wall`.

- [ ] **Step 1: Тест нависань — має впасти**

`tools/overhangs.py` з аргументами `case/stl/shade_top.stl 30`. Логіка: як у разовій перевірці в сесії — нормаль `nz > cos(30°)` (у моделі грань дивиться вгору = у друці вниз), групи по `round(z,1)`; дозволені без ліміту групи з `z ≥ 174.3`. Додати в `build.sh` після STL: `python3 -I tools/overhangs.py case/stl/shade_top.stl 30`.

- [ ] **Step 2: Assert-и кільця**

```scad
assert(ring_t - (bay.z + bay_fit) >= 1.2, "стінка кільця за пазом < 1.2");
assert(ring_r[1] <= cav_r(cut_z) + 0.01 && ring_r[1] <= cav_r(ring_z0) + 0.01, "кільце не входить у бетон");
assert(bay_ramp + bay.y + 2 * bay_fit + bump_h < lap - 1, "паз зі скосом не вміщується у висоту кільця");
assert(bay_n * (bay.x / sleeve_r * 180 / PI + bay_turn + 2) < 360, "пази 4 ламелей перекриваються");
```

- [ ] **Step 3: Запустити — падає** (`ring_t` тощо невизначені).

- [ ] **Step 4: Реалізувати**

`bay_ring()`: `arc_ring` / циліндр-кільце `ring_r`, z `ring_z0…cut_z`; мінус 4 Г-пази: вертикальний вхід від верху на ширину ламелі + зазор, далі горизонтальна частина на `bay_turn`, дно якої піднімається на `bay_ramp` за поворот (робити `hull()` двох тонких `arc_ring` на початку й кінці або сегментами по 2°); горбик `bump_h` перед кінцем повороту (як у старому `bowl()`). Плюс 4 вушка всередину на `pad_a` з потайними отворами. `shade_top()`: манжета `sleeve_r`, висота `lap`; 4 ламелі `bay` з верхньою гранню під кут скосу (досить `hull()` двох `arc_ring` різної висоти); скіс 45° від `sleeve_r - lap_t` до `top_in` — як зараз (`chamf` перерахується сам). Видалити старі asserts байонета в чаші (`паз байонета прориває чашу`, `манжета плафона зачіпає акумулятори` — замінити на `ring_z0 >= bat_top + 0.3` з Task 2).

- [ ] **Step 5: Перевірити**

Run: `bash tools/build.sh`
Expected: без помилок; `overhangs.py` проходить (лишаються тільки заглиблення під дімер і 4 ламелі ≤ 30 мм²); `bay_ring` і `shade_top` — по одному тілу.

- [ ] **Step 6: Commit** — `байонетне кільце на гвинтах, 4 ламелі на манжеті`

---

### Task 4: Форма для відливки

**Files:**
- Modify: `case/lamp.scad` (модулі `mold_outer(side)`, `mold_core()`, `mold_pin()`, `puck_core()`; `part` = `mold_outer_a`, `mold_outer_b`, `mold_core`, `mold_pin`, `puck_core`)
- Modify: `tools/build.sh`

**Interfaces:**
- Consumes: `base()`, `base_void()`, `cav_r()`, `puck_void()`, `insert`, `pad_a`.
- Produces: друковані частини форми; `mold_t = 3` (стінка форми), `mold_flange = 8` (фланці на стику половин з 4 отворами Ø4 під болти M3).

- [ ] **Step 1: Assert-и форми**

```scad
assert(mold_t >= 2.4, "стінка форми тонка: прогнеться під бетоном");
assert(max(base_h, 2 * (belt_r + mold_t + mold_flange)) <= 180, "частина форми не влазить на стіл A1 mini");
```

(`base_h = cut_z - 5`).

- [ ] **Step 2: Запустити — падає**, реалізувати:

- `mold_outer(side)`: оболонка навколо зовнішньої поверхні `base()` товщиною `mold_t`, відкрита зверху (заливаємо в робочому положенні: відкритий верх = край чаші, туди ставиться сердечник), розрізана площиною XZ на половини `side = ±1`, з фланцями на стику; знизу — дно форми з виступом-вікном під зенківку USB-C (гніздо формує `puck_core`).
- `mold_core()`: тіло порожнини (`base_void()` без `puck_void()`), порожнисте всередині зі стінкою 2, з бортиком зверху, що лягає на край форми й центрує сердечник; 4 штирі `mold_pin()` Ø2.5 униз з бортика в центри `insert_holes()`, на які надіваються латунні вставки.
- `puck_core()`: як зараз (кишеня IP5306 + зенківка + канал), але канал доходить до `floor_z`, щоб зустрітися з сердечником.

- [ ] **Step 3: Перевірити**

Run: `bash tools/build.sh`
Expected: без помилок; кожна частина форми — одне тіло; жодна не вища/ширша за 180.

- [ ] **Step 4: Commit** — `форма для відливки бетонної основи`

---

### Task 5: Збирання, 3D-сторінки, перелік деталей, схеми, спека

**Files:**
- Modify: `tools/build.sh` (перелік деталей: прибрати `bowl`, `puck`; додати `base`, `bay_ring`, `mold_outer_a`, `mold_outer_b`, `mold_core`, `puck_core`; той самий перелік у `stl_bodies.py`-виклику)
- Modify: `assets/lamp3d.js` (підписи/матеріали: `base` — «Основа», «бетон, одна відливка», матеріал бетону `std(0xb9b4ac, 0.95)`; `bay_ring` — «Байонетне кільце», «PETG, 4 гвинти M3»; частини форми — розділ «Лиття»; батареї — «Акумулятори 4× Li-Pol»)
- Modify: `render.html` (LIFT: `base` замість `bowl`+`puck`, `bay_ring` між основою й плафоном; пікер — «Колір дімера», фарбує лише `dimmer`, ключ localStorage лишити; тексти «бетонна основа» замість «пастельна чаша»/«бетонна шайба»)
- Modify: `parts-3d.html` (якщо перелік деталей там явний)
- Modify: `parts.html` (lipo: кількість 4, «≈3400 мА·год: два стоси по 2»; нові рядки: латунні вставки M3×5.7 ×4, гвинти M3×8 потай ×4 (+запас), PETG для кільця; бетон — «основа одним виливком»)
- Modify: `assets/nets.js` (BT1: «4× Li-Pol 850 мА·год паралельно (1S)»)
- Modify: `wiring.html` (BT1 намальовано 4 комірки, два стоси по 2; підпис «4 × Li-Pol 60×20×8»)
- Modify: `docs/spec.md` (форма і габарити; таблиця деталей: основа, кільце, форма; електроніка: 4 комірки ≈3400 мА·год, заряд ≈2 год; мої рішення)

- [ ] **Step 1: Перевірка сторінок — має впасти**

Run: `grep -n "6×\|6 ×\|5100\|'bowl'\|bowl:\|puck:" assets/lamp3d.js render.html parts.html wiring.html assets/nets.js`
Expected: є збіги (старі тексти) — після кроку 2 мають зникнути, крім ключа localStorage `lamp-bowl-color`.

- [ ] **Step 2: Реалізувати зміни вище**, `bash tools/build.sh` (перегенерує `assets/models.js`).

- [ ] **Step 3: Перевірити в браузері** (на GitHub Pages після push, локальний сервер у цій сесії недоступний):
  - `render.html`: лампа зібрана, розбирається повзунком, основа бетонна, пікер фарбує дімер, у консолі без помилок;
  - `parts-3d.html`: нові деталі в списку, відкриваються;
  - `wiring.html`: самоперевірка мереж ОК;
  - `parts.html`: нові рядки є.

- [ ] **Step 4: Перегенерувати прев'ю** `case/preview_section.png`, `case/preview_assembly.png` (як раніше: `-D 'part="section"'` / `"assembly"` у PNG).

- [ ] **Step 5: Commit і публікація** — `сторінки під бетонну основу`; `git push origin lamp-build:main`, дочекатися `gh api repos/L1m0n/night-lamp/pages/builds/latest` = built.
