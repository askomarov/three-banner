varying vec2 vUv;
varying vec3 vPostion;
uniform float time;

// noise
float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float noise(vec3 p){
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

float lines(vec2 uv, float offset) {

  // return abs(sin(uv.x*20.));
  // return smoothstep(
  //   0.0, 0.4 + offset*0.5,
  //   0.5*abs((sin(uv.x*50.) + offset*2.))
  // );
   return step(0.5, abs(sin(uv.x * 100.0) + offset * 2.0));
}

float linesWithWidth(vec2 uv, float frequency, float stripeWidth, float offset) {
  // frequency управляет количеством полос
  // stripeWidth контролирует ширину полос
  return step(stripeWidth, abs(sin(uv.x * frequency) + offset));
}

mat2 rotate2D(float angle){
  return mat2(
    cos(angle), -sin(angle),
    sin(angle), cos(angle)
  );
}

// Функция для генерации псевдо-случайного числа на основе позиции
float hash(float x) {
  return fract(sin(x) * 43758.5453);
}
float rand(float co) { return fract(sin(co*(91.3458)) * 47453.5453); }


void main() {
  // Предлагаемые цвета полос
  vec3 color1 = vec3(22.0/255.0, 24.0/255.0, 45.0/255.0);   // Тёмный цвет
  vec3 color2 = vec3(141.0/255.0, 62.0/255.0, 242.0/255.0); // Фиолетовый цвет
  vec3 color3 = vec3(254.0/255.0, 236.0/255.0, 34.0/255.0); // Жёлтый цвет

  vec3 backgroundColor = vec3(22.0/255.0, 24.0/255.0, 45.0/255.0); // Фоновый цвет
  // #16182d 22. 24. 45.
  // #8d3ef2 141. 62. 242.
  // #feec22 254. 236. 34.
  // vec3 accent = vec3(22./255., 24./255., 45./255.);
  // vec3 baseFirst = vec3(141./255., 62./255., 242./255.);
  // vec3 baseSecond = vec3(254./255., 236./255., 34./255.);

  // vec3 color1 = vec3(1., 0., 0.);
  // vec3 color2 = vec3(0., 1., 0.);
  // vec3 color3 = vec3(0., 0., 1.);

  // float n = noise(vPostion + time * 0.05);
  // // gl_FragColor = vec4(n, 0., 1.0, 1.0);
  // // vec2 baseUV = vPostion.xy;
  // vec2 baseUV = vUv*rotate2D(n)*0.9;
  // float basePattern = lines(baseUV, 0.15);
  // float secondPattern = lines(baseUV, 0.5);

  // vec3 baseColor = mix(baseFirst, baseSecond, basePattern);
  // vec3 secondBaseColor = mix(baseColor, accent, secondPattern);

  // gl_FragColor = vec4(vec3(secondBaseColor), 1.);
  // gl_FragColor = vec4(vec3(basePattern), 1.0);

  // еще вариант ///////////////////////////
  // vec3 stripeColor = vec3(141.0/255.0, 62.0/255.0, 242.0/255.0); // Фиксированный цвет полос
  // float n = noise(vPostion + time * 0.05);
  // vec2 baseUV = vUv * rotate2D(n) * 0.9;
  // float basePattern = lines(baseUV, 0.15);

  // // Используем один цвет для полос
  // gl_FragColor = vec4(stripeColor * basePattern, 1.0);

  // еще вариант ///////////////////////////
  // vec3 backgroundColor = vec3(141.0/255.0, 62.0/255.0, 242.0/255.0);  // Цвет полос
  // vec3 stripeColor = vec3(22.0/255.0, 24.0/255.0, 45.0/255.0); // Фоновый цвет

  // float n = noise(vPostion + time * 0.05);
  // vec2 baseUV = vUv * rotate2D(n) * 0.9;

  // // Определяем паттерн полос
  // float basePattern = lines(baseUV, 0.15);

  // // Если basePattern = 1.0, рисуем полосы; если 0.0, рисуем фон
  // vec3 color = mix(backgroundColor, stripeColor, basePattern);

  // // Устанавливаем цвет пикселя
  // gl_FragColor = vec4(color, 1.0);

  // еще вариант ///////////////////////////
    // Шум для рандомизации
  float n = noise(vPostion + time * 0.03);

  // Поворот UV-координат с шумом
  vec2 baseUV = vUv * rotate2D(n) * 0.9;

  // Настройка частоты полос и их ширины
  float frequency = 15.0;    // Количество полос
  float stripeWidth = 0.4;   // Ширина полос

  // Паттерн полос с управлением шириной полос
  float basePattern = step(stripeWidth, fract(baseUV.x * frequency));  // Чередуем полосы и фон

  float randomValue = rand(floor(baseUV.x * frequency));
  // Если это полоса (значение basePattern = 1), выбираем случайный цвет
  vec3 stripeColor;
  if (basePattern == 1.0) {
    // Генерация фиксированного случайного значения для каждой полосы на основе её позиции
    if (randomValue < 0.33) {
      stripeColor = color1;
    } else if (randomValue < 0.66) {
      stripeColor = color2;
    } else {
      stripeColor = color3;
    }
  } else {
    stripeColor = backgroundColor; // Если это не полоса, устанавливаем фоновый цвет
  }

  // Устанавливаем цвет пикселя
  gl_FragColor = vec4(stripeColor, 1.0);
}
