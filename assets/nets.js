/* Єдине джерело з'єднань лампи. Читають schematic.html (схема) і wiring.html (монтаж).
   variant: "both" — обидва варіанти, "v1" — B100K + кнопка + MOSFET-и, "v2" — RK097NS з вимикачем.
   Для кожного варіанта ім'я мережі трапляється один раз, а кожен пін — щонайбільше в одній мережі:
   мережі, що відрізняються між V1 і V2, записані двома повними копіями (v1 і v2). */
window.LAMP_NETS = {
  parts: {
    BT1:  { name: "8× Li-Pol 850 мА·год паралельно (1S)", variant: "both", pins: { "+": "плюс", "-": "мінус" } },
    U1:   { name: "IP5306, модуль павербанка з USB-C", variant: "both",
            pins: { "BAT+": "акумулятор +", "BAT-": "акумулятор −", "VOUT": "вихід 5 В", "GND": "земля", "KEY": "кнопка вмикання" } },
    U2:   { name: "ESP32-C3 SuperMini", variant: "both",
            pins: { "5V": "живлення 5 В", "GND": "земля", "3V3": "вихід 3.3 В", "GPIO0": "АЦП, повзунок ручки",
                    "GPIO1": "АЦП, дільник батареї", "GPIO6": "живлення стрічки (V1)", "GPIO7": "KEY (V1)", "GPIO10": "дані стрічки" } },
    U3:   { name: "74AHCT1G125, зсув рівня 3.3 → 5 В", variant: "both",
            pins: { "VCC": "5 В", "GND": "земля", "A": "вхід", "Y": "вихід", "OE": "дозвіл, активний низький → GND" } },
    R1:   { name: "Резистор 330 Ом", variant: "both", pins: { "1": "", "2": "" } },
    R2:   { name: "Резистор 220 кОм", variant: "both", pins: { "1": "", "2": "" } },
    R3:   { name: "Резистор 220 кОм", variant: "both", pins: { "1": "", "2": "" } },
    C1:   { name: "Конденсатор 1000 мкФ 10 В", variant: "both", pins: { "1": "+", "2": "−" } },
    C2:   { name: "Конденсатор 100 нФ", variant: "both", pins: { "1": "", "2": "" } },
    C3:   { name: "Конденсатор 100 нФ", variant: "both", pins: { "1": "", "2": "" } },
    LED1: { name: "Стрічка SK6812 RGBW, 80 LED", variant: "both", pins: { "5V": "живлення 5 В", "GND": "земля", "DIN": "дані" } },
    RV1:  { name: "Потенціометр B100K", variant: "v1", pins: { "1": "край", "2": "повзунок", "3": "край" } },
    RV2:  { name: "Потенціометр RK097NS 10K з вимикачем", variant: "v2",
            pins: { "1": "край", "2": "повзунок", "3": "край", "S1": "вимикач", "S2": "вимикач" } },
    SW1:  { name: "Кнопка KFC-003A", variant: "v1", pins: { "1": "", "2": "" } },
    Q1:   { name: "P-MOSFET AO3401", variant: "v1", pins: { "G": "затвор", "S": "витік", "D": "стік" } },
    Q2:   { name: "N-MOSFET 2N7002", variant: "v1", pins: { "G": "затвор", "D": "стік", "S": "витік" } },
    Q3:   { name: "N-MOSFET 2N7002", variant: "v1", pins: { "G": "затвор", "D": "стік", "S": "витік" } },
    R4:   { name: "Резистор 10 кОм", variant: "v1", pins: { "1": "", "2": "" } },
    R5:   { name: "Резистор 10 кОм", variant: "v1", pins: { "1": "", "2": "" } },
    R6:   { name: "Резистор 10 кОм", variant: "v1", pins: { "1": "", "2": "" } }
  },
  nets: [
    { name: "BAT+",       variant: "both", pins: ["BT1.+", "U1.BAT+", "R2.1"] },
    { name: "GND",        variant: "v1",   pins: ["BT1.-", "U1.BAT-", "U1.GND", "U2.GND", "U3.GND", "U3.OE", "LED1.GND", "C1.2", "C2.2", "C3.2", "R3.2",
                                                  "RV1.3", "SW1.2", "Q2.S", "Q3.S", "R5.2", "R6.2"] },
    { name: "GND",        variant: "v2",   pins: ["BT1.-", "U1.BAT-", "U1.GND", "U2.GND", "U3.GND", "U3.OE", "LED1.GND", "C1.2", "C2.2", "C3.2", "R3.2",
                                                  "RV2.3"] },
    { name: "VBAT_SENSE", variant: "both", pins: ["R2.2", "R3.1", "U2.GPIO1"] },
    { name: "5V_OUT",     variant: "v1",   pins: ["U1.VOUT", "U2.5V", "U3.VCC", "C3.1", "Q1.S", "R4.1"] },
    { name: "5V_OUT",     variant: "v2",   pins: ["U1.VOUT", "RV2.S1"] },
    { name: "5V_SW",      variant: "v2",   pins: ["RV2.S2", "U2.5V", "U3.VCC", "C3.1", "LED1.5V", "C1.1"] },
    { name: "LED_5V",     variant: "v1",   pins: ["Q1.D", "LED1.5V", "C1.1"] },
    { name: "Q1_GATE",    variant: "v1",   pins: ["Q1.G", "R4.2", "Q2.D"] },
    { name: "LED_PWR",    variant: "v1",   pins: ["U2.GPIO6", "Q2.G", "R5.1"] },
    { name: "KEY",        variant: "v1",   pins: ["U1.KEY", "SW1.1", "Q3.D"] },
    { name: "KEY_DRV",    variant: "v1",   pins: ["U2.GPIO7", "Q3.G", "R6.1"] },
    { name: "3V3",        variant: "v1",   pins: ["U2.3V3", "RV1.1"] },
    { name: "3V3",        variant: "v2",   pins: ["U2.3V3", "RV2.1"] },
    { name: "POT_W",      variant: "v1",   pins: ["U2.GPIO0", "C2.1", "RV1.2"] },
    { name: "POT_W",      variant: "v2",   pins: ["U2.GPIO0", "C2.1", "RV2.2"] },
    { name: "DATA_3V3",   variant: "both", pins: ["U2.GPIO10", "U3.A"] },
    { name: "DATA_5V",    variant: "both", pins: ["U3.Y", "R1.1"] },
    { name: "LED_DIN",    variant: "both", pins: ["R1.2", "LED1.DIN"] }
  ]
};
