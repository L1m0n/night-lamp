// Спільне для parts-3d.html і render.html: геометрія з LAMP_MODELS, матеріали, полотно з OrbitControls.
// Потрібні: three@0.147.0 (three.min.js, OrbitControls.js, BufferGeometryUtils.js) і assets/models.js.
(function () {
  // [назва, матеріал, тип, група]
  var INFO = {
    shade_top:        ['Плафон', 'PLA білий, напівпрозорий', 'друк', 'Друк'],
    dimmer:           ['Дімер', 'PLA / PETG пастельний, шавлія', 'друк', 'Друк'],
    bowl:             ['Чаша', 'PLA пастельний, шавлія', 'друк', 'Друк'],
    column:           ['Колона', 'PLA білий', 'друк', 'Друк'],
    reflector:        ['Відбивач', 'PLA білий', 'друк', 'Друк'],
    chassis:          ['Шасі', 'PLA', 'друк', 'Друк'],
    knob_v1_carriage: ['Каретка дімера V1', 'PLA білий', 'друк', 'Друк'],
    knob_v1_guide:    ['Напрямна дімера V1', 'PLA білий', 'друк', 'Друк'],
    knob_v2_cap:      ['Кришка колони V2', 'PLA білий', 'друк', 'Друк'],
    puck:             ['Шайба', 'бетон, знизу корок 1 мм', 'лиття', 'Лиття'],
    puck_core:        ['Вкладиш-сердечник для лиття', 'PLA, ставиться у форму', 'друк для лиття', 'Лиття'],
    batteries:        ['Акумулятори 8× Li-Pol', 'макет 55×20×10 мм на комірку', 'покупна', 'Покупні (макети)'],
    pcb:              ['Плати: IP5306, ESP32-C3', 'макет, PCB', 'покупна', 'Покупні (макети)'],
    pot_v1:           ['Потенціометр B100K (V1)', 'макет', 'покупна', 'Покупні (макети)'],
    pot_v2:           ['Потенціометр RK097NS (V2)', 'макет', 'покупна', 'Покупні (макети)']
  };
  var SAGE = 0xa8b88e;
  // hex-кольори — у sRGB (інакше three r147 трактує їх як лінійні й усе вицвітає)
  if (window.THREE && THREE.ColorManagement) THREE.ColorManagement.legacyMode = false;

  function webgl() {
    try {
      var c = document.createElement('canvas');
      return !!(window.WebGLRenderingContext && (c.getContext('webgl2') || c.getContext('webgl')));
    } catch (e) { return false; }
  }
  function ready() { return !!(window.THREE && THREE.OrbitControls && THREE.BufferGeometryUtils && window.LAMP_MODELS) && webgl(); }

  var cache = {};
  function geom(name) {
    if (cache[name]) return cache[name];
    var bin = atob(LAMP_MODELS[name].pos), bytes = new Uint8Array(bin.length);
    for (var i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
    var g = new THREE.BufferGeometry();
    g.setAttribute('position', new THREE.BufferAttribute(new Float32Array(bytes.buffer), 3));
    // Злиття вершин + нормалі зі зламом 35°: округлі оболонки гладкі, гострі ребра лишаються гострими
    g = THREE.BufferGeometryUtils.toCreasedNormals(THREE.BufferGeometryUtils.mergeVertices(g), 35 * Math.PI / 180);
    g.computeBoundingBox();
    return (cache[name] = g);
  }

  function std(color, rough, metal, extra) {
    var m = new THREE.MeshStandardMaterial({ color: color, roughness: rough, metalness: metal || 0 });
    return extra ? Object.assign(m, extra) : m;
  }
  function material(name) {
    switch (name) {
      case 'puck': return std(0xc9c4bd, 0.92);
      case 'bowl': case 'dimmer': return std(SAGE, 0.62);
      case 'chassis': case 'puck_core': return std(0xe4ded3, 0.7);
      case 'reflector': return std(0xfbf9f5, 0.4);
      case 'batteries': return std(0x8e99a6, 0.45, 0.15); // без карти оточення метал виходить чорним — тому метал ледь-ледь
      case 'pcb': return std(0x2f6b4a, 0.55);
      case 'pot_v1': case 'pot_v2': return std(0xb9bbbe, 0.4, 0.2);
      default: return std(0xf4f0e8, 0.58); // PLA білий напівматовий
    }
  }

  // Полотно в контейнері: прозоре тло (видно --bg сторінки), DPR ≤ 2, стежить за розміром.
  function stage(host, fov) {
    var renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    renderer.setClearColor(0x000000, 0);
    renderer.outputEncoding = THREE.sRGBEncoding;
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.0;
    host.appendChild(renderer.domElement);
    var scene = new THREE.Scene();
    var camera = new THREE.PerspectiveCamera(fov || 30, 1, 5, 5000);
    var controls = new THREE.OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.dampingFactor = 0.08;
    // dirty: малювати лише коли щось змінилось (рух камери, ресайз, анімація сторінки)
    var s = { renderer: renderer, scene: scene, camera: camera, controls: controls, aspect: 1, onResize: null, dirty: true };
    controls.addEventListener('change', function () { s.dirty = true; });
    function resize() {
      var w = host.clientWidth || 1, h = host.clientHeight || 1;
      renderer.setSize(w, h, false);
      camera.aspect = s.aspect = w / h;
      camera.updateProjectionMatrix();
      if (s.onResize) s.onResize();
      s.dirty = true;
    }
    if (window.ResizeObserver) new ResizeObserver(resize).observe(host); else window.addEventListener('resize', resize);
    resize();
    return s;
  }

  function fallback(host, text) {
    host.innerHTML = '';
    var p = document.createElement('p');
    p.className = 'fallback';
    p.textContent = text;
    host.appendChild(p);
  }

  window.Lamp3D = { INFO: INFO, ready: ready, geom: geom, material: material, stage: stage, fallback: fallback };
})();
