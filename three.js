import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import RAPIER from "@dimforge/rapier3d-compat";
import vertexShader from "./shaders/vertexShader.glsl";
import fragmentShader from "./shaders/fragmentShader.glsl";
import { getRandomColor } from "./utils.js";
import { generateRandomGeometry } from "./generateGeo.js";
import MeshReflectorMaterial from "./MeshReflectorMaterial";
import { TextGeometry } from "three/addons/geometries/TextGeometry.js";
import { FontLoader } from "three/addons/loaders/FontLoader.js";

class Sketch {
  constructor(containerId) {
    this.container = document.getElementById(containerId);

    // Основные параметры
    this.width = this.container.clientWidth;
    this.height = this.container.clientHeight;

    this.scene = this.createScene();
    this.camera = this.createCamera();
    this.renderer = this.createRenderer();
    this.controls = this.addOrbitControls();
    this.gravity = null;
    this.world = null;
    this.RAPIER = null;
    this.cube = this.createCube();
    this.time = 0;
    this.textureLoader = new THREE.TextureLoader();

    this.font;
    this.textGeo;
    this.textMesh;
    this.mousePos = new THREE.Vector2(0, 0);

    this.minY = 0.3;
    this.maxY = 0.8;
    this.amplitude = (this.maxY - this.minY) / 2; // 0.25
    this.offset = this.minY + this.amplitude; // 0.3 + 0.25 = 0.55

    this.textMaterials = [
      new THREE.MeshPhongMaterial({ color: new THREE.Color('rgb(254, 236, 34)'), flatShading: true }), // front
      new THREE.MeshPhongMaterial({ color: new THREE.Color('rgb(141, 62, 242)') }), // side
    ];
    // Запускаем инициализацию
    this.init();
  }

  async init() {
    this.clock = new THREE.Clock();
    // Добавляем объекты на сцену
    this.addObjects();
    this.loadText();
    // Обработчики событий
    this.addEventListeners();

    // Добавляем освещение
    this.addLight();

    // Запуск анимации
    this.animate();
  }

  // Создание сцены
  createScene() {
    const scene = new THREE.Scene();
    // scene.background = new THREE.Color(0x0e0b2e);
    return scene;
  }

  // Создание камеры
  createCamera() {
    const fov = 75;
    const aspect = this.width / this.height;
    const near = 0.1;
    const far = 1000;
    const camera = new THREE.PerspectiveCamera(fov, aspect, near, far);
    camera.position.set(2, 1, 3);
    return camera;
  }

  // Создание рендера
  createRenderer() {
    const renderer = new THREE.WebGLRenderer({
      antialias: true,
      alpha: true,
    });
    renderer.setSize(this.width, this.height);

    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.outputColorSpace = THREE.SRGBColorSpace;
    renderer.outputEncoding = THREE.sRGBEncoding;

    if (this.container) {
      this.container.appendChild(renderer.domElement);
    } else {
      console.error(`Элемент с id "${this.container}" не найден.`);
    }

    return renderer;
  }

  async initPhysics() {
    this.RAPIER = await RAPIER.init();
    this.gravity = { x: 0.0, y: 0, z: 0.0 };
    this.world = new RAPIER.World(this.gravity);
  }

  addLight() {
    const hemiLight = new THREE.HemisphereLight(0x000000, 0x0e0b2e);
    this.scene.add(hemiLight);

    const light = new THREE.AmbientLight(0x404040); // soft white light
    // this.scene.add(light);

    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.5);
    this.scene.add(directionalLight);

    const pointLight = new THREE.PointLight( 0xffffff, 4.5, 0, 0 );
    pointLight.color.setHSL( Math.random(), 1, 0.5 );
    pointLight.position.set( 0, 100, 90 );
    // this.scene.add( pointLight );

  }

  createCube() {
    const WALL_HEIGHT = 4;
    const WALL_WIDTH = 10;
    this.material = new THREE.ShaderMaterial({
      extensions: {
        derivatives: "extension GL_OES_standard_derivatives : enable",
      },
      side: THREE.DoubleSide,
      uniforms: {
        time: { value: 0 },
      },
      transparent: false,
      // wireframe: true,
      blending: THREE.AdditiveBlending,
      fragmentShader: fragmentShader,
      vertexShader: vertexShader,
    });
    const geo = new THREE.PlaneGeometry(
      WALL_WIDTH,
      WALL_HEIGHT,
      10,
      10
    ).rotateY(Math.PI / 2);

    const mesh = new THREE.Mesh(geo, this.material);
    mesh.position.set(-1, WALL_HEIGHT / 2, 2);
    return mesh;
  }

  // Добавление OrbitControls
  addOrbitControls() {
    return new OrbitControls(this.camera, this.renderer.domElement);
  }

  loadText() {
    const loader = new FontLoader();

    // Загрузка шрифта асинхронно
    loader.load("./gentilis_regular.typeface.json", (font) => {
      this.font = font;
      this.createText();
    });
  }

  createText() {
    if (this.font) {
      const textGeometry = new TextGeometry("CAPSBOLD", {
        font: this.font,
        size: 0.3,
        depth: 0.2,
        curveSegments: 12,
        bevelEnabled: true,
        bevelThickness: 0.03,
        bevelSize: 0.02,
        bevelOffset: 0,
        bevelSegments: 5,
      });

      this.textMesh = new THREE.Mesh(textGeometry,this.textMaterials);

      // Добавляем текст на сцену
      this.textMesh.position.set(-1, 2, 2.7);
      this.textMesh.rotateY(Math.PI / 3);
      this.scene.add(this.textMesh);
    } else {
      console.log("Шрифт еще не загружен");
    }
  }

  addObjects() {
    this.scene.add(this.cube);
    this.plane = new THREE.Mesh(new THREE.PlaneGeometry(10, 10));
    this.plane.position.y = 0;
    this.plane.rotation.x = -Math.PI / 2;
    this.scene.add(this.plane);

    this.plane.material = new MeshReflectorMaterial(
      this.renderer,
      this.camera,
      this.scene,
      this.plane,
      {
        resolution: 1024,
        blur: [512, 128],
        mixBlur: 2.5,
        mixContrast: 1.5,
        mirror: 1,
      }
    );
    this.plane.material.setValues({
      roughnessMap: this.textureLoader.load("./roughness.jpg"),
      normalMap: this.textureLoader.load("./normal.png"),
      normalScale: new THREE.Vector2(0.3, 0.3),
    });

    const clonedCube = this.cube.clone();
    clonedCube.position.z = -1;
    clonedCube.rotateY(Math.PI / 2);
    // this.scene.add(clonedCube);
  }

  // Обработчик изменения размеров окна
  onWindowResize() {
    this.width = this.container.clientWidth;
    this.height = this.container.clientHeight;

    this.renderer.setSize(this.width, this.height);
    this.camera.aspect = this.width / this.height;
    this.camera.updateProjectionMatrix();
  }

  onMouseMove(evt) {
    this.mousePos.x = (evt.clientX / this.width) * 2 - 1;
    this.mousePos.y = -(evt.clientY / this.height) * 2 + 1;
  }

  // Добавление обработчиков событий
  addEventListeners() {
    window.addEventListener("resize", this.onWindowResize.bind(this));

    window.addEventListener("mousemove", this.onMouseMove.bind(this), false);
  }

  // Анимация
  animate() {
    requestAnimationFrame(this.animate.bind(this));
    this.time += 0.05;
    // this.controls.update();

    this.plane.material.update();
    if (this.textMesh) {
      this.textMesh.position.y = Math.sin(this.time * 0.25) * this.amplitude + this.offset;
      // this.textMesh.updateMatrixWorld();
      this.camera.lookAt(this.textMesh.position);
      // this.camera.updateMatrixWorld();
    }
    this.cube.material.uniforms.time.value = this.time;
    this.renderer.render(this.scene, this.camera);
  }
}

// Запуск инициализации, передаем id элемента
export default Sketch;

// Чтобы запустить, просто нужно создать экземпляр класса
// const sketch = new Sketch('canvas');
