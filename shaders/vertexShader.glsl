uniform float time;
varying vec2 vUv;
varying vec3 vPostion;

void main() {
  vUv = uv;  // Передаем стандартный атрибут uv в varying переменную
  vPostion = position;
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}
