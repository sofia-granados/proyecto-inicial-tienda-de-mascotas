# 📘 PLAN DE IMPLEMENTACIÓN TOTALMENTE FUNCIONAL: Polivet Pro (18 Entidades | Flutter Multiplataforma | 100% ES)

> ⚠️ **Alcance:** Este documento es un **blueprint de ejecución exacta**. Sigue estos pasos en orden y obtendrás una aplicación 100% funcional, compilable y desplegable en Android, iOS, Web y Windows. **No contiene código**. Está diseñado para ser seguido por un desarrollador o equipo sin ambigüedades.

---

## 📋 0. PRE-REQUISITOS OBLIGATORIOS
| Elemento | Acción Requerida | Validación |
|----------|------------------|------------|
| **SDK** | Flutter `stable` ≥ 3.22, Dart ≥ 3.4 | `flutter --version` muestra canal estable |
| **IDE** | VS Code + Extensiones: `Flutter`, `Dart`, `Firebase`, `Error Lens` | `flutter doctor` sin ❌ críticos |
| **Plataformas** | Android SDK, Xcode (macOS), Visual Studio 2022+ (Windows), Chrome/Edge | `flutter devices` lista ≥1 dispositivo por plataforma |
| **Firebase** | Cuenta activa, Proyecto creado, Billing habilitado (Spark es suficiente) | Consola Firebase accesible con proyecto activo |
| **Control de Versiones** | Git instalado, repo inicializado | `git init` ejecutado, `.gitignore` generado |

---

## 🗃️ 1. ESQUEMA DE ENTIDADES & REQUISITOS OBLIGATORIOS (Firestore / NoSQL)
Se adapta el modelo relacional a Firestore mediante **documentos independientes, referencias por ID y arrays embebidos** para transacciones. Todos los campos y colecciones se nombran en español `snake_case`. Se definen explícitamente los campos obligatorios (`✅ Obligatorios`) y las reglas de validación por entidad.

| Colección Firestore | Campos | ✅ Requisitos Obligatorios & Validaciones |
|---------------------|--------|------------------------------------------|
| `usuarios` | `id, empleado_id, username, rol, activo, ultimo_acceso` | `username`, `rol`, `activo` son obligatorios. `id` = UID de Firebase Auth. `password_hash` **NO** se guarda (gestionado por Auth). |
| `mascotas` | `id, nombre, especie, raza, edad, sexo, peso, color, microchip, fecha_ingreso, estado` | `nombre`, `especie`, `propietario_id`, `estado` obligatorios. `peso` ≥ 0, `estado` ∈ ["activo", "inactivo", "fallecido"]. |
| `clientes` | `id, nombre, apellido, email, telefono, direccion, fecha_registro` | `nombre`, `apellido` obligatorios. Al menos `email` o `telefono` debe ser válido. Formato email y teléfono validado. |
| `proveedores` | `id, nombre_empresa, contacto, email, telefono, direccion, rfc` | `nombre_empresa`, `contacto`, `email`/`telefono` obligatorios. `rfc` opcional pero con formato válido si se proporciona. |
| `productos` | `id, nombre, descripcion, precio_compra, precio_venta, stock, stock_minimo, categoria_id, proveedor_id` | `nombre`, `precio_venta`, `stock`, `categoria_id` obligatorios. `precio_venta` > 0, `stock` ≥ 0, `stock_minimo` ≥ 0. |
| `categorias_producto` | `id, nombre` | `nombre` obligatorio. Debe ser único para evitar duplicados en UI. |
| `inventario_movimientos` | `id, producto_id, tipo, cantidad, fecha, motivo, usuario_id` | `producto_id`, `tipo` (entrada/salida/ajuste), `cantidad` (≠0), `fecha` obligatorios. Se escribe atómicamente con cada cambio de stock. |
| `ventas` | `id, cliente_id, empleado_id, fecha, subtotal, descuento, impuesto, total, metodo_pago, estado, detalles[]` | `cliente_id`, `fecha`, `total`, `metodo_pago`, `estado`, `detalles[]` obligatorios. `detalles[]` embebido: `[{producto_id, cantidad, precio_unitario, subtotal}]`. `total` = `subtotal - descuento + impuesto`. |
| `compras` | `id, proveedor_id, empleado_id, fecha, total, estado, detalles[]` | `proveedor_id`, `fecha`, `total`, `estado`, `detalles[]` obligatorios. Mismo patrón de array embebido que `ventas`. |
| `citas` | `id, mascota_id, cliente_id, veterinario_id, fecha_hora, tipo_servicio, motivo, estado` | `mascota_id`, `cliente_id`, `fecha_hora`, `tipo_servicio`, `estado` obligatorios. `fecha_hora` no puede ser pasada al crear. `estado` ∈ ["pendiente", "confirmada", "en_proceso", "completada", "cancelada"]. |
| `historiales_medicos` | `id, mascota_id, veterinario_id, fecha, diagnostico, tratamiento, observaciones` | `mascota_id`, `fecha`, `diagnostico` obligatorios. `diagnostico` y `tratamiento` máx. 1000 caracteres. |
| `servicios` | `id, nombre, descripcion, precio, duracion_min` | `nombre`, `precio` (>0), `duracion_min` (>0) obligatorios. Catálogo maestro referenciado por `ventas_servicios`. |
| `ventas_servicios` | `id, cita_id, servicio_id, precio, descuento` | `cita_id`, `servicio_id`, `precio` obligatorios. Vincula servicios prestados a citas. `descuento` ≥ 0. |
| `empleados` | `id, nombre, apellido, puesto, email, telefono, salario, fecha_contrato, activo` | `nombre`, `apellido`, `puesto`, `activo` obligatorios. `salario` ≥ 0, `email` formato válido. |
| `puestos` | `id, nombre, descripcion, permisos[]` | `nombre`, `permisos[]` obligatorios. `permisos[]` array de strings: `["crear_venta", "editar_cita", "ver_inventario", ...]`. |
| `audit_logs` | `id, usuario_id, tabla, accion, fecha, ip, datos_anteriores, datos_nuevos` | `usuario_id`, `tabla`, `accion`, `fecha` obligatorios. Solo escritura. Lectura restringida a roles administrativos. |

> 🔍 **Decisión Técnica:** Se prioriza **atomicidad en transacciones** (`ventas`, `compras`) con detalles embebidos, y **consultas cruzadas** (`mascota_id`, `cliente_id`, `empleado_id`) mediante referencias. Esto evita `N+1 queries` excesivos y mantiene Firestore dentro de límites de rendimiento.

---

## 🏗️ 2. ARQUITECTURA Y ESTRUCTURA DEL PROYECTO
```
lib/
├── core/               # tema, constantes_es, router, localizadores_es, utilidades
├── domain/             # entidades_es, interfaces_repositorio, casos_uso
├── data/               # modelos_es, repositorios_impl, fuentes_firestore
├── presentation/       # proveedores_es, pantallas_es, widgets_es
└── main.dart           # MultiProvider, Firebase init, MaterialApp(locale: es_ES)
```
- **State Management:** `ChangeNotifier` por módulo de negocio (`Auth`, `Negocio`, `Inventario`, `Finanzas`, `Veterinaria`, `RRHH`, `Sistema`)
- **Inyección:** Manual en `main.dart` o `get_it` si se escala
- **Flujo de Datos:** UI → Provider → Repositorio → Firestore → Stream/Future → UI
- **Localización:** Forzada a `Locale('es', 'ES')`. Sin fallback a inglés. Todos los `Strings`, validaciones y errores mapeados a español nativo.

---

## 🚀 3. PROCEDIMIENTO PASO A PASO (FASES 0-6)

### 🔹 FASE 0: CONFIGURACIÓN MULTIPLATAFORMA & LOCALIZACIÓN
1. Crear proyecto: `flutter create polivet_pro --platforms=android,ios,web,windows`
2. Vincular Firebase: `flutterfire configure` → generar `firebase_options.dart`
3. Configurar `pubspec.yaml` con dependencias exactas y `flutter_localizations` + `intl`
4. Forzar idioma en `MaterialApp`: `locale: const Locale('es', 'ES')`, `supportedLocales: [...]`, `localizationsDelegates: [...]`
5. Definir `AppTheme` con paleta `#bc6c25`, `#dda15e`, `#fefae0`, `#3e2723` y tipografía `Poppins`
6. Configurar `go_router` con rutas en español: `/bienvenida`, `/inicio-sesion`, `/registro`, `/panel`, `/modulo/:nombre`
7. Validar `flutter run` en Chrome, Windows y emulador Android sin warnings

### 🔹 FASE 1: AUTENTICACIÓN & ENTIDAD `USUARIOS`
1. Habilitar `Email/Password` en Firebase Auth
2. Crear modelo `Usuario` con campos exactos (excluyendo `password_hash`, gestionado por Auth)
3. Implementar `RepositorioAutenticacion`: `iniciarSesion()`, `registrar()`, `cerrarSesion()`, `escucharCambios()`
4. Mapear códigos Firebase a mensajes en español: `wrong-password` → `"Contraseña incorrecta."`, `email-already-in-use` → `"Este correo ya está registrado."`, etc.
5. Al registrar: crear en Auth → escribir documento en `usuarios/{uid}` → redirigir a `/panel`
6. `ProveedorAutenticacion` expone: `estaAutenticado`, `usuarioActual`, `cargando`, `error`
7. Validar flujo completo: registro → login → perfil cargado → logout → redirección

### 🔹 FASE 2: CAPA DE DATOS & MODELOS (18 ENTIDADES)
1. Crear modelos Dart para las 18 entidades, exactamente con los campos solicitados
2. Implementar `fromJson`/`toJson` con validaciones de tipo y **marcado explícito de campos obligatorios**
3. Configurar `RepositorioFirestore<T>` genérico: `crear()`, `leer()`, `actualizar()`, `eliminar()`, `observarTodos()`, `buscar()`
4. Manejar relaciones NoSQL:
   - `detalles` en `ventas`/`compras` → arrays de mapas
   - Referencias → campos `*_id` con resolución en cliente
   - Logs → escrituras atómicas via `FirebaseFirestore.instance.runTransaction()`
5. Crear `ConstructoresConsulta` para índices: `fecha_hora`, `estado`, `categoria_id`, `cliente_id`
6. Definir reglas de seguridad Firestore por colección (lectura/escritura autenticada + validación de tipos)

### 🔹 FASE 3: PROVIDERS & GESTIÓN DE ESTADO
1. Crear 7 proveedores agrupados por dominio:
   - `ProveedorAuth`, `ProveedorNegocio` (mascotas, clientes, proveedores)
   - `ProveedorInventario` (productos, categorías, movimientos)
   - `ProveedorFinanzas` (ventas, compras, detalles, servicios)
   - `ProveedorVeterinaria` (citas, historiales, ventas_servicios)
   - `ProveedorRRHH` (empleados, puestos)
   - `ProveedorSistema` (usuarios, audit_logs)
2. Cada provider expone: `elementos`, `cargando`, `enviando`, `error`, `consulta`, `filtro`
3. Métodos: `cargar()`, `agregar()`, `actualizar()`, `eliminar()`, `buscar()`, `aplicarFiltro()`
4. Suscribir `StreamSubscription` a colecciones relevantes y `cancelar()` en `dispose()`
5. Validar que cambios en Firestore se reflejen en <500ms sin reconstrucciones innecesarias

### 🔹 FASE 4: UI/UX & CRUD RESPONSIVO (100% ES)
1. **Panel Principal:** `GridView` con módulos: `Mascotas`, `Clientes`, `Inventario`, `Ventas`, `Compras`, `Citas`, `Historiales`, `Personal`, `Auditoría`
2. **Pantallas Lista:** `SliverAppBar` con búsqueda colapsable, filtros por `estado`, `categoria_id`, `fecha`
3. **Pantallas Formulario:**
   - Campos dinámicos según entidad
   - Validaciones en español: `"El stock no puede ser negativo"`, `"La fecha no puede ser anterior a hoy"`, `"Seleccione una categoría válida"`, etc.
   - Botones: `"Guardar"`, `"Cancelar"`, `"Eliminar"`
   - Para `ventas`/`compras`: botón `"Agregar detalle"` que inserta en array `detalles` con cálculo automático de `subtotal`
4. **Diálogos & Estados Vacíos:** Textos 100% ES, ilustraciones temáticas, confirmaciones de eliminación
5. **Consistencia Visual:** Bordes `16px` (tarjetas), `12px` (campos), `20px` (botones), gradientes `#bc6c25 → #dda15e`, sombras suaves
6. **Adaptabilidad:** `LayoutBuilder` para `crossAxisCount`, `MediaQuery` para teclado virtual, `Tab`/`Hover` para escritorio

### 🔹 FASE 5: OPTIMIZACIÓN MULTIPLATAFORMA
1. **Web:** `--web-renderer canvaskit`, `PathUrlStrategy`, `manifest.json` con `"lang": "es"`, PWA opcional
2. **Windows:** DPI aware, `MSIX` packaging, atajos `Ctrl+S`/`Esc`, navegación por teclado
3. **Android/iOS:** `minifyEnabled`, `shrinkResources`, `Info.plist` permisos, generación `.aab`/`.ipa`
4. **Rendimiento:** `const` widgets, `ListView.builder`, `StreamProvider` solo para datos en tiempo real, caché de imágenes, evitar `setState` en árbol alto
5. Validar compilación `--release` sin errores en las 4 plataformas

### 🔹 FASE 6: PRUEBAS, SEGURIDAD & DESPLIEGUE
1. **Pruebas:** Unitarias (repos, providers, validadores ES), Widget (login, formularios, listas), Integración (flujo completo)
2. **Seguridad:** Reglas Firestore a producción, App Check, validación cliente+servidor, variables sensibles en compilación
3. **Despliegue:** Firebase Hosting (Web), Play Console (Android), App Store Connect (iOS), Microsoft Store o `.msi` (Windows)
4. **Documentación:** `README.md` completo en español, guía de instalación, estructura, comandos de build, política de privacidad

---

## ✅ 4. CHECKLIST DE VALIDACIÓN CROSS-PLATFORM & LOCALIZACIÓN
| Entidad/Módulo | Android | iOS | Web | Windows | Localización ES |
|----------------|---------|-----|-----|---------|-----------------|
| Auth + `usuarios` | ✅ | ✅ | ✅ | ✅ | 100% ES (campos, errores, flujos) |
| `mascotas`, `clientes`, `proveedores` | ✅ | ✅ | ✅ | ✅ | Campos, labels, validaciones en ES |
| `productos`, `categorias`, `inventario_movimientos` | ✅ | ✅ | ✅ | ✅ | Moneda ES, fechas `dd/MM/yyyy` |
| `ventas`, `compras`, `detalles` | ✅ | ✅ | ✅ | ✅ | Cálculos atómicos, textos transaccionales ES |
| `citas`, `historiales`, `servicios`, `ventas_servicios` | ✅ | ✅ | ✅ | ✅ | Agendas, diagnósticos, estados en ES |
| `empleados`, `puestos`, `audit_logs` | ✅ | ✅ | ✅ | ✅ | Roles, permisos, logs en ES |
| Panel Responsivo | ✅ | ✅ | ✅ | ✅ | Grid adaptativo, hover/touch ES |
| Builds `--release` | ✅ | ✅ | ✅ | ✅ | Compilación limpia multiplataforma |
| Pruebas Automatizadas | ✅ | ✅ | ✅ | ✅ | Cobertura ≥70%, mensajes ES |





# Prompt para el Desarrollo de Polivet Pro
Actúa como un Desarrollador Senior Experto en Flutter y Firebase. Tu misión es construir una aplicación veterinaria de alto rendimiento llamada Polivet, utilizando una arquitectura limpia (Clean Architecture) con Provider para la gestión de estado.
necesito que sea funcional para flutter para android/web/ windows/IOS
El diseño debe ser minimalista, moderno y acogedor, utilizando estrictamente la siguiente paleta de colores:

Primario: #bc6c25 (Tierra profundo)

Secundario/Acentos: #dda15e (Arena suave)

Fondo/Contraste: #fefae0 (Crema claro)

 FASE 1: Autenticación y Onboarding
Desarrolla el flujo inicial de usuario conectándolo directamente con Firebase Authentication:

Welcome Screen: Una pantalla de bienvenida con el logo de Polivet que ofrezca dos opciones claras: "Iniciar Sesión" y "Crear Cuenta".

Login Screen: * Campos: Correo electrónico, Nombre y Contraseña.

Acción: Autenticar en Firebase y redirigir al Home.

Register Screen: * Campos: Nombre, Apellidos, Fecha de Nacimiento (DatePicker), Correo electrónico y Contraseña.

Acción: Registrar en Firebase Auth y crear un perfil de usuario adicional en la colección usuarios de Cloud Firestore.

 FASE 2: Arquitectura de Datos (Firestore)
Configura los Modelos, Servicios y Providers para manejar el CRUD completo de las siguientes entidades en Cloud Firestore. Cada cambio debe reflejarse en tiempo real en la consola de Firebase:

Módulos a implementar:

 Núcleo: MASCOTA (nombre, especie, raza, etc.) y CLIENTE (dueños).

 Inventario: PRODUCTO (stock, categoría, precio) y PROVEEDOR.

 Comercial: VENTA y COMPRA con sus respectivos detalles.

 Salud: CITA y HISTORIAL_MEDICO.

 Staff: EMPLEADO y PUESTO.

 FASE 3: Interfaz de Usuario (UI/UX)
Diseña la pantalla principal con un Dashboard Moderno que utilice Widgets personalizados para navegar a cada carpeta/módulo:

Dashboard de Widgets: Cada entidad (Mascotas, Inventario, Citas, etc.) debe representarse con un Card elegante que use los colores #dda15e y #bc6c25.

Sistema CRUD Universal:

List Screen: Una vista de lista con búsqueda y filtros para cada entidad.

Form Screen: Un formulario dinámico para Crear/Editar datos.

Delete Action: Diálogos de confirmación estilizados antes de borrar datos de Firestore.

Consistencia Visual: Usa bordes redondeados (15-20dp), tipografías claras y botones con gradientes sutiles entre los tonos café y arena.

 FASE 4: Requerimientos Técnicos Finales
Usa cloud_firestore para la persistencia de datos.

Usa firebase_auth para la seguridad.

Usa provider para inyectar la lógica de negocio en las pantallas.

Asegúrate de que todas las imágenes o iconos sean coherentes con la temática veterinaria.

Entrega el código organizado por carpetas (models, services, providers, screens, widgets) listo para ser ejecutado en Flutter

TOTALMENTE FUNCIONAL. 
