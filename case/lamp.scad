// Нічна лампа на акумуляторах: шейдер — форма lamp-0.1.1 (Fusion), зменшена ×0.7; бетонна основа, шасі з акумуляторами,
// восьмигранна колона зі стрічкою, дімер угорі.
//   openscad -D 'part="base"' -o base.stl lamp.scad      (усі деталі — tools/build.sh)
//   openscad -D 'part="assembly"' -D variant=2 -o a.png lamp.scad
// Усі деталі — в осі лампи: стіл z=5, низ шейдера z=15 (лампа на 10 мм над столом, ~175 мм від столу до верху).
// Шейдер = профіль lamp-export-1.step, масштаб 0.7 від дна шейдера (z=15); стінка лишається 2 мм.
// Найвища друкована деталь ≤ 180 (Bambu A1 mini). STL складаються у збірку без зсувів; друкувати — повернувши в слайсері.
// Розміри в мм. Значення з позначкою «заміряти» — номінальні, звір зі своїми деталями.
//
// Вигляд згори: +X — USB-C у боці основи, ±Y — акумулятори, −X — ESP32 (стоїть ребром).

part    = "assembly";  // shade_top, base, bay_ring, puck_core, chassis, reflector, column, knob_v1_carriage,
                       // knob_v1_guide, knob_v2_cap, dimmer, batteries, pcb, pot_v1, pot_v2, assembly, section
variant = 2;           // вузол дімера для assembly/section: 1 — B100K з кнопкою, 2 — RK097NS з вимикачем

/* [Шейдер: lamp-0.1.1 × 0.7 від z=15] */
S        = 0.7;
function sz(z) = 15 + (z - 15) * S;   // висота зі STEP → модель
ring_z   = 15;                // дно-кільце шейдера (r 28…38.5); стіл на z=5
fil_c    = [55 * S, sz(40)];  // центр заокруглення
fil_r    = 25 * S;
belt_r   = 80 * S;            // пояс
belt_z   = sz(50);            // верх поясу
cone_top = [70.0227 * S, sz(249.675)];  // кінець конуса, далі заокруглення 0.5
top_z    = sz(250.15);
wall     = 2;
top_wall = 1.2;   // стінка плафона: 2 лінії по 0.6 — швидше друк і більше світла крізь матовий PLA
plate_z  = [174.43, 176.43];  // верхня пластина 2 мм; опущена на 0.75, щоб дімер 2.5 мм став урівень
plate_hole_d = 20;
recess_r = 67.5 * S;          // заглиблення під дімер
collar   = [40 * S, 42 * S, 17];  // комір під ніжку: r внутрішній, r зовнішній, z центру заокруглення R2

/* [Байонет] */
lap      = 5;     // напуск плафона в основу
lap_fit  = 0.2;
lap_t    = 1.6;   // товщина манжети плафона
ring_t   = 2.6;   // радіальна товщина байонетного кільця (висота — lap); 2.6 — щоб стінка за пазом лишилась ≥ 1.2 при ring_fit = 0.3
tab_t    = 2.4;   // вушко кільця під кільцем: висота
bay      = [10, 2, 1.0]; // ламель: по дузі, по висоті, радіально
bay_n    = 4;
bay_turn = 30;    // поворот байонета
bay_ramp = 0.6;   // на скільки стеля паза опускається за поворот
bay_pre  = 0.05;   // натяг: у кінці повороту стеля тисне на ламель
bay_rim  = 1.0;   // бортик над стелею паза на вході
bay_fit  = 0.2;
bump_sq  = 0.15;  // стиск ламелі на горбику понад зазор паза — налаштувати після пробного друку
bump_clr = 0.1;   // зазор між піднятим низом ламелі й вершиною горбика
bump_h   = 2 * bay_fit + bump_sq;   // висота горбика над дном паза (зазор паза 2·bay_fit)
bay_foot = 1.5;   // «п'ятка» ламелі (задній край, градуси) — єдина частина, що доходить до горбика; решта знизу виїмчаста
bay_lock = 1.5;   // горбик закінчується за стільки градусів до заднього краю ламелі в замкненому положенні
bump_fl  = 2;     // похилий бік горбика, градуси по дузі

/* [Форма для відливки (друкується)] */
mold_t      = 3;     // стінка форми
mold_flange = 8;     // фланці на стику половин (болти M3)
mold_bolt_d = 4;
mold_cw     = 2;     // стінка порожнистого сердечника
mold_cf     = 3;     // бортик сердечника зверху
mold_pin_d  = 2.5;   // штир під латунну вставку
mold_fit    = 0.1;   // зазор гнізда зенківки USB-C у стінці форми і гнізда каналу в сердечнику
mold_vent_d = 4;     // випуски повітря/надлишку в бортику (над стінкою основи)
mold_fin_t  = 4;     // товщина фланця-плавника кожної половини
mold_vent2_d = 2.8;  // випуски повітря крізь дно сердечника і стелі пазів
mold_pin_h  = 2.5;   // установчі штирі на стику половин
mold_skirt  = 2;     // спідниця бортика: центрує сердечник по зовнішньому краю форми

/* [Основа: бетонна відливка] */
base_wall = 5;             // стінка бетонної основи
draft     = 1;             // ухил внутрішньої порожнини, градуси: сердечник виймається вгору
pad       = [9.2, 7];      // ребро: радіально (вставка M3 лежить у відкритому отворі кільця), по висоті
pad_a     = [0, 90, 180, 270];
pad_half  = 8;             // ребро: півширина по дузі, градуси
notch_a   = pad_half + 1;  // виїмка шасі під ребро: півширина, градуси
insert    = [4.6, 5.7];    // латунна вставка: OD, довжина
insert_heat_d = 4.0;      // отвір під вплавлення тієї ж вставки паяльником (пробна пластикова чаша)
screw_len = 6;             // гвинт кільця M3×L з потайною головкою
ring_fit  = 0.3;           // зазор кільця й вушок до бетону (радіально) — налаштувати після пробного друку, за потреби підшліфувати зовнішню грань кільця
esp_slot_pad = 0.6;          // відбивач: запас навколо ESP32 у проріз (0.3 зазор + 0.3 люфт шасі/колони)

puck_fit = 0.25;           // зазор у комірі (у STEP ніжка Ø80 у коміра Ø80 впритул)
puck_d   = 2 * collar[0] - 2 * puck_fit;
puck_z   = [5, collar.z];
ip5306   = [21, 25, 1.2];  // ширина (край з USB-C), довжина, товщина плати — заміряти
pm_fit   = 0.3;
usb_z    = 10;             // центр гнізда USB-C: 5 мм над столом
usb_below = 1.6;           // плата лежить компонентами донизу: центр гнізда під її нижньою стороною — заміряти
usb_sock = [7.5, 9, 3.2];  // гніздо USB-C: глибина, ширина, висота — заміряти
usb_over = 0.2;            // на скільки гніздо виступає за край плати — заміряти
plug     = [12.4, 6.6];    // литий корпус штекера: ширина, висота
plug_fit = 0.2;            // зазор навколо корпусу штекера в зенківці
chan_d   = 8;              // канал під дроти вгору, виходить усередину колони
chan_x   = -6.5;            // з того боку осі, де немає плати IP5306

/* [Шасі] */
chassis_d   = 91;
chassis_fit = 0.2;
chassis_t   = 3;
cell        = [60, 20, 8];   // Li-Pol 850 мА·год з PCM і двостороннім скотчем — заміряно
layers      = 2;             // два стоси по 2 = 4 комірки (≈3400 мА·год)
bat_tol     = 0.5;
pocket_wall = [1.2, 5];      // стінка навколо стосів акумуляторів: товщина, висота
esp  = [22.5, 18, 1.2];      // ESP32-C3 SuperMini — заміряти
rail = [1.2, 3];             // напрямні під плати: товщина, висота
groove = [6, 1.5];           // жолоб під дроти з колони до ESP32 (під акумуляторами)
cup_depth = 8;
cup_wall  = 2;
col_fit   = 0.2;

/* [Колона] */
col_face = 12.5;   // грань восьмигранника
col_top  = plate_z[0] - 0.5;   // до самої пластини плафона: вузол дімера з кнопкою всередині колони
key      = [1.5, 2.5];        // ребро в порожнині (від повороту вкладиша) і полички під вкладиш: радіально, по дузі
col_bore = 22;
slot     = [6, 6];   // паз на нижньому торці: шини й дані з шасі в колону
strip_z0  = 42.8;             // низ смуги (кінець з падами); нижні отвори під відбивачем, перший LED над ним
leds      = 6;                // LED на грань; 8 граней → 48
strip_len = leds * 1000 / 60;  // 100
strip_t   = 3;                // товщина смуги разом з LED і скотчем
strip_pcb = 1.5;              // кінець смуги без LED, з пайкою — стоїть між акумуляторами
pitch_led = 1000 / 60;
wire_d    = 3.5;              // отвори під дроти смуги: на кожній грані під і над смугою
wire_gap  = 0.5;              // від торця смуги до краю отвору

/* [Вузол дімера V1: B100K + KFC-003A] */
pot1_body  = [16, 7];      // корпус: діаметр, глибина від монтажної площини — заміряти
pot1_bush  = 7;            // довжина втулки M7 — заміряти
pot1_shaft = 15;           // вал від монтажної площини — заміряти
pot1_face  = 158.94;       // монтажна площина (низ пластини каретки) → верх втулки 165.94
sb         = [6.1, 3.6, 2.5];  // KFC-003A: ширина, глибина, висота разом зі штоком — заміряти
sb_stroke  = 0.25;         // хід штока — заміряти
v1_travel  = 0.4;          // хід каретки до упорів: шток 0.25 + запас, щоб не роздавити кнопку
guide_wall = 1.3;
fit        = 0.15;         // зазор ковзання/посадки

/* [Вузол дімера V2: RK097NS] */
pot2_body  = [10, 11, 12];    // корпус разом з вимикачем: ширина, довжина, глибина (заміряно)
pot2_bush  = 5;               // довжина втулки M7 (заміряно)
pot2_shaft = 15;              // вал від монтажної площини (заміряно)
pot2_lock  = pot2_body.z / 2; // глибина гнізда: напрямні на пів корпусу
pot2_turn  = 112.5;           // бік із ніжками (-Y корпусу) дивиться на паз ключа (22.5°), стінка — навпроти
bush_top   = 165.44;          // верх втулки
bush_hole  = 7.2;

/* [Дімер: lamp-0.1.1 × 0.7; товщина 2.5 і хвостовик — без масштабу] */
dim_r    = 66.5 * S;
dim_z    = [sz(250.19) - 2.5, sz(250.19)];
grip_n   = 4;     // планок-хрестом на верхній грані дімера
grip_w   = 3;     // ширина планки біля основи
grip_h   = 1.0;   // висота над диском
grip_gap = 5;     // відступ планки від центру і від краю
boss     = [9, dim_z[0] - 10];   // хвостовик: радіус, низ
shaft_d  = 6.0;               // рифлений вал (заміряно на RK097)
shaft_press = 0.1;            // натяг
shaft_hole  = 9;              // глибина отвору від низу хвостовика

$fn = 180;

// --- похідні розміри ---
k        = (belt_r - cone_top.x) / (cone_top.y - belt_z);    // нахил конуса dr/dz
function off_r(z, w) = z < fil_c.y ? fil_c.x + sqrt(max(0, pow(fil_r - w, 2) - pow(fil_c.y - z, 2)))  // радіус контуру, відступленого всередину на w по нормалі
                 : z <= belt_z ? belt_r - w : belt_r - w * sqrt(1 + k * k) - k * (z - belt_z);
function in_r(z) = off_r(z, wall);
col_flat  = col_face / (2 * tan(22.5));  // половина розміру під ключ
deck_z    = 26.5;                        // верх диска шасі: кут нижньої комірки ≥26.2 (заокруглення дна), верх верхньої ≤26.9 (кільце)
chassis_z = deck_z - chassis_t;          // шасі лежить на бетонному дні
bat_top   = deck_z + layers * cell.z;
refl_z    = bat_top;                     // відбивач лежить на акумуляторах
cut_z     = 48.2;                         // верх основи / шов з плафоном (відбивач на 1 мм нижче)
ring_z0   = cut_z - lap;                  // низ байонетного кільця
rib_top   = ring_z0 - tab_t;              // верх ребер: на них лягають вушка кільця
floor_z   = chassis_z;                    // верх бетонного дна
bat_y0    = col_flat + col_fit + cup_wall + bat_tol;  // акумулятори двома стосами по боках колони (±Y), впритул до стакана
bat_corner = norm([cell.x / 2 + bat_tol, bat_y0 + cell.y + bat_tol]);
cav_r_top = off_r(cut_z, base_wall);
pocket_r  = cav_r(deck_z) - 0.3;
esp_x     = -(cell.x / 2 + bat_tol + pocket_wall[0] + 3 + esp.z / 2);  // ESP32 ребром за торцем акумуляторів
pm_top    = usb_z + usb_below + ip5306.z;                   // стеля кишені = спина плати
usb_hole  = plug + [2, 2] * plug_fit;                       // зенківка під корпус штекера
pm_x1     = sqrt(pow(puck_d / 2 - 1.2, 2) - pow(ip5306.x / 2 + pm_fit, 2)) - pm_fit;  // край плати з USB-C: кути кишені ≥1.2 від боку ніжки
sock_front = pm_x1 + usb_over;                             // торець гнізда USB-C
win_x0    = sock_front - 0.5;                              // дно зенківки: трохи за торцем гнізда
// кільце сидить у бетоні зазором ring_fit по мінімальному радіусу порожнини (без ухилу): так просто й стінка за пазом не тонша
ring_r    = [cav_r(cut_z) - ring_t, cav_r(ring_z0) - ring_fit];             // внутрішній, зовнішній
sleeve_r  = ring_r[0] - lap_fit;                            // зовнішній радіус манжети
refl      = [floor(2 * (min(sleeve_r - lap_t, cav_r(refl_z)) - 0.3) * 2) / 2, 1.2];  // білий відбивач: під манжету і під стінку основи (він нижче кільця), вниз до 0.5
refl_notch_r = rib_r(rib_top) - 0.3;     // виїмки відбивача під вушка кільця (вони внизу стирчать далі за ребро, але rib_r росте вгору)
bay_a     = bay.x / sleeve_r * 180 / PI;                    // ламель по дузі, градуси
bay_s     = 2 * bay_fit / sleeve_r * 180 / PI;              // зазор входу по дузі з кожного боку, градуси
bay_hg    = bay.y + 2 * bay_fit;                            // висота паза
bay_c0    = cut_z - bay_rim;                                // стеля паза на вході
bay_m     = bay_ramp / bay_turn;                            // спад стелі, мм на градус
bay_top   = bay_c0 - bay_ramp + bay_pre;                    // верх ламелі на її початку (стеля в кінці повороту тисне на bay_pre)
bump_b1   = bay_turn - bay_lock;                            // горбик по дузі кільця: від bump_b0 до bump_b1
bump_b0   = bump_b1 - 2 * bump_fl;
bay_end   = bay_a + bay_turn;                               // кінець паза по дузі
bay_r1    = sleeve_r + bay.z + bay_fit;                     // зовнішній радіус паза
tab_in    = rib_r(rib_top);                                 // вушко: від грані ребра
tab_out   = cav_r(rib_top) - ring_fit;                           // до стінки основи
hole_r    = ring_r[0] - 6.5 / 2 - 0.12;                     // вісь вставки/гвинта: голівка (cs[1] = 6.5) цілком в отворі кільця, доступна зверху
cs        = [3.4, 6.5, 0.2];                                // отвір, зенківка 90°, піднесення манжети над головкою
bore      = col_bore - 2 * fit - 2 * guide_wall;            // отвір напрямної V1
carr_d    = bore - 2 * fit;
sb_base   = pot1_face - pot1_body.y - 1 - sb.z;             // кнопка стоїть на дні напрямної
guide_z0  = sb_base - 1.5;
pot2_face = bush_top - pot2_bush;
v1_bush   = pot1_face + pot1_bush;
node_top  = max(v1_bush, bush_top);
strip_z1  = strip_z0 + strip_len;
wire_z    = [strip_z0 - wire_gap - wire_d / 2, strip_z1 + wire_gap + wire_d / 2];  // центри отворів
node_z0   = guide_z0;                     // вкладиш вузла дімера (V1 і V2) стоїть на поличках колони на цій висоті
guide_top = pot1_face + 2;

function rib_r(z) = cav_r(z) - pad.x;  // внутрішня грань ребра: йде за ухилом, тож сердечник виймається
function cav_r(z) = min(off_r(z, base_wall), cav_r_top - tan(draft) * (cut_z - z));  // порожнина основи з ухилом

notch_r   = rib_r(chassis_z) - 0.3;      // виїмка шасі під ребро: чиста від грані ребра внизу, де вона найближча до осі
echo(str("Шасі: notch_r = ", notch_r, ", refl[0] = ", refl[0], " | Порожнина основи: cav_r(", deck_z, ") = ", cav_r(deck_z), ", кут комірки ", bat_corner, ", верх комірок ", bat_top, " (кільце ", ring_z0, ")"));
echo(str("Вал у хвостовику: V1 ", pot1_face + pot1_shaft - boss[1], ", V2 ", pot2_face + pot2_shaft - boss[1]));

for (z = [floor_z : 0.5 : cut_z - 0.5]) assert(cav_r(z + 0.5) >= cav_r(z) - 1e-6, "порожнина основи має піднутрення: сердечник не вийде");
for (z = [floor_z : 0.5 : cut_z - 0.5]) assert(rib_r(z + 0.5) >= rib_r(z) - 1e-6, "ребро під вставку має піднутрення: сердечник не вийде");
// нормальна товщина стінки (до зовнішнього контуру) вздовж порожнини; нижче z=20 стінку тримає суцільне дно
function wall_n(z) = z < fil_c.y ? fil_r - norm([cav_r(z) - fil_c.x, z - fil_c.y])
                   : z <= belt_z ? belt_r - cav_r(z) : (belt_r - k * (z - belt_z) - cav_r(z)) / sqrt(1 + k * k);
// вікно акумуляторів: кут нижньої комірки під заокругленням, верх під кільцем, шасі й комірки повз ребра
assert(bat_corner + 0.3 <= cav_r(deck_z), "кут нижньої комірки впирається в заокруглення дна основи");
assert(bat_top + 0.3 <= ring_z0, "верхня комірка зачіпає байонетне кільце");
assert(chassis_d / 2 + chassis_fit <= cav_r(chassis_z), "шасі не лягає на дно основи");
// виїмки шасі й відбивача (notch_r, refl_notch_r) виведені з rib_r у найвужчому місці (rib_r не спадає вгору), тож лишається перевірити запас по дузі
assert((notch_a - pad_half) * PI / 180 * notch_r >= 0.3, "виїмка шасі вужча за ребро: запас по дузі < 0.3");
assert(refl[0] / 2 + 0.3 <= cav_r(refl_z), "відбивач упирається в стінку основи");
assert(tab_in - refl_notch_r >= 0.3 - 1e-6 && (notch_a - pad_half) * PI / 180 * tab_in >= 0.3, "виїмка відбивача не чиста від вушка кільця: радіально чи по дузі < 0.3");   // вушко (rib_top…+tab_t) — справжній сусід відбивача, ребра на цій висоті немає
assert(refl[0] / 2 + 0.3 <= sleeve_r - lap_t, "відбивач не влазить у манжету плафона");
// ESP32 стоїть від deck_z до deck_z + esp.y і проходить крізь шар відбивача (refl_z…+refl[1]): потрібен проріз із запасом 0.3
assert(refl_z >= deck_z + esp.y + 0.3 || esp_slot_pad >= 0.3, "ESP32 проходить крізь відбивач: потрібен проріз із запасом ≥ 0.3");
// стос (з рамкою) і ESP32 — під внутрішньою гранню ребра на 90°/270° та 180°; rib_r росте вгору, тож мінімум на deck_z
assert(norm([(bat_y0 + cell.y + bat_tol + pocket_wall[0]) * tan(pad_half), bat_y0 + cell.y + bat_tol + pocket_wall[0]]) + 0.3 <= rib_r(deck_z), "стос акумуляторів зачіпає ребро на 90°/270°");
assert(-esp_x + esp.z / 2 + 3 + 0.3 <= rib_r(deck_z), "ESP32 з деталями зачіпає ребро на 180°");
// z<20 — кут на суцільному фундаменті (нормальна стінка 4→5), перевіряємо від початку дуги зсуву
assert(puck_z[1] < floor_z + 1, "канал під дроти не доходить до порожнини основи");
for (z = [fil_c.y - fil_r + base_wall : 0.5 : cut_z]) assert(wall_n(z) >= base_wall - 0.2, "стінка основи тонша за base_wall");
assert(pm_top + 3 <= floor_z, "бетон над кишенею IP5306 тонший за 3 мм");
assert(norm([-esp_x + esp.z / 2 + 3, esp.x / 2]) < pocket_r, "ESP32 з деталями впирається в стінку основи");
assert(top_z - (cut_z - lap) <= 180 && cut_z - ring_z <= 180, "деталь шейдера вища за стіл принтера");
assert(node_top < col_top && col_top < plate_z[0] - 0.3, "вузол дімера має бути в колоні, а колона — під пластиною");
assert(boss[0] + 0.4 < col_bore / 2 - key[0], "хвостовик дімера зачіпає ребро в колоні");
assert(pot1_face + pot1_shaft - boss[1] >= 6, "вал V1 заходить у хвостовик дімера менше ніж на 6 мм");
assert(pot2_face + pot2_shaft - boss[1] >= 6, "вал V2 заходить у хвостовик дімера менше ніж на 6 мм");
assert(boss[1] + shaft_hole > max(pot1_face + pot1_shaft, pot2_face + pot2_shaft) + 0.5, "вал упирається в дно отвору дімера");
assert(boss[1] - node_top > v1_travel + 0.3, "втулка торкається хвостовика дімера");
assert(col_flat + col_fit + cup_wall <= (cell.x - cell.y) / 2, "стакан колони не влазить у центр між стосами");
assert(v1_travel > sb_stroke && v1_travel < dim_z[0] - plate_z[1], "хід каретки V1: має натиснути кнопку і не впертися дімером у плафон");
assert(wire_z[0] + wire_d / 2 < strip_z0 && wire_z[1] - wire_d / 2 > strip_z1, "отвір під дроти заходить під смугу");
assert(wire_z[0] - wire_d / 2 > deck_z + cup_depth, "нижній отвір під дроти схований у стакані шасі");
assert(wire_z[1] + wire_d / 2 < node_z0 && node_z0 <= col_top, "верхній отвір під дроти впирається у вузол дімера або виходить за колону");
assert((cell.x - cell.y) / 2 - col_flat >= strip_pcb, "кінець смуги з пайкою не влазить між колоною й акумуляторами");
assert(strip_z0 + pitch_led / 2 - 2.5 > refl_z + refl[1], "перший LED під відбивачем");
assert(abs(chan_x) + chan_d / 2 < col_bore / 2, "канал з ніжки має виходити всередину колони");
assert(pm_x1 - ip5306.y > chan_x + chan_d / 2 + 1, "плата IP5306 налазить на канал під дроти");
assert(norm([pm_x1 + pm_fit, ip5306.x / 2 + pm_fit]) < puck_d / 2 - 1, "кишеня IP5306 прориває бік ніжки");
assert(win_x0 <= sock_front && win_x0 >= sock_front - 0.5, "дно зенківки USB-C має бути в межах 0.5 мм від торця гнізда");
assert(pm_x1 <= sock_front, "плата IP5306 заходить у шлях штекера");
assert(usb_hole.x >= plug.x + 0.3 && usb_hole.y >= plug.y + 0.3, "корпус штекера не проходить у зенківку");
assert(usb_z - usb_hole.y / 2 < puck_z[0] + 3, "під зенківкою USB-C лишилась би бетонна смужка < 3 мм — зенківка має бути відкрита донизу");
assert(usb_sock.y < usb_hole.x && usb_sock.z < usb_hole.y, "гніздо більше за зенківку");
top_in = in_r(cut_z + 1) + wall - top_wall;  // внутрішній радіус плафона над швом (наближено, конус майже вертикальний)
assert(top_wall / 2 < top_wall - 0.5, "стінка плафона < 1 мм: кільце зрощення з манжетою не заходить у неї");
assert(ring_t - (bay.z + bay_fit) >= 1.2, "стінка кільця за пазом < 1.2");
assert(ring_r[1] - bay_r1 >= 1.2, "справжня стінка кільця за пазом < 1.2");
assert(bay_ramp + bay.y + 2 * bay_fit + bump_h < lap - 1, "паз зі скосом не вміщується у висоту кільця");
assert(bay_n * (bay_end + bay_s + 2) < 360, "пази 4 ламелей перекриваються");
// справжня вертикаль паза: бортик зверху, спад стелі вздовж ламелі, нижній бортик
assert(bay_c0 - bay_m * bay_end - bay_hg - ring_z0 >= 0.7, "під пазом менше 0.7 мм кільця");
assert(bay_top - bay.y - bay_m * bay_a > cut_z - lap, "ламель зісковзує нижче манжети");
assert(ring_r[0] >= norm([-esp_x + esp.z / 2 + 3, esp.x / 2]) + 0.3, "кільце зачіпає ESP32");
// вушка: від грані ребра до стінки, під кільцем; зенківка в них, зазори до акумуляторів, ESP32 і виїмок
assert(tab_t - cs[2] >= (cs[1] - cs[0]) / 2, "вушко тонше за зенківку");
// гвинт: голівка врівень з низом кільця (зенківка), кінчик не дійшов до дна отвору вставки і в різьбі вставки ≥ 3 мм
screw_tip = ring_z0 - cs[2] - screw_len;
assert(screw_tip >= rib_top - insert[1] + 0.5, "гвинт кільця впирається в дно отвору вставки");
assert(rib_top - screw_tip >= 3, "гвинт кільця заходить у вставку менше ніж на 3 мм різьби");
assert(hole_r + cs[1] / 2 + 0.1 <= ring_r[0], "головка гвинта під кільцем: недоступна зверху");
assert(hole_r - insert[0] / 2 - rib_r(rib_top) >= 1.0 && cav_r(rib_top) - hole_r - insert[0] / 2 >= 1.0, "бетону навколо вставки < 1.0 мм");
assert(bump_sq - bay_pre >= 0.05, "стиск на горбику не більший за натяг у кінці: клацу не буде");
assert(abs(bump_b1 - (bay_turn - bay_lock)) < 1e-9 && bump_b0 > bay_a + bay_s, "горбик має бути виведений з bay_turn і лежати за входом");
assert(atan(bump_h / (bump_fl * PI / 180 * ring_r[0])) <= 30, "похилий бік горбика крутіший за 30°");
assert(bay_lock * PI / 180 * ring_r[0] >= 1, "у замку п'ятка ламелі ближче 1 мм до горбика");
assert(bay_foot > 0 && bay_foot < bay_a && bay.y - bump_h - bump_clr >= 1, "п'ятка/виїмка ламелі некоректні");
assert(tab_t - cs[2] - (cs[1] - cs[0]) / 2 >= 0.6, "під зенківкою вушка лишається менше 0.6 мм");
assert(tab_in <= hole_r - cs[1] / 2 - 0.1 && hole_r + cs[1] / 2 <= tab_out, "зенківка виходить за вушко");
assert((notch_a - pad_half) * PI / 180 * tab_in >= 0.3, "вушко ближче 0.3 до виїмки по дузі");
assert(tab_in >= norm([(bat_y0 + cell.y + bat_tol + pocket_wall[0]) * tan(pad_half), bat_y0 + cell.y + bat_tol + pocket_wall[0]]) + 0.3, "вушко зачіпає акумулятори");
assert(tab_in >= -esp_x + esp.z / 2 + 3 + 0.3, "вушко зачіпає ESP32");

// --- шейдер ---
function arc(c, r, a0, a1, n = 30) = [for (i = [0:n]) c + r * [cos(a0 + (a1 - a0) * i / n), sin(a0 + (a1 - a0) * i / n)]];

module shade_envelope() {  // усе, що обмежує зовнішня поверхня, до осі
  polygon(concat([[0, ring_z]], arc(fil_c, fil_r, -90, 0), [[belt_r, belt_z]],
                 arc([cone_top.x - 0.5 * cos(atan(k)), top_z - 0.5], 0.5, atan(k), 90), [[0, top_z]]));
}

module shade_profile(w = wall) {
  difference() {
    union() {
      difference() {
        shade_envelope();
        offset(r = -w) union() { shade_envelope(); mirror([1, 0]) shade_envelope(); }  // стінка і дно
      }
      intersection() { shade_envelope(); translate([0, plate_z[0]]) square([belt_r, top_z]); }  // пластина
      translate([collar[0], ring_z]) square([collar[1] - collar[0], collar.z - ring_z]);       // комір
      intersection() { translate([collar[0], collar.z]) circle(r = 2, $fn = 48); translate([collar[0], 0]) square(100); }
    }
    translate([-1, ring_z - 1]) square([collar[0] + 1, collar.z]);   // середина відкрита під ніжку
    translate([-1, plate_z[1]]) square([recess_r + 1, 10]);          // заглиблення під дімер
    translate([-1, 0]) square([plate_hole_d / 2 + 1, 300]);          // отвір Ø20
  }
}

module shade() { rotate_extrude() shade_profile(); }

module zslab(z0, z1) { translate([-200, -200, z0]) cube([400, 400, z1 - z0]); }

module arc_ring(r0, r1, z0, h, a0, a1) {
  rotate(a0) translate([0, 0, z0]) rotate_extrude(angle = a1 - a0) translate([r0, 0]) square([r1 - r0, h]);
}

module shade_top() {
  intersection() { rotate_extrude() shade_profile(top_wall); zslab(cut_z, 300); }
  // манжета: заходить в основу на lap мм; над нею пласка полиця до стінки — тієї ж товщини, що й стінка
  // (при друці догори дриґом полиця висить ~8 мм усередину: під неї потрібна підтримка)
  difference() {
    union() {
      translate([0, 0, cut_z - lap]) cylinder(r = sleeve_r, h = lap + 0.01);
      translate([0, 0, cut_z]) cylinder(r = top_in + top_wall / 2, h = top_wall);
    }
    translate([0, 0, cut_z - lap - 1]) cylinder(r = sleeve_r - lap_t, h = lap + top_wall + 2);
  }
  // ламелі: верх і низ спадають уздовж дуги, як стеля паза (гвинтова поверхня того ж кроку)
  for (i = [0:bay_n - 1]) rotate(i * 360 / bay_n) {
    ramp_arc(sleeve_r - 0.5, sleeve_r + bay.z, 0, bay_foot, bay_top - bay.y, bay.y, 3);   // п'ятка: повна висота
    ramp_arc(sleeve_r - 0.5, sleeve_r + bay.z, bay_foot - 0.3, bay_a, bay_top - bay.y - bay_m * bay_foot + bump_h + bump_clr, bay.y - bump_h - bump_clr, 3);   // решта: низ піднято на висоту горбика й зазор над його вершиною
  }
}

// дуга a0…a1 висотою h, низ якої спадає на bay_m мм на градус від z0 (кроками step°; hull двох тонких зрізів на крок)
module ramp_arc(r0, r1, a0, a1, z0, h, step = 2) {
  for (a = [a0 : step : a1 - 0.001]) let(b = min(a + step + 0.3, a1)) hull() {  // +0.3°: сусідні сегменти перекриваються, а не торкаються гранями
    arc_ring(r0, r1, z0 - bay_m * (a - a0), h, a, a + 0.01);
    arc_ring(r0, r1, z0 - bay_m * (b - a0), h, b - 0.01, b);
  }
}

// --- байонетне кільце: лежить у бетоні під краєм, вушками на ребрах, 4 Г-пази зі скосом ---
module bay_groove() {  // у координатах кільця; ламель входить зверху на 0…bay_a, далі йде по θ до bay_end
  ramp_arc(ring_r[0] - 0.01, bay_r1, 0, bay_end, bay_c0 - bay_hg, bay_hg, 2);                                  // стеля спадає, паз тієї ж висоти
  translate([0, 0, bay_c0 - bay_m * (bay_a + bay_s) - bay_hg]) arc_ring(ring_r[0] - 0.01, bay_r1, 0, cut_z + 1 - (bay_c0 - bay_m * (bay_a + bay_s) - bay_hg), -bay_s, bay_a + bay_s);  // вертикальний вхід
}

module bay_bump() {  // горбик на дні перед кінцем повороту: ламель перескакує його з клацом
  // гострий горбик з похилими боками, лише на останніх градусах перед замком: його перетинає тільки «п'ятка» ламелі
  // один hull трьох тонких зрізів (початок, вершина, кінець): трикутник над похилим дном опуклий, тож це рівно горбик, без швів між схилами
  hull() for (q = [[bump_b0, 0], [bump_b0 + bump_fl, bump_h], [bump_b1, 0]])
    arc_ring(ring_r[0] - 0.01, bay_r1, bay_c0 - bay_hg - bay_m * q[0] - 0.01, q[1] + 0.01, q[0] - 0.005, q[0] + 0.005);
}

module bay_tab() {  // на 0°: вушко під кільцем від грані ребра до стінки; зверху врівень з низом кільця, але над манжетою — виїмка
  difference() {
    rotate(-pad_half) rotate_extrude(angle = 2 * pad_half) translate([tab_in, rib_top]) square([tab_out - tab_in, tab_t + 0.01]);
    translate([0, 0, ring_z0 - cs[2]]) cylinder(r = ring_r[0], h = 1);   // манжета плафона стоїть над вушком із зазором
    translate([hole_r, 0, ring_z0 - cs[2] - (cs[1] - cs[0]) / 2]) cylinder(d1 = cs[0], d2 = cs[1], h = (cs[1] - cs[0]) / 2 + 0.001, $fn = 48);  // зенківка 90°
    translate([hole_r, 0, rib_top - 1]) cylinder(d = cs[0], h = tab_t + 2, $fn = 48);
    translate([hole_r, 0, ring_z0 - cs[2]]) cylinder(d = cs[1], h = 1, $fn = 48);   // головка під кільцем у товщі вушка
  }
}

module bay_ring() {  // друк: перевернутим (верхній торець на стіл) — у робочому положенні низ кільця висить над столом через вушка
  difference() {
    rotate_extrude() translate([ring_r[0], ring_z0]) square([ring_r[1] - ring_r[0], lap]);
    for (i = [0:bay_n - 1]) rotate(i * 360 / bay_n) difference() { bay_groove(); bay_bump(); }
  }
  for (a = pad_a) rotate(a) bay_tab();
}

// --- основа: бетонна відливка (стінка 5, порожнина з ухилом) ---
// зенківка USB-C: бічні стінки радіальні, щоб на виході в круглий бік ніжки бетон мав прямий кут, а не клин ~13°
module usb_wedge(x1, z0, z1, g = 0) {
  k = (usb_hole.x / 2 + g) / win_x0;
  translate([0, 0, z0]) linear_extrude(z1 - z0) polygon([[win_x0, -k * win_x0], [x1, -k * x1], [x1, k * x1], [win_x0, k * win_x0]]);
}

module puck_void() {
  translate([chan_x - chan_d / 2, -ip5306.x / 2 - pm_fit, puck_z[0] - 1]) cube([pm_x1 + pm_fit - chan_x + chan_d / 2, ip5306.x + 2 * pm_fit, pm_top - puck_z[0] + 1]);
  // зенківка від торця гнізда назовні: корпус штекера заходить до торця, гніздо стоїть глибше за бік ніжки
  // відкрита донизу: бетонна смужка під нею (1.5 мм) відколювалась би
  usb_wedge(puck_d / 2 + 1, puck_z[0] - 1, usb_z + usb_hole.y / 2);
  translate([chan_x, 0, puck_z[0]]) cylinder(d = chan_d, h = puck_z[1] - puck_z[0] + 1, $fn = 48);
}

module base_void() {
  rotate_extrude() polygon(concat([[0, floor_z]], [for (z = [floor_z : 1 : cut_z]) [cav_r(z), z]], [[cav_r(cut_z), cut_z + 1], [0, cut_z + 1]]));
  puck_void();
  translate([chan_x, 0, puck_z[1]]) cylinder(d = chan_d, h = floor_z + 1 - puck_z[1], $fn = 48);  // канал крізь дно (puck_void кінчається на puck_z[1]+1) в порожнину
}

module rib(a, g = 0) {  // ребро (пілястра) від дна до верху п'ятачка: ±pad_half, внутрішня грань за ухилом; g > 0 — роздуте на g (стінка сердечника навколо паза)
  rotate(a - pad_half - g * 180 / PI / rib_r(floor_z)) rotate_extrude(angle = 2 * (pad_half + g * 180 / PI / rib_r(floor_z)))
    polygon(concat([for (z = [floor_z : 1 : rib_top - 0.01]) [rib_r(z) - g, z]], [[rib_r(rib_top) - g, rib_top]], g > 0 ? [[rib_r(rib_top) - g, rib_top + g], [cav_r(rib_top) + 1, rib_top + g]] : [], [[cav_r(rib_top) + 1, rib_top]], [for (z = [floor_z + floor(rib_top - 0.01 - floor_z) : -1 : floor_z]) [cav_r(z) + 1, z]]));  // зовнішня межа — у тих самих z, що й порожнина (від floor_z): інакше біля підлоги лишається клин порожнини між ребром і стінкою
}

module insert_holes(d = insert[0], extra = 0) {  // extra — запас глибини під пластик, витіснений при вплавленні
  for (a = pad_a) rotate(a) translate([hole_r, 0, rib_top - insert[1] - extra]) cylinder(d = d, h = insert[1] + extra + 1, $fn = 48);
}

module base(plastic = false) {  // plastic — пробна пластикова чаша: отвори під вплавлення вставок замість заливки в бетон
  difference() {
    union() {
      intersection() { rotate_extrude() shade_envelope(); zslab(0, cut_z); }
      translate([0, 0, puck_z[0]]) cylinder(d = puck_d, h = ring_z - puck_z[0] + 1);  // під кільцем-дном шейдера суцільний бетон
    }
    difference() { base_void(); for (a = pad_a) rib(a); }
    if (plastic) insert_holes(insert_heat_d, 1); else insert_holes();
  }
}

module usb_core() {   // зенківка USB-C: стоїть у гнізді стінки форми; виймається вбік +X, коли puck_core уже вийнятий
  usb_wedge(pc_reach, puck_z[0], usb_z + usb_hole.y / 2);
}

module puck_core() {  // вкладиш: кишеня IP5306 + канал (плата клеїться спиною до стелі кишені); виймається вниз крізь низ основи
  difference() {
    union() {
      intersection() { puck_void(); translate([0, 0, puck_z[0]]) cylinder(d = puck_d + 2, h = puck_z[1] - puck_z[0]); }
      translate([chan_x, 0, puck_z[1] - 0.5]) cylinder(d = chan_d, h = floor_z + 1 - puck_z[1] + 0.5, $fn = 48);  // канал доходить до сердечника: входить у його гніздо над дном порожнини
    }
    usb_core();
  }
}

// --- форма для відливки ---
// Порядок. Підготовка: воском/мастилом змастити всі поверхні форми і штирі, віск у різьбу латунних вставок, вставки надіти на штирі.
// Складання: половини форми стягнути болтами M3 (фланці, нижня пара + 4), у форму поставити puck_core і usb_core (кінчик у гнізді стінки).
// Заливка: бетон до рівня краю, повільно опустити сердечник (канал puck_core входить у його гніздо), прикрутити бортик M3 до фланців форми, вібрувати.
// Розпалубка: відкрутити сердечник і підняти його вгору (штирі виходять з вставок); відкрутити болти й розвести половини вздовж ±Y;
// виштовхнути puck_core вниз крізь низ основи; витягти usb_core вбік +X.
// Після розпалубки: збити стовпчики від випусків — рівно з поверхнею на дні порожнини (там сідає шасі) і на верхах ребер (там сідають вушка кільця).
// Друк: зовнішні половини зовнішньою гранню вниз, плавником вгору (установчі штирі виступають із площини рознім).
// --- форма для відливки: відкритий верх = край основи (там заливка і сердечник), низ основи (z=5) на дні форми ---
module base_outer_2d(top) {  // профіль зовнішньої поверхні основи (x ≥ 0), з ніжкою
  intersection() {
    union() { shade_envelope(); translate([0, puck_z[0]]) square([puck_d / 2, ring_z - puck_z[0] + 1]); }
    square([200, top]);
  }
}

module mold_2d(w) { intersection() { offset(delta = w) base_outer_2d(cut_z); translate([0, puck_z[0] - mold_t]) square([200, cut_z - puck_z[0] + mold_t]); } }

mold_tab_x = off_r(cut_z, 0) + mold_t + mold_flange / 2;      // болт бортика сердечника у верх фланця форми
mold_low_x = puck_d / 2 + mold_t + mold_flange - 3.5;         // нижня пара болтів у фланці ніжки, якнайдалі від стінки
mold_pin_z = 13;
mold_boss  = [7, 7, 12];   // бобишка під вставку бортика цілком у половині A (y ≥ 0): x (навколо вставки), y від площини рознім, висота вниз від краю
mold_tab_y = insert[0] / 2 + 1.2;   // вісь вставки: ≥ 1.2 мм стінки до площини рознім

module mold_outer(side) {   // side ±1: половина по y ≥ 0 / y ≤ 0, рознім площиною XZ
  difference() {
    union() {
      intersection() {
        rotate_extrude() mold_2d(mold_t);
        translate([-200, side > 0 ? 0 : -200, -1]) cube([400, 200, 300]);
      }
      // фланець на стику: пластина по контуру на mold_flange далі за стінку
      rotate([90, 0, 0]) translate([0, 0, side > 0 ? -mold_fin_t : 0]) linear_extrude(mold_fin_t) union() { mold_2d(mold_t + mold_flange); mirror([1, 0]) mold_2d(mold_t + mold_flange); }
      if (side > 0) for (sx = [-1, 1]) translate([sx * mold_tab_x - mold_boss.x / 2, 0, cut_z - mold_boss.z]) cube(mold_boss);   // бобишка під вставку M3 (бортик сердечника)
      for (sx = [-1, 1]) if (sx == side) translate([sx * mold_low_x, 0.01 * side, mold_pin_z]) rotate([90 * side, 0, 0]) cylinder(d = 3, h = mold_pin_h + 0.01, $fn = 32);   // установчий штир (в іншу половину)
    }
    rotate_extrude() base_outer_2d(cut_z + 1);                              // порожнина = зовнішня поверхня основи, зверху відкрита
    intersection() { usb_wedge(pc_reach, puck_z[0] - 0.01, usb_z + usb_hole.y / 2 + mold_fit, mold_fit); translate([pc_reach - 2, -50, 0]) cube([2, 100, 100]); }  // гніздо під кінчик usb_core (зенківка відкрита донизу — гніздо від підлоги форми)
    for (sx = [-1, 1], z = [24, 36]) translate([sx * (off_r(z, 0) + mold_t + mold_flange / 2), 0, z]) rotate([90, 0, 0]) cylinder(d = mold_bolt_d, h = 2 * mold_fin_t + 2, center = true, $fn = 48);
    for (sx = [-1, 1]) translate([sx * mold_low_x, 0, 8]) rotate([90, 0, 0]) cylinder(d = mold_bolt_d, h = 2 * mold_fin_t + 2, center = true, $fn = 48);   // низ: стягує дно/ніжку
    for (sx = [-1, 1]) if (sx != side) translate([sx * mold_low_x, -0.01 * side, mold_pin_z]) rotate([-90 * side, 0, 0]) cylinder(d = 3 + 0.4, h = mold_pin_h + 0.5, $fn = 32);   // гніздо під штир іншої половини
    if (side > 0) for (sx = [-1, 1]) translate([sx * mold_tab_x, mold_tab_y, cut_z - 9]) cylinder(d = insert[0] - 0.4, h = 10, $fn = 48);   // отвір під латунну вставку M3 (вплавлення) — лише в половині A
  }
}

module mold_pin() { translate([hole_r, 0, rib_top - insert[1]]) cylinder(d = mold_pin_d, h = insert[1] + 1, $fn = 48); }  // латунна вставка надівається знизу і впирається в сердечник; штирі зроблені разом із сердечником (окремо не друкується)

module mold_core(solid = false, vents = true) {   // порожнина основи (без каналів ніжки) з пазами під ребра; порожнистий, бортик лягає на край форми; solid — без порожнини, vents — з випусками (обидва прапорці лише для перевірок)
  rim = off_r(cut_z - 5, 0) + mold_t * sqrt(1 + k * k) + mold_fit;   // внутрішній радіус спідниці: охоплює форму на всю її глибину (конус розширюється донизу)
  module cav(z0, w, ztop) { rotate_extrude() polygon(concat([[0, z0]], [for (z = [z0 : 1 : cut_z]) [cav_r(z) - w, z]], [[cav_r(cut_z) - w, ztop], [0, ztop]])); }
  difference() {
    union() {
      difference() {
        difference() { cav(floor_z, 0, cut_z); for (a = pad_a) rib(a); translate([chan_x, 0, floor_z - 1]) cylinder(d = chan_d + 2 * mold_fit, h = 2, $fn = 48); }
        if (!solid) difference() { cav(floor_z + 3, mold_cw, cut_z + mold_cf + 1); for (a = pad_a) rib(a, mold_cw); }
      }
      for (a = pad_a) rotate(a) intersection() {   // бобишка над штирем, прикипає до стінки сердечника
        translate([hole_r - 3, -3, rib_top]) cube([cav_r(rib_top) - 1 - (hole_r - 3), 6, 4]);
        cav(floor_z, 0, cut_z);
      }
      translate([0, 0, cut_z]) difference() {   // бортик + спідниця навколо краю форми (в проріз фланців стику не лізе)
        union() {
          cylinder(r = rim + mold_skirt, h = mold_cf);
          translate([0, 0, -5]) difference() { cylinder(r = rim + mold_skirt, h = 5); translate([0, 0, -1]) cylinder(r = rim, h = 7); translate([-100, -mold_fin_t - 0.4, -1]) cube([200, mold_fin_t + mold_boss.y + 0.8, 7]); }
        }
        translate([0, 0, -1]) cylinder(r = cav_r_top - mold_cw, h = mold_cf + 2);
        for (i = [0 : 11]) rotate(15 + i * 30) translate([(cav_r_top + mold_ro) / 2, 0, -1]) cylinder(d = mold_vent_d, h = mold_cf + 2, $fn = 24);
      }
      for (sx = [-1, 1]) difference() {   // вушка бортика: M3 в латунну вставку у фланці форми
        hull() { translate([sx * mold_tab_x, mold_tab_y, cut_z]) cylinder(r = 5, h = mold_cf, $fn = 48); translate([sx * (rim - 2), mold_tab_y - 5, cut_z]) cube([0.1, 10, mold_cf]); }
        translate([sx * mold_tab_x, mold_tab_y, cut_z - 1]) cylinder(d = 3.4, h = mold_cf + 2, $fn = 48);
      }
    }
    if (vents && !solid) {
      for (i = [0 : 5]) rotate(30 + 60 * i) translate([30, 0, floor_z - 1]) cylinder(d = mold_vent2_d, h = 5, $fn = 24);   // дно сердечника → порожнина
      translate([0, 0, floor_z - 1]) cylinder(d = mold_vent2_d, h = 5, $fn = 24);
      for (a = pad_a) rotate(a) translate([44, 4.5, rib_top - 0.5]) cylinder(d = mold_vent2_d, h = mold_cw + 1, $fn = 24);   // стеля паза → порожнина
    }
  }
  for (a = pad_a) rotate(a) mold_pin();
}

module mold_assembly() {   // показ: форма в розрізі зі складеними деталями (для перевірки)
  intersection() {
    union() {
      color("#c0643f", 0.5) { mold_outer(1); mold_outer(-1); }
      color("#5a6a7a") mold_core();
      color("#6f8f6a") { puck_core(); usb_core(); }
      color("#9b9b96") base();
    }
    translate([-200, 0, -10]) cube([400, 200, 300]);
  }
}

// --- шасі ---
module octagon(rf) { rotate(22.5) circle(r = rf / cos(22.5), $fn = 8); }  // грані перпендикулярні осям X/Y

module cell_at(side, layer) {  // стос по боці колони: side ±1 по Y
  mirror([0, side < 0 ? 1 : 0, 0]) translate([-cell.x / 2, bat_y0, deck_z + layer * cell.z]) cube(cell);
}

module rails(size, pos) {  // дві напрямні вздовж довгих боків плати
  for (s = [-1, 1]) translate([pos.x, pos.y + s * (size.y / 2 + fit + rail[0] / 2), deck_z + rail[1] / 2])
    cube([size.x - 6, rail[0], rail[1]], center = true);
}


module chassis() {
  box = [cell.x + 2 * bat_tol, cell.y + 2 * bat_tol];
  difference() {
    union() {
      translate([0, 0, chassis_z]) cylinder(d = chassis_d, h = chassis_t);
      translate([0, 0, deck_z]) linear_extrude(pocket_wall[1]) offset(r = 0.45) offset(delta = -0.45) intersection() {  // рамки під два стоси, обрізані по колу порожнини основи; без смужок < 0.9 мм
        for (sd = [-1, 1]) translate([0, sd * (bat_y0 - bat_tol + box.y / 2)]) difference() {
          square(box + 2 * [1, 1] * pocket_wall[0], center = true); square(box, center = true);
        }
        circle(r = pocket_r);
      }
      translate([0, 0, deck_z]) linear_extrude(cup_depth) difference() { octagon(col_flat + col_fit + cup_wall); octagon(col_flat + col_fit); }
      rotate(90) rails([esp.x, esp.z], [0, -esp_x]);  // паз: плата стоїть ребром
    }
    translate([chan_x, 0, chassis_z - 1]) cylinder(d = chan_d, h = chassis_t + 2, $fn = 48);
    for (a = pad_a) rotate(a - notch_a) translate([0, 0, chassis_z - 1]) rotate_extrude(angle = 2 * notch_a)  // виїмки під ребра
      translate([notch_r, 0]) square([chassis_d, deck_z + pocket_wall[1] - chassis_z + 2]);
    rotate(180) translate([0, -groove.x / 2, deck_z - groove.y]) cube([-esp_x, groove.x, groove.y + 0.01]);  // до ESP32
  }
}

module reflector() {
  translate([0, 0, refl_z]) linear_extrude(refl[1]) difference() {
    circle(d = refl[0]); octagon(col_flat + strip_t + 0.3);  // пропускає смугу
    translate([esp_x - esp.z / 2 - esp_slot_pad, -esp.x / 2 - esp_slot_pad]) square([esp.z + 3 + 2 * esp_slot_pad, esp.x + 2 * esp_slot_pad]);  // проріз під ESP32 (стоїть ребром до 44.5, разом з деталями 3 мм)
    for (a = pad_a) rotate(a - notch_a) polygon(concat([for (t = [0 : 1 : 2 * notch_a]) refl_notch_r * [cos(t), sin(t)]], [for (t = [2 * notch_a : -1 : 0]) refl[0] * [cos(t), sin(t)]]));  // виїмка під ребро
  }
}

// --- колона ---
module column() {
  difference() {
    translate([0, 0, deck_z]) linear_extrude(col_top - deck_z) octagon(col_flat);
    translate([0, 0, deck_z - 1]) cylinder(d = col_bore, h = col_top - deck_z + 2);
    rotate(180) translate([col_flat - 5, -slot.x / 2, deck_z - 1]) cube([10, slot.x, slot.y + 1]);  // у жолоб шасі, бік ESP32
    for (a = [0:45:315], z = wire_z) rotate(a) translate([col_flat - 5, 0, z]) rotate([0, 90, 0]) cylinder(d = wire_d, h = 10, $fn = 24);
  }
  for (a = [22.5, 142.5, 262.5]) rotate(a) translate([col_bore / 2 - key[0], -1.5, node_z0 - 2]) cube([key[0] + 0.5, 3, 2]);  // полички між отворами під дроти
  rotate(22.5) translate([col_bore / 2 - key[0], -key[1] / 2, node_z0]) cube([key[0] + 0.5, key[1], col_top - node_z0]);   // ребро
}

module key_slot() { rotate(22.5) translate([col_bore / 2 - key[0] - fit - 0.5, -key[1] / 2 - fit, node_z0 - 1]) cube([5, key[1] + 2 * fit, 40]); }

// --- вузол дімера V2: кришка колони під RK097NS ---
module knob_v2_cap() {  // гільза в колоні: стоїть на поличках, RK097NS — гайкою на верхній стінці, корпус звисає всередину
  difference() {
    translate([0, 0, node_z0]) cylinder(d = col_bore - 2 * fit, h = pot2_face + 2 - node_z0);
    translate([0, 0, node_z0 - 1]) cylinder(d = col_bore - 2 * fit - 2 * guide_wall, h = pot2_face - pot2_lock - node_z0 + 1);  // під корпус і дроти
    // гніздо на половину глибини корпусу: грань без ніжок (+Y) упирається в стінку, бокові грані — у напрямні, бік із ніжками (-Y) відкритий
    rotate(pot2_turn) translate([0, 0, pot2_face - pot2_lock - 0.01]) intersection() {
      cylinder(d = col_bore - 2 * fit - 2 * guide_wall, h = pot2_lock + 0.01);
      union() {
        translate([-pot2_body.x / 2 - fit, -pot2_body.y / 2 - fit, 0]) cube([pot2_body.x + 2 * fit, pot2_body.y + 2 * fit, pot2_lock + 0.01]);
        translate([-20, -20, 0]) cube([40, 20 - pot2_body.y / 2 - fit + 0.01, pot2_lock + 0.01]);
      }
    }
    translate([0, 0, pot2_face - 1]) cylinder(d = bush_hole, h = 10, $fn = 48);
    key_slot();
  }
}

// --- вузол дімера V1: напрямна в колоні і каретка з B100K, під нею KFC-003A ---
module knob_v1_guide() {
  difference() {
    translate([0, 0, guide_z0]) cylinder(d = col_bore - 2 * fit, h = guide_top - guide_z0);
    translate([0, 0, sb_base]) cylinder(d = bore, h = 50);
    translate([0, -bore / 2 + 3, guide_z0 - 1]) cylinder(d = 4, h = 5, $fn = 32);                            // дроти вниз
    key_slot();
  }
  translate([bore / 2 - 0.7, -1, sb_base]) cube([1.5, 2, guide_top - sb_base]);                          // ребро від провертання
  for (s = [-1, 1]) translate([s * (sb.x / 2 + 2.5), 0, sb_base]) cylinder(d = 2.5, h = sb.z - v1_travel, $fn = 24);  // упори ходу
}

module knob_v1_carriage() {
  z0 = sb_base + sb.z;  // у спокої каретка лежить на штоку кнопки
  difference() {
    translate([0, 0, z0]) cylinder(d = carr_d, h = pot1_face + 1.5 - z0);
    translate([0, 0, pot1_face - pot1_body.y - 0.01]) cylinder(d = pot1_body.x + 2 * fit, h = pot1_body.y + 0.01);
    translate([0, 0, pot1_face - 1]) cylinder(d = bush_hole, h = 5, $fn = 48);
    translate([-carr_d / 2 - 1, -4, z0 - 1]) cube([5, 8, pot1_face - z0 + 1]);                       // виводи і дроти
    for (s = [-1, 1]) translate([-carr_d / 2, s * 4.5 - 2.5, z0 - 1]) cube([carr_d, 5, 1 + 1 - 0.01]);  // місток над кнопкою
    translate([carr_d / 2 - 1.2, -1.3, z0 - 1]) cube([3, 2.6, pot1_face + 3 - z0]);                  // паз під ребро
  }
}

// --- дімер ---
module dimmer() {
  difference() {
    union() {
      translate([0, 0, dim_z[0]]) cylinder(r = dim_r, h = dim_z[1] - dim_z[0]);
      translate([0, 0, boss[1]]) cylinder(r = boss[0], h = dim_z[0] - boss[1] + 0.01);
      // планки під палець хрестом: скруглені в перерізі й на кінцях (hull двох напівеліпсоїдів)
      for (i = [0 : grip_n - 1]) rotate(i * 360 / grip_n) translate([0, 0, dim_z[1] - 0.01]) hull()
        for (x = [grip_gap + grip_w / 2, dim_r - grip_gap - grip_w / 2]) translate([x, 0, 0])
          intersection() { scale([grip_w / 2, grip_w / 2, grip_h + 0.01]) sphere(1, $fn = 32); translate([-5, -5, 0]) cube(10); }
    }
    translate([0, 0, boss[1] - 1]) cylinder(d = shaft_d - shaft_press, h = shaft_hole + 1, $fn = 48);
  }
}

// --- макети покупних деталей ---
module batteries() { for (sd = [-1, 1], l = [0:layers - 1]) cell_at(sd, l); }

module pcb() {
  translate([pm_x1 - ip5306.y, -ip5306.x / 2, pm_top - ip5306.z]) cube([ip5306.y, ip5306.x, ip5306.z]);                       // IP5306 компонентами донизу
  translate([sock_front - usb_sock.x, -usb_sock.y / 2, usb_z - usb_sock.z / 2]) cube(usb_sock);       // гніздо USB-C
  translate([esp_x - esp.z / 2, -esp.x / 2, deck_z]) cube([esp.z, esp.x, esp.y]);  // стоїть ребром
}

module pot_v1() {
  translate([0, 0, pot1_face - pot1_body.y]) cylinder(d = pot1_body.x, h = pot1_body.y);
  translate([0, 0, pot1_face]) cylinder(d = 7, h = pot1_bush);
  translate([0, 0, pot1_face]) cylinder(d = shaft_d, h = pot1_shaft);
  translate([-sb.x / 2, -sb.y / 2, sb_base]) cube(sb);  // KFC-003A
}

module pot_v2() {
  rotate(pot2_turn) translate([-pot2_body.x / 2, -pot2_body.y / 2, pot2_face - pot2_body.z]) cube(pot2_body);  // як гніздо в knob_v2_cap
  translate([0, 0, pot2_face]) cylinder(d = 7, h = pot2_bush);
  translate([0, 0, pot2_face]) cylinder(d = shaft_d, h = pot2_shaft);
}

module scene(cut) {
  module c(col, a = 1) { color(col, a) if (cut) intersection() { children(); translate([-200, 0, 0]) cube([400, 200, 300]); } else children(); }
  c("#e9e4da", cut ? 1 : 0.35) rotate(bay_turn) shade_top();   // затягнутий: повернуто в кінець пазів
  c("#9b9b96", cut ? 1 : 0.6) base();
  c("#5a6a7a") bay_ring();
  c("#d9d4cc") chassis();
  c("#ffffff") reflector();
  c("#f4f2ee") column();
  c("#c0643f") dimmer();
  c("#2f6db5") batteries();
  c("#1c1f1d") pcb();
  if (variant == 1) { c("#6f8f6a") knob_v1_guide(); c("#a3c49c") knob_v1_carriage(); c("#555") pot_v1(); }
  else { c("#6f8f6a") knob_v2_cap(); c("#555") pot_v2(); }
}

// --- форма для відливки: asserts ---
base_h    = cut_z - 5;
pc_reach  = puck_d / 2 + 1;                        // куди доходить зенківка puck_core (поза бік ніжки)
mold_ro   = off_r(cut_z, 0);                       // зовнішній радіус основи на верхньому краї
mold_pc_top = floor_z + 1;                         // верх puck_core: заходить у гніздо сердечника над дном
assert(mold_t >= 2.4, "стінка форми тонка: прогнеться під бетоном");
assert(max(base_h, 2 * (belt_r + mold_t + mold_flange)) <= 180 && 2 * (mold_tab_x + 5) <= 180, "частина форми не влазить на стіл A1 mini");
assert(2 * (off_r(cut_z - 5, 0) + mold_t * sqrt(1 + k * k) + mold_fit + mold_skirt) <= 180 && cut_z + mold_cf - floor_z <= 180, "сердечник не влазить на стіл A1 mini");
assert(mold_fin_t - 4 / 2 >= 2 && mold_low_x - mold_bolt_d / 2 - (puck_d / 2 + mold_t) >= 2 && mold_tab_x - 2 > mold_ro + mold_t, "вставка/болт надто близько до краю плавника");
assert(mold_tab_y - insert[0] / 2 >= 1.2 && mold_boss.y - mold_tab_y - insert[0] / 2 >= 1.2 && mold_boss.x / 2 - insert[0] / 2 >= 1.2 && mold_boss.z - 9 >= 1.2, "стінка бобишки навколо вставки бортика < 1.2 мм");
assert(mold_tab_x - mold_boss.x / 2 >= mold_ro + mold_t - 0.5 && mold_tab_x + mold_boss.x / 2 <= mold_ro + mold_t + mold_flange, "бобишка вставки виходить за плавник");
assert(mold_flange / 2 - mold_bolt_d / 2 >= 2, "болт M3 надто близько до краю фланця форми");
// puck_core: зенківка доходить до стінки форми й гнізда в ній, канал — до сердечника на floor_z
assert(pc_reach > puck_d / 2 && pc_reach <= puck_d / 2 + mold_t - 1.2, "зенківка usb_core не заходить у стінку форми або гніздо лишає стінку < 1.2");
assert(mold_pc_top >= floor_z && mold_pc_top > puck_z[1], "puck_core не доходить до сердечника на дні порожнини");
// штир у ребрі: радіально між гранню ребра (вгорі найдальша) і стінкою основи (внизу найближча), по дузі в межах ±pad_half
assert(hole_r - mold_pin_d / 2 >= rib_r(rib_top) + 0.3 && hole_r + mold_pin_d / 2 <= cav_r(rib_top - insert[1]) - 0.3, "штир виходить за ребро радіально");
assert(asin((mold_pin_d / 2 + 0.3) / hole_r) <= pad_half, "штир виходить за ребро по дузі");
assert(mold_pin_d < insert[0] - 0.5, "штир занадто товстий для вставки");

if      (part == "shade_top")        shade_top();
else if (part == "base")             base();
else if (part == "base_plastic")     base(true);
else if (part == "bay_ring")         bay_ring();
else if (part == "puck_core")        puck_core();
else if (part == "usb_core")         usb_core();
else if (part == "mold_outer_a")     mold_outer(1);
else if (part == "mold_outer_b")     mold_outer(-1);
else if (part == "mold_core")        mold_core();
else if (part == "mold_pin")         mold_pin();
else if (part == "mold_assembly")    mold_assembly();
else if (part == "chassis")          chassis();
else if (part == "reflector")        reflector();
else if (part == "column")           column();
else if (part == "knob_v1_carriage") knob_v1_carriage();
else if (part == "knob_v1_guide")    knob_v1_guide();
else if (part == "knob_v2_cap")      knob_v2_cap();
else if (part == "dimmer")           dimmer();
else if (part == "batteries")        batteries();
else if (part == "pcb")              pcb();
else if (part == "pot_v1")           pot_v1();
else if (part == "pot_v2")           pot_v2();
else if (part == "none")             ;   // для include з перевірок
else if (part == "section")          scene(true);   // розріз площиною XZ, видно половину y ≥ 0
else                                 scene(false);
