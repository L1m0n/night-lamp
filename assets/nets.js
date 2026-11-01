/* Єдине джерело з'єднань лампи. Читають schematic.html (схема) і wiring.html (монтаж).
   variant: "both" — обидва варіанти, "v1" — B100K + кнопка KFC-003A, "v2" — RK097NS з вимикачем.
   Для кожного варіанта ім'я мережі трапляється один раз, а кожен пін — щонайбільше в одній мережі:
   мережі, що відрізняються між V1 і V2, записані двома повними копіями (v1 і v2).
   Без макетки: R1 впаяний у дріт DIN, R2/R3 — прямо на пінах ESP32. */
window.LAMP_NETS = {
  parts: {
    BT1:  { name: "6× Li-Pol 850 мА·год паралельно (1S)", variant: "both", pins: { "+": "плюс", "-": "мінус" } },
    U1:   { name: "IP5306, модуль павербанка з USB-C", variant: "both",
            pins: { "BAT+": "акумулятор +", "BAT-": "акумулятор −", "VOUT": "вихід 5 В", "GND": "земля", "KEY": "кнопка вмикання" } },
    U2:   { name: "ESP32-C3 SuperMini", variant: "both",
            pins: { "5V": "живлення 5 В", "GND": "земля", "3V3": "вихід 3.3 В", "GPIO0": "АЦП, повзунок ручки",
                    "GPIO1": "АЦП, дільник батареї", "GPIO10": "дані стрічки" } },
    R1:   { name: "Резистор 330 Ом, у дроті DIN", variant: "both", pins: { "1": "", "2": "" } },
    R2:   { name: "Резистор 220 кОм", variant: "both", pins: { "1": "", "2": "" } },
    R3:   { name: "Резистор 220 кОм", variant: "both", pins: { "1": "", "2": "" } },
    LED1: { name: "Стрічка SK6812 RGBW, 48 LED", variant: "both", pins: { "5V": "живлення 5 В", "GND": "земля", "DIN": "дані" } },
    RV1:  { name: "Потенціометр B100K", variant: "v1", pins: { "1": "край", "2": "повзунок", "3": "край" } },
    RV2:  { name: "Потенціометр RK097NS 10K з вимикачем", variant: "v2",
            pins: { "1": "край", "2": "повзунок", "3": "край", "S1": "вимикач", "S2": "вимикач" } },
    SW1:  { name: "Кнопка KFC-003A", variant: "v1", pins: { "1": "", "2": "" } }
  },
  nets: [
    { name: "BAT+",       variant: "both", pins: ["BT1.+", "U1.BAT+", "R2.1"] },
    { name: "GND",        variant: "v1",   pins: ["BT1.-", "U1.BAT-", "U1.GND", "U2.GND", "LED1.GND", "R3.2", "RV1.1", "SW1.2"] },
    { name: "GND",        variant: "v2",   pins: ["BT1.-", "U1.BAT-", "U1.GND", "U2.GND", "LED1.GND", "R3.2", "RV2.1"] },
    { name: "VBAT_SENSE", variant: "both", pins: ["R2.2", "R3.1", "U2.GPIO1"] },
    { name: "5V_OUT",     variant: "v1",   pins: ["U1.VOUT", "U2.5V", "LED1.5V"] },
    { name: "5V_OUT",     variant: "v2",   pins: ["U1.VOUT", "RV2.S1"] },
    { name: "5V_SW",      variant: "v2",   pins: ["RV2.S2", "U2.5V", "LED1.5V"] },
    { name: "KEY",        variant: "v1",   pins: ["U1.KEY", "SW1.1"] },
    { name: "3V3",        variant: "v1",   pins: ["U2.3V3", "RV1.3"] },
    { name: "3V3",        variant: "v2",   pins: ["U2.3V3", "RV2.3"] },
    { name: "POT_W",      variant: "v1",   pins: ["U2.GPIO0", "RV1.2"] },
    { name: "POT_W",      variant: "v2",   pins: ["U2.GPIO0", "RV2.2"] },
    { name: "DATA",       variant: "both", pins: ["U2.GPIO10", "R1.1"] },
    { name: "LED_DIN",    variant: "both", pins: ["R1.2", "LED1.DIN"] }
  ]
};
