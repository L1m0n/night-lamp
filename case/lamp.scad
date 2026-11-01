// Нічна лампа на акумуляторах: шейдер — форма lamp-0.1.1 (Fusion), зменшена ×0.7; бетонна шайба, шасі з акумуляторами,
// восьмигранна колона зі стрічкою, дімер угорі.
//   openscad -D 'part="bowl"' -o bowl.stl lamp.scad      (усі деталі — tools/build.sh)
//   openscad -D 'part="assembly"' -D variant=2 -o a.png lamp.scad
// Усі деталі — в осі лампи: стіл z=5, низ шейдера z=15 (лампа на 10 мм над столом, ~175 мм від столу до верху).
// Шейдер = профіль lamp-export-1.step, масштаб 0.7 від дна шейдера (z=15); стінка лишається 2 мм.
// Найвища друкована деталь ≤ 180 (Bambu A1 mini). STL складаються у збірку без зсувів; друкувати — повернувши в слайсері.
// Розміри в мм. Значення з позначкою «заміряти» — номінальні, звір зі своїми деталями.
//
// Вигляд згори: +X — USB-C у боці шайби, ±Y — акумулятори, −X — ESP32 (стоїть ребром).

part    = "assembly";  // shade_top, bowl, puck, puck_core, chassis, reflector, column, knob_v1_carriage,
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
plate_z  = [174.43, 176.43];  // верхня пластина 2 мм; опущена на 0.75, щоб дімер 2.5 мм став урівень
plate_hole_d = 20;
recess_r = 67.5 * S;          // заглиблення під дімер
collar   = [40 * S, 42 * S, 17];  // комір під шайбу: r внутрішній, r зовнішній, z центру заокруглення R2

/* [Байонет] */
lap      = 6;     // напуск плафона в чашу
lap_fit  = 0.2;
lap_t    = 1.6;   // товщина манжети плафона
lap_join = 0.5;   // над z=50 манжета заходить у стінку плафона, щоб бути з ним одним тілом
bay      = [8, 2, 1.0];  // ламель: по дузі, по висоті, радіально
bay_n    = 3;
bay_turn = 30;    // поворот байонета
bay_fit  = 0.2;
bump_h   = 0.4;   // горбик-фіксатор у пазу

/* [Шайба: бетон] */
puck_fit = 0.25;           // зазор у комірі (у STEP шайба Ø80 у коміра Ø80 впритул)
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
cell        = [55, 20, 10];  // Li-Pol 850 мА·год
bat_tol     = 0.5;
pocket_wall = [1.2, 5];      // стінка навколо вітряка: товщина, висота
esp  = [22.5, 18, 1.2];      // ESP32-C3 SuperMini — заміряти
rail = [1.2, 3];             // напрямні під плати: товщина, висота
groove = [6, 1.5];           // жолоб під дроти з колони до ESP32 (під акумуляторами)
cup_depth = 8;
cup_wall  = 2;
col_fit   = 0.2;
refl = [103, 1.2];           // білий відбивач

/* [Колона] */
col_face = 12.5;   // грань восьмигранника
col_top  = 159.44;
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
pot2_body  = [10, 11.5, 11];  // корпус разом з вимикачем: ширина, довжина, глибина — заміряти
pot2_bush  = 5;               // довжина втулки M7 — заміряти
pot2_shaft = 15;              // вал від монтажної площини — заміряти
bush_top   = 165.44;          // верх втулки
bush_hole  = 7.2;

/* [Дімер: lamp-0.1.1 × 0.7; товщина 2.5 і хвостовик — без масштабу] */
dim_r    = 66.5 * S;
dim_z    = [sz(250.19) - 2.5, sz(250.19)];
boss     = [9, dim_z[0] - 10];   // хвостовик: радіус, низ
shaft_d  = 6.0;               // рифлений вал — заміряти
shaft_press = 0.1;            // натяг
shaft_hole  = 9;              // глибина отвору від низу хвостовика

$fn = 180;

// --- похідні розміри ---
k        = (belt_r - cone_top.x) / (cone_top.y - belt_z);    // нахил конуса dr/dz
cone_in  = belt_r - wall * sqrt(1 + k * k);                 // внутрішній конус на верху поясу
function in_r(z) = z < fil_c.y ? fil_c.x + sqrt(pow(fil_r - wall, 2) - pow(fil_c.y - z, 2))
                 : z <= belt_z ? belt_r - wall : cone_in - k * (z - belt_z);
col_flat  = col_face / (2 * tan(22.5));  // половина розміру під ключ
chassis_z = collar.z + 2;                // шасі лежить на верху коміра
deck_z    = chassis_z + chassis_t;       // верх диска шасі
bat_top   = deck_z + 2 * cell.z;
refl_z    = bat_top;                     // відбивач лежить на акумуляторах
cut_z     = refl_z + refl[1] + 1;         // розріз: відбивач на 1 мм нижче краю чаші
bat_y0    = col_flat + col_fit + cup_wall + 0.5 + bat_tol;  // акумулятори двома стосами по боках колони (±Y)
bat_corner = norm([cell.x / 2 + bat_tol, bat_y0 + cell.y + bat_tol]);
pocket_r  = in_r(deck_z) - 0.3;
esp_x     = -(cell.x / 2 + bat_tol + pocket_wall[0] + 3 + esp.z / 2);  // ESP32 ребром за торцем акумуляторів
pm_top    = usb_z + usb_below + ip5306.z;                   // стеля кишені = спина плати
usb_hole  = plug + [2, 2] * plug_fit;                       // зенківка під корпус штекера
pm_x1     = sqrt(pow(puck_d / 2 - 1.2, 2) - pow(ip5306.x / 2 + pm_fit, 2)) - pm_fit;  // край плати з USB-C: кути кишені ≥1.2 від боку шайби
sock_front = pm_x1 + usb_over;                             // торець гнізда USB-C
win_x0    = sock_front - 0.5;                              // дно зенківки: трохи за торцем гнізда
sleeve_r  = in_r(cut_z) - lap_fit;                          // зовнішній радіус манжети: чаша над поясом звужується, найвужче — на краю
bay_z     = cut_z - lap / 2 - bay.y / 2;                    // низ ламелі
bay_a     = bay.x / sleeve_r * 180 / PI;                    // ламель по дузі, градуси
bore      = col_bore - 2 * fit - 2 * guide_wall;            // отвір напрямної V1
carr_d    = bore - 2 * fit;
sb_base   = pot1_face - pot1_body.y - 1 - sb.z;             // кнопка стоїть на дні напрямної
guide_z0  = sb_base - 1.5;
pot2_face = bush_top - pot2_bush;
v1_bush   = pot1_face + pot1_bush;
node_top  = max(v1_bush, bush_top);
strip_z1  = strip_z0 + strip_len;
wire_z    = [strip_z0 - wire_gap - wire_d / 2, strip_z1 + wire_gap + wire_d / 2];  // центри отворів
node_z0   = min(guide_z0, col_top - 5);   // нижче — порожнина колони вільна (напрямна V1, хвостовик кришки V2)

echo(str("Внутрішній радіус чаші: z=27 → ", in_r(27), ", z=", bat_top, " → ", in_r(bat_top)));
echo(str("Вал у хвостовику: V1 ", pot1_face + pot1_shaft - boss[1], ", V2 ", pot2_face + pot2_shaft - boss[1]));

assert(bat_corner + 0.5 < pocket_r, "акумулятори впираються в чашу");
assert(norm([-esp_x + esp.z / 2 + 3, esp.x / 2]) < pocket_r, "ESP32 з деталями впирається в чашу");
assert(sleeve_r - lap_t > bat_corner + 0.5, "манжета плафона зачіпає акумулятори");
assert(top_z - (cut_z - lap) <= 180 && cut_z - ring_z <= 180, "деталь шейдера вища за стіл принтера");
assert(node_top < plate_z[0] - 0.5, "колона з вузлом дімера впирається в пластину плафона");
assert(pot1_face + pot1_shaft - boss[1] >= 6, "вал V1 заходить у хвостовик дімера менше ніж на 6 мм");
assert(pot2_face + pot2_shaft - boss[1] >= 6, "вал V2 заходить у хвостовик дімера менше ніж на 6 мм");
assert(boss[1] + shaft_hole > max(pot1_face + pot1_shaft, pot2_face + pot2_shaft) + 0.5, "вал упирається в дно отвору дімера");
assert(boss[1] - node_top > v1_travel + 0.3, "втулка торкається хвостовика дімера");
assert(chassis_d / 2 + chassis_fit <= in_r(chassis_z), "шасі не проходить у чашу на z=27");
assert(col_flat + col_fit + cup_wall <= (cell.x - cell.y) / 2, "стакан колони не влазить у центр вітряка");
assert(v1_travel > sb_stroke && v1_travel < dim_z[0] - plate_z[1], "хід каретки V1: має натиснути кнопку і не впертися дімером у плафон");
assert(refl[0] / 2 < in_r(refl_z + refl[1]), "відбивач не влазить у плафон");
assert(wire_z[0] + wire_d / 2 < strip_z0 && wire_z[1] - wire_d / 2 > strip_z1, "отвір під дроти заходить під смугу");
assert(wire_z[0] - wire_d / 2 > deck_z + cup_depth, "нижній отвір під дроти схований у стакані шасі");
assert(wire_z[1] + wire_d / 2 < node_z0 && node_z0 <= col_top, "верхній отвір під дроти впирається у вузол дімера або виходить за колону");
assert((cell.x - cell.y) / 2 - col_flat >= strip_pcb, "кінець смуги з пайкою не влазить між колоною й акумуляторами");
assert(strip_z0 + pitch_led / 2 - 2.5 > refl_z + refl[1], "перший LED під відбивачем");
assert(abs(chan_x) + chan_d / 2 < col_bore / 2, "канал з шайби має виходити всередину колони");
assert(pm_x1 - ip5306.y > chan_x + chan_d / 2 + 1, "плата IP5306 налазить на канал під дроти");
assert(norm([pm_x1 + pm_fit, ip5306.x / 2 + pm_fit]) < puck_d / 2 - 1, "кишеня IP5306 прориває бік шайби");
assert(win_x0 <= sock_front && win_x0 >= sock_front - 0.5, "дно зенківки USB-C має бути в межах 0.5 мм від торця гнізда");
assert(pm_x1 <= sock_front, "плата IP5306 заходить у шлях штекера");
assert(usb_hole.x >= plug.x + 0.3 && usb_hole.y >= plug.y + 0.3, "корпус штекера не проходить у зенківку");
assert(usb_z - usb_hole.y / 2 > puck_z[0] + 1, "зенківка USB-C прориває низ шайби");
assert(usb_sock.y < usb_hole.x && usb_sock.z < usb_hole.y, "гніздо більше за зенківку");
assert(belt_r - wall + lap_join > in_r(cut_z + 1) && belt_r - wall + lap_join < in_r(cut_z + 1) + wall - 0.5, "манжета не зростається зі стінкою плафона");
assert(refl[0] / 2 < sleeve_r - lap_t - 0.3, "відбивач не влазить у манжету плафона");
assert(sleeve_r + bay.z + bay_fit < in_r(cut_z) + wall - 0.9, "паз байонета прориває чашу: стінка під пазом < 0.9");

// --- шейдер ---
function arc(c, r, a0, a1, n = 30) = [for (i = [0:n]) c + r * [cos(a0 + (a1 - a0) * i / n), sin(a0 + (a1 - a0) * i / n)]];

module shade_envelope() {  // усе, що обмежує зовнішня поверхня, до осі
  polygon(concat([[0, ring_z]], arc(fil_c, fil_r, -90, 0), [[belt_r, belt_z]],
                 arc([cone_top.x - 0.5 * cos(atan(k)), top_z - 0.5], 0.5, atan(k), 90), [[0, top_z]]));
}

module shade_profile() {
  difference() {
    union() {
      difference() {
        shade_envelope();
        offset(r = -wall) union() { shade_envelope(); mirror([1, 0]) shade_envelope(); }  // стінка 2 і дно
      }
      intersection() { shade_envelope(); translate([0, plate_z[0]]) square([belt_r, top_z]); }  // пластина
      translate([collar[0], ring_z]) square([collar[1] - collar[0], collar.z - ring_z]);       // комір
      intersection() { translate([collar[0], collar.z]) circle(r = 2, $fn = 48); translate([collar[0], 0]) square(100); }
    }
    translate([-1, ring_z - 1]) square([collar[0] + 1, collar.z]);   // середина відкрита під шайбу
    translate([-1, plate_z[1]]) square([recess_r + 1, 10]);          // заглиблення під дімер
    translate([-1, 0]) square([plate_hole_d / 2 + 1, 300]);          // отвір Ø20
  }
}

module shade() { rotate_extrude() shade_profile(); }

module zslab(z0, z1) { translate([-200, -200, z0]) cube([400, 400, z1 - z0]); }

module arc_ring(r0, r1, z0, h, a0, a1) {
  rotate(a0) translate([0, 0, z0]) rotate_extrude(angle = a1 - a0) translate([r0, 0]) square([r1 - r0, h]);
}

module bowl() {
  difference() {
    intersection() { shade(); zslab(0, cut_z); }
    for (i = [0:bay_n - 1]) rotate(i * 360 / bay_n) {  // Г-паз: вниз від краю, потім 30° по колу
      arc_ring(sleeve_r - 0.1, sleeve_r + bay.z + bay_fit, bay_z - bay_fit, cut_z - bay_z + bay_fit + 1, -0.5, bay_a + 0.5);
      arc_ring(sleeve_r - 0.1, sleeve_r + bay.z + bay_fit, bay_z - bay_fit, bay.y + 2 * bay_fit, -0.5, bay_turn + bay_a + 0.5);
    }
  }
  for (i = [0:bay_n - 1]) rotate(i * 360 / bay_n)  // горбик: ламель перескакує його в кінці повороту
    arc_ring(in_r(cut_z), sleeve_r + bay.z + bay_fit + 0.1, bay_z - bay_fit - 0.01, bump_h + 0.01, bay_turn - 1.2, bay_turn - 0.4);
}

module shade_top() {
  intersection() { shade(); zslab(cut_z, 300); }
  difference() {  // манжета: заходить у чашу на 6 мм, сходинка — торець плафона на краю чаші
    union() {
      translate([0, 0, cut_z - lap]) cylinder(r = sleeve_r, h = lap);
      translate([0, 0, cut_z]) cylinder(r = belt_r - wall + lap_join, h = 1);  // зрощення зі стінкою
    }
    translate([0, 0, cut_z - lap - 1]) cylinder(r = sleeve_r - lap_t, h = lap + 3);
  }
  for (i = [0:bay_n - 1]) rotate(i * 360 / bay_n) arc_ring(sleeve_r - 0.5, sleeve_r + bay.z, bay_z, bay.y, 0, bay_a);
}

// --- шайба ---
module puck_void() {
  translate([chan_x - chan_d / 2, -ip5306.x / 2 - pm_fit, puck_z[0] - 1]) cube([pm_x1 + pm_fit - chan_x + chan_d / 2, ip5306.x + 2 * pm_fit, pm_top - puck_z[0] + 1]);
  // зенківка від торця гнізда назовні: корпус штекера заходить до торця, гніздо стоїть глибше за бік шайби
  translate([win_x0, -usb_hole.x / 2, usb_z - usb_hole.y / 2]) cube([puck_d / 2 + 1 - win_x0, usb_hole.x, usb_hole.y]);
  translate([chan_x, 0, puck_z[0]]) cylinder(d = chan_d, h = puck_z[1] - puck_z[0] + 1, $fn = 48);
}

module puck() { difference() { translate([0, 0, puck_z[0]]) cylinder(d = puck_d, h = puck_z[1] - puck_z[0]); puck_void(); } }

module puck_core() {  // вкладиш у форму: те, що в шайбі порожнє (плата клеїться спиною до стелі кишені)
  intersection() { puck_void(); translate([0, 0, puck_z[0]]) cylinder(d = puck_d + 2, h = puck_z[1] - puck_z[0]); }
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
      translate([0, 0, deck_z]) linear_extrude(pocket_wall[1]) intersection() {  // рамки під два стоси, обрізані по колу чаші
        for (sd = [-1, 1]) translate([0, sd * (bat_y0 - bat_tol + box.y / 2)]) difference() {
          square(box + 2 * [1, 1] * pocket_wall[0], center = true); square(box, center = true);
        }
        circle(r = pocket_r);
      }
      translate([0, 0, deck_z]) linear_extrude(cup_depth) difference() { octagon(col_flat + col_fit + cup_wall); octagon(col_flat + col_fit); }
      rotate(90) rails([esp.x, esp.z], [0, -esp_x]);  // паз: плата стоїть ребром
    }
    translate([chan_x, 0, chassis_z - 1]) cylinder(d = chan_d, h = chassis_t + 2, $fn = 48);
    rotate(180) translate([0, -groove.x / 2, deck_z - groove.y]) cube([-esp_x, groove.x, groove.y + 0.01]);  // до ESP32
  }
}

module reflector() {
  translate([0, 0, refl_z]) linear_extrude(refl[1]) difference() { circle(d = refl[0]); octagon(col_flat + strip_t + 0.3); }  // пропускає смугу
}

// --- колона ---
module column() {
  difference() {
    translate([0, 0, deck_z]) linear_extrude(col_top - deck_z) octagon(col_flat);
    translate([0, 0, deck_z - 1]) cylinder(d = col_bore, h = col_top - deck_z + 2);
    rotate(180) translate([col_flat - 5, -slot.x / 2, deck_z - 1]) cube([10, slot.x, slot.y + 1]);  // у жолоб шасі, бік ESP32
    for (a = [0:45:315], z = wire_z) rotate(a) translate([col_flat - 5, 0, z]) rotate([0, 90, 0]) cylinder(d = wire_d, h = 10, $fn = 24);
  }
}

// --- вузол дімера V2: кришка колони під RK097NS ---
module knob_v2_cap() {
  difference() {
    union() {
      translate([0, 0, col_top]) cylinder(d = 2 * col_flat, h = pot2_face + 2 - col_top);   // лежить на торці колони
      translate([0, 0, col_top - 5]) cylinder(d = col_bore - 2 * fit, h = 5.01);              // хвостовик у порожнину
    }
    translate([0, 0, col_top - 6]) cylinder(d = col_bore - 2 * fit - 2 * guide_wall, h = pot2_face - col_top + 6);  // під корпус
    translate([0, 0, pot2_face - 1]) cylinder(d = bush_hole, h = 10, $fn = 48);
  }
}

// --- вузол дімера V1: напрямна в колоні і каретка з B100K, під нею KFC-003A ---
module knob_v1_guide() {
  difference() {
    union() {
      translate([0, 0, guide_z0]) cylinder(d = col_bore - 2 * fit, h = col_top - guide_z0);
      translate([0, 0, col_top]) cylinder(d = 2 * col_flat, h = 1.5);
    }
    translate([0, 0, sb_base]) cylinder(d = bore, h = 50);
    translate([0, -bore / 2 + 3, guide_z0 - 1]) cylinder(d = 4, h = 5, $fn = 32);                            // дроти вниз
  }
  translate([bore / 2 - 0.7, -1, sb_base]) cube([1.5, 2, col_top + 1.5 - sb_base]);                          // ребро від провертання
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
    }
    translate([0, 0, boss[1] - 1]) cylinder(d = shaft_d - shaft_press, h = shaft_hole + 1, $fn = 48);
  }
}

// --- макети покупних деталей ---
module batteries() { for (sd = [-1, 1], l = [0:1]) cell_at(sd, l); }

module pcb() {
  translate([pm_x1 - ip5306.y, -ip5306.x / 2, pm_top - ip5306.z]) cube(ip5306);                       // IP5306 компонентами донизу
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
  translate([-pot2_body.x / 2, -pot2_body.y / 2, pot2_face - pot2_body.z]) cube(pot2_body);
  translate([0, 0, pot2_face]) cylinder(d = 7, h = pot2_bush);
  translate([0, 0, pot2_face]) cylinder(d = shaft_d, h = pot2_shaft);
}

module scene(cut) {
  module c(col, a = 1) { color(col, a) if (cut) intersection() { children(); translate([-200, 0, 0]) cube([400, 200, 300]); } else children(); }
  c("#e9e4da", cut ? 1 : 0.35) shade_top();
  c("#8c7f6e", cut ? 1 : 0.6) bowl();
  c("#9b9b96") puck();
  c("#d9d4cc") chassis();
  c("#ffffff") reflector();
  c("#f4f2ee") column();
  c("#c0643f") dimmer();
  c("#2f6db5") batteries();
  c("#1c1f1d") pcb();
  if (variant == 1) { c("#6f8f6a") knob_v1_guide(); c("#a3c49c") knob_v1_carriage(); c("#555") pot_v1(); }
  else { c("#6f8f6a") knob_v2_cap(); c("#555") pot_v2(); }
}

if      (part == "shade_top")        shade_top();
else if (part == "bowl")             bowl();
else if (part == "puck")             puck();
else if (part == "puck_core")        puck_core();
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
else if (part == "section")          scene(true);   // розріз площиною XZ, видно половину y ≥ 0
else                                 scene(false);
