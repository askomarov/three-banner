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
  return smoothstep(
    0., 0.5 + offset*0.5,
    0.5*abs((sin(uv.x*20.) + offset*2.))
  );
}


mat2 rotate2D(float angle){
  return mat2(
    cos(angle), -sin(angle),
    sin(angle), cos(angle)
  );
}

void main() {
  // #16182d 22. 24. 45.
  // #8d3ef2 141. 62. 242.
  // #feec22 254. 236. 34.
  vec3 accent = vec3(22./255., 24./255., 45./255.);
  vec3 baseFirst = vec3(141./255., 62./255., 242./255.);
  vec3 baseSecond = vec3(254./255., 236./255., 34./255.);

  vec3 color1 = vec3(1., 0., 0.);
  vec3 color2 = vec3(0., 1., 0.);
  vec3 color3 = vec3(0., 0., 1.);

  float n = noise(vPostion + time * 0.1);
  // gl_FragColor = vec4(n, 0., 1.0, 1.0);
  // vec2 baseUV = vPostion.xy;
  vec2 baseUV = vUv*rotate2D(n)*0.5;
  float basePattern = lines(baseUV, 0.15);
  float secondPattern = lines(baseUV, 0.4);

  vec3 baseColor = mix(baseFirst, baseSecond, basePattern);
  vec3 secondBaseColor = mix(baseColor, accent, secondPattern);

  gl_FragColor = vec4(vec3(secondBaseColor), 1.);
  // gl_FragColor = vec4(vec3(basePattern), 1.0);
}
