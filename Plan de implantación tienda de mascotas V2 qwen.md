# 📘 PLAN DE IMPLEMENTACIÓN TOTALMENTE FUNCIONAL: Polivet Pro (Flutter Multiplataforma)
> 🌍 **Localización:** 100% Español (UI, Base de Datos, Validaciones, Mensajes, Formatos)
> ⚠️ **Alcance:** Blueprint de ejecución exacta. Sigue los pasos en orden para obtener una aplicación compilable, funcional y completamente en español para Android, iOS, Web y Windows. **Sin código.**

---

## 📋 0. ESTRATEGIA DE LOCALIZACIÓN ESPAÑOLA (ES)
Para garantizar que **todos los datos y textos visibles** estén estrictamente en español, se aplicará la siguiente política transversal:

| Elemento | Política de Localización | Ejemplo |
|----------|--------------------------|---------|
| **Interfaz (UI)** | Cadenas centralizadas en `strings_es.dart` o constantes globales | `label_bienvenida: "Bienvenido a Polivet Pro"` |
| **Campos Firestore** | Nombres de colecciones y documentos en español, snake_case | `clientes/{uid}`, campo: `nombre_completo` |
| **Modelos Dart** | Propiedades y métodos en español | `class Cliente { String correo; }` |
| **Validaciones** | Mensajes de error en español nativo, sin anglicismos | `"El correo electrónico no tiene un formato válido"` |
| **Errores Firebase** | Mapeo explícito de códigos técnicos a frases en español | `wrong-password → "La contraseña ingresada es incorrecta."` |
| **Formatos** | `Locale('es', 'ES')` forzado. Fechas: `dd/MM/yyyy`, Hora: `HH:mm`, Moneda: `es_ES`/`es_MX` | `"13/05/2026 14:30"`, `"$ 1.250,00"` |
| **Estados Vacíos** | Ilustraciones + texto descriptivo + botón de acción en español | `"Aún no hay mascotas registradas. Agrega la primera aquí."` |

---

## 🏗️ FASE 1: CONFIGURACIÓN BASE & ARQUITECTURA
### 🎯 Objetivo
Estructurar el proyecto, forzar localización `es_ES`, configurar tema visual y enrutamiento seguro.

### 📝 Procedimiento Paso a Paso
1. Crear proyecto multiplataforma:  
   `flutter create polivet_pro --platforms=android,ios,web,windows`
2. Vincular Firebase:  
   `flutterfire configure` → Seleccionar proyecto → Generar `firebase_options.dart`
3. Crear estructura de carpetas:
   ```
   lib/
   ├── core/          # tema, constantes, router, utilidades, localizacion_es
   ├── domain/        # entidades_es, interfaces_repositorio, casos_uso
   ├── data/          # modelos_es, repositorios_impl, fuentes_datos
   ├── presentation/  # proveedores_es, pantallas_es, widgets_es
   └── main.dart
   ```
4. Configurar `pubspec.yaml`:
   - Dependencias: `firebase_core`, `firebase_auth`, `cloud_firestore`, `provider`, `go_router`, `flutter_svg`, `intl`, `uuid`, `collection`, `flutter_form_builder`, `form_builder_validators`, `fluttertoast`
   - Agregar `flutter_localizations` y `intl` para forzar idioma
   - Registrar fuentes: `assets/fonts/Poppins/` y activos: `assets/icons/`, `assets/images/`
5. Definir `AppTheme` en `core/tema/`:
   - `primario: #bc6c25`, `secundario: #dda15e`, `fondo: #fefae0`, `texto: #3e2723`
   - `radioBorde: 16.0`, `sombraTarjeta: 2`, `gradienteBoton: lineal(#bc6c25 → #dda15e)`
   - `tipografia: Poppins`, jerarquía clara
6. Configurar `go_router`:
   - Rutas: `/bienvenida`, `/inicio-sesion`, `/registro`, `/panel`, `/modulo/:nombre`
   - Redirección condicional: si `!auth.estaAutenticado` → `/bienvenida`, si sí → `/panel`
   - Forzar `Locale('es', 'ES')` en `MaterialApp.localizationsDelegates`
7. Inicializar `MultiProvider` en `main.dart`:
   - `ProveedorAutenticacion`, `ProveedorMascotas`, `ProveedorClientes`, `ProveedorInventario`, `ProveedorCitas`, `ProveedorVentas`, `ProveedorPersonal`
   - `Firebase.initializeApp()` antes de `runApp()`

### 📦 Entregables
- Estructura de carpetas creada
- `pubspec.yaml` configurado con soporte ES
- Tema global y localización forzada
- Router con redirección segura
- Proveedores instanciados

### ✅ Criterios de Validación
- [ ] `flutter run -d chrome` compila sin warnings
- [ ] Todo texto visible aparece en español
- [ ] Fechas y monedas siguen formato español
- [ ] Router redirige correctamente según estado
- [ ] `flutter analyze` muestra 0 errores críticos

---

## 🔐 FASE 2: AUTENTICACIÓN & ONBOARDING (100% ES)
### 🎯 Objetivo
Implementar registro, inicio de sesión, perfil y redirección segura con mensajes y validaciones en español.

### 📝 Procedimiento Paso a Paso
1. **Firebase Console:**
   - Autenticación → Método → Habilitar `Correo electrónico / Contraseña`
   - Firestore → Modo `Pruebas` (luego producción)
2. **Capa de Dominio & Datos:**
   - Entidad `Usuario`: `uid`, `correo`, `nombre`, `apellidos`, `fecha_nacimiento`, `creado_en`
   - Modelo `ModeloUsuario` con `fromJson`/`toJson` en español
   - Interfaz `RepositorioAutenticacion`: `iniciarSesion()`, `registrar()`, `cerrarSesion()`, `escucharCambios()`
   - Implementación `RepositorioFirebaseAuth` mapeando códigos de error a frases en español
3. **Proveedor de Estado:**
   - `ProveedorAutenticacion extends ChangeNotifier`
   - Estado: `estaAutenticado`, `cargando`, `usuario`, `mensajeError`
   - Métodos: `autenticar()`, `registrarUsuario()`, `salir()`, `observarSesion()`
4. **Pantallas UI (Español nativo):**
   - `PantallaBienvenida`: Logo centrado, ilustración veterinaria, botones `"Iniciar Sesión"` y `"Crear Cuenta"`
   - `PantallaInicioSesion`: Campos `"Correo electrónico"`, `"Contraseña"`. Validación: `"El correo es obligatorio"`, `"La contraseña debe tener al menos 8 caracteres"`. Botón `"Entrar"`
   - `PantallaRegistro`: Campos `"Nombre"`, `"Apellidos"`, `"Fecha de nacimiento"` (DatePicker), `"Correo electrónico"`, `"Contraseña"`, `"Confirmar contraseña"`. Validación: `"Los campos no coinciden"`, `"La fecha no puede ser futura"`. Al éxito: crear en Auth → documento en `usuarios/{uid}` → redirigir a `/panel`
5. **Mapeo de Errores Firebase (ES):**
   - `user-not-found` → `"No existe una cuenta con este correo."`
   - `wrong-password` → `"La contraseña ingresada es incorrecta."`
   - `email-already-in-use` → `"Este correo ya está registrado."`
   - `invalid-email` → `"El formato del correo no es válido."`
   - `weak-password` → `"La contraseña es demasiado débil."`
   - `network-request-failed` → `"Error de conexión. Verifica tu internet."`

### 📦 Entregables
- Flujo completo de autenticación funcional
- Perfil de usuario persistido en `usuarios/`
- Mensajes de error y validaciones en español
- Redirección segura por estado

### ✅ Criterios de Validación
- [ ] Registro crea documento en `usuarios/{uid}` con campos en español
- [ ] Login redirige al panel con datos cargados
- [ ] Errores muestran frases claras en español
- [ ] Cierre de sesión limpia estado y redirige a `/bienvenida`
- [ ] Pruebas unitarias de `ProveedorAutenticacion` pasan

---

## 🗃️ FASE 3: ARQUITECTURA DE DATOS & CRUD EN TIEMPO REAL (ES)
### 🎯 Objetivo
Implementar modelos, repositorios y proveedores para las 10 entidades con sincronización Firestore y nomenclatura 100% española.

### 📝 Procedimiento Paso a Paso
1. **Esquemas Firestore (Nombres en español):**
   - `mascotas`: `id`, `nombre`, `especie`, `raza`, `fecha_nacimiento`, `propietario_id`, `creado_en`
   - `clientes`: `id`, `nombre_completo`, `correo`, `telefono`, `direccion`, `creado_en`
   - `productos`: `id`, `nombre`, `categoria`, `precio`, `stock`, `proveedor_id`, `activo`
   - `proveedores`: `id`, `nombre_empresa`, `contacto`, `telefono`, `correo`, `direccion`
   - `ventas`: `id`, `cliente_id`, `fecha`, `total`, `estado`, `detalles[]`
   - `compras`: `id`, `proveedor_id`, `fecha`, `total`, `estado`, `detalles[]`
   - `citas`: `id`, `mascota_id`, `fecha`, `hora`, `tipo_servicio`, `estado`, `notas`
   - `historiales`: `id`, `mascota_id`, `fecha`, `diagnostico`, `tratamiento`, `veterinario_id`
   - `personal`: `id`, `nombre`, `puesto`, `telefono`, `correo`, `horario`
   - `puestos`: `id`, `nombre`, `permisos[]`
2. **Capa de Datos:**
   - `RepositorioFirestore<T>` genérico: `crear()`, `leer()`, `actualizar()`, `eliminar()`, `observarTodos()`, `buscar()`
   - `ConstructoresConsulta` para filtrado, ordenamiento y límites
   - Mapeo de `FirebaseException` a `ErrorAplicacion` con mensajes en español
3. **Proveedores por Módulo:**
   - Cada proveedor extiende `ChangeNotifier`
   - Estado: `elementos`, `cargando`, `enviando`, `error`, `consultaBusqueda`, `filtro`
   - Métodos: `cargarElementos()`, `agregarElemento()`, `actualizarElemento()`, `eliminarElemento()`, `buscar()`, `aplicarFiltro()`
   - `StreamSubscription` para `observarTodos()` y `cancelar()` en `dispose()`
4. **Reglas de Seguridad Firestore:**
   - `allow read, write: if request.auth != null && request.resource.data.keys().hasAll(['creado_en'])`
   - Validación de tipos: `es string`, `es number`, `es timestamp`
   - Restricción por rol si se escala

### 📦 Entregables
- 10 modelos serializables con nomenclatura ES
- Repositorio genérico funcional
- 10 proveedores aislados por entidad
- Reglas de seguridad activas y en español

### ✅ Criterios de Validación
- [ ] CRUD completo se refleja en consola Firebase
- [ ] Actualizaciones visibles en <500ms
- [ ] Búsqueda filtra sin recargar pantalla
- [ ] Eliminación solicita confirmación en español y borra documento
- [ ] `flutter analyze` sin fugas de memoria

---

## 🎨 FASE 4: INTERFAZ DE USUARIO & PANEL RESPONSIVO (ES)
### 🎯 Objetivo
Construir UI consistente, adaptable a 4 plataformas, con navegación modular y componentes reutilizables con textos 100% en español.

### 📝 Procedimiento Paso a Paso
1. **Panel Principal:**
   - `GridView.builder` con `crossAxisCount` calculado vía `LayoutBuilder`
   - 6-8 módulos visibles: `"Mascotas"`, `"Clientes"`, `"Inventario"`, `"Proveedores"`, `"Ventas"`, `"Citas"`, `"Historiales"`, `"Personal"`
   - Tarjetas: icono SVG, título en español, fondo `#fefae0`, borde `#dda15e`, sombra suave
   - Efecto hover en escritorio (escala 1.02, opacidad)
2. **PantallaLista Genérica:**
   - `SliverAppBar` con búsqueda colapsable (`placeholder: "Buscar por nombre, especie o categoría..."`)
   - Filtro integrado que actualiza `consultaBusqueda` en proveedor
   - `ListView.builder` con `Dismissible` (móvil) / botón `"Eliminar"` (escritorio)
   - Deslizar para refrescar
   - Estado vacío: ilustración + `"Aún no hay registros. Toca el botón + para agregar uno."`
3. **PantallaFormulario Dinámica:**
   - Campos renderizados según esquema de entidad
   - Validación inline: `"Este campo es obligatorio"`, `"Formato no válido"`, `"El precio debe ser mayor a 0"`
   - Botones `"Guardar"` (gradiente) y `"Cancelar"`
   - Teclado virtual se ajusta con `MediaQuery.viewInsets`
   - Atajos escritorio: `Ctrl+S` (guardar), `Esc` (cancelar)
4. **Componentes Reutilizables (Labels ES):**
   - `BotonPersonalizado`: `"Continuar"`, `"Editar"`, `"Eliminar"`, `"Volver"`
   - `CampoTextoPersonalizado`: etiquetas, texto de error, icono prefijo
   - `SuperposicionCarga`: `"Cargando información..."`, `"Procesando solicitud..."`
   - `DialogoConfirmacionEliminacion`: `"¿Estás seguro de eliminar este registro?"`, `"Esta acción no se puede deshacer."`
5. **Consistencia Visual:**
   - Bordes: `16px` (tarjetas), `12px` (campos), `20px` (botones)
   - Sombras: `box-shadow: 0 4px 12px rgba(188, 108, 37, 0.15)`
   - Tipografía: `Poppins`, contraste WCAG AA
   - Iconos: temática veterinaria, SVG, escalado automático

### 📦 Entregables
- Panel responsivo con navegación ES
- 10 pantallas CRUD completas
- Biblioteca de widgets reutilizables
- Navegación fluida y accesible

### ✅ Criterios de Validación
- [ ] Panel se adapta a `320px`, `768px`, `1280px`
- [ ] Búsqueda filtra en <200ms sin bloquear UI
- [ ] Formularios validan correctamente en móvil y teclado físico
- [ ] Diálogos de eliminación bloquean interacción hasta respuesta
- [ ] `flutter run -d web` y `-d windows` renderizan sin distorsión

---

## 🌍 FASE 5: OPTIMIZACIÓN MULTIPLATAFORMA (ES)
### 🎯 Objetivo
Garantizar rendimiento nativo, compatibilidad de input y empaquetado con localización persistente.

### 📝 Procedimiento Paso a Paso
1. **Web:**
   - `flutter build web --release --web-renderer canvaskit`
   - `web/manifest.json`: `"name": "Polivet Pro"`, `"short_name": "Polivet"`, `"lang": "es"`
   - `index.html`: meta viewport, favicon, service worker (opcional)
   - URL strategy: `PathUrlStrategy()` con rutas en español opcional (recomendado técnico: mantener rutas técnicas `/panel`)
2. **Windows:**
   - `windows/runner/`: DPI awareness `PER_MONITOR_AWARE`
   - Empaquetado `MSIX`: icono `.ico`, versión, firma
   - Validar navegación `Tab`/`Enter` y tooltips en español
   - Ejecutar en Windows 10/11, `1920x1080` y `1366x768`
3. **Android/iOS:**
   - `android/app/build.gradle`: `minifyEnabled true`, `shrinkResources true`
   - `ios/Runner/Info.plist`: permisos red, orientación, tema
   - Generar APK/AAB y IPA de prueba
4. **Rendimiento:**
   - `const` en widgets estáticos
   - `ListView.builder`/`GridView.builder`
   - `StreamProvider` solo datos en tiempo real, `ChangeNotifierProvider` para formularios
   - Caché imágenes con `flutter_cache_manager`
   - Evitar `setState()` en árbol alto

### 📦 Entregables
- Builds funcionales por plataforma
- Configuraciones de empaquetado listas
- Métricas de rendimiento validadas

### ✅ Criterios de Validación
- [ ] Web carga en <3s en red 3G simulada
- [ ] Windows abre en <1.5s, redimensiona sin fallo
- [ ] Android/iOS navegan a 60 FPS
- [ ] `flutter build apk/ios/web/windows --release` sin errores

---

## 🧪 FASE 6: PRUEBAS, SEGURIDAD & DESPLIEGUE
### 🎯 Objetivo
Validar funcionalidad, proteger datos y preparar distribución con localización verificada.

### 📝 Procedimiento Paso a Paso
1. **Pruebas:**
   - Unitarias: `ProveedorAutenticacion`, `RepositorioFirestore`, `ValidadoresES`
   - Widget: `PantallaInicioSesion`, `FormularioPersonalizado`, `TarjetaPanel`
   - Integración: flujo `"registro → inicio sesión → crear mascota → ver lista → editar → eliminar"`
   - Ejecutar: `flutter test`, `integration_test`
2. **Seguridad:**
   - Reglas Firestore a producción
   - Validación entrada datos frontend + backend
   - App Check (reCAPTCHA v3 web, Play Integrity Android, DeviceCheck iOS)
   - Variables sensibles en `flutter_dotenv` o compilación
3. **Despliegue:**
   - Web: Firebase Hosting / Vercel / Netlify
   - Android: Play Console (`.aab`), capturas, política privacidad ES
   - iOS: Xcode → Archive → App Store Connect, certificados, provisioning
   - Windows: Microsoft Store o `.msi`/`.exe` firmado
4. **Documentación (ES):**
   - `README.md` con arquitectura, configuración, dependencias, comandos de compilación
   - `.env.example`
   - Guía de contribución y flujo Git en español

### 📦 Entregables
- Reportes de pruebas
- Reglas de seguridad activas
- Binarios listos para distribución
- Documentación técnica completa en español

### ✅ Criterios de Validación
- [ ] Cobertura pruebas ≥ 70% en lógica crítica
- [ ] Reglas Firestore bloquean escrituras no autenticadas
- [ ] App Check activo en producción
- [ ] `flutter clean && flutter pub get && flutter build` exitoso en todas las plataformas

---

## 📊 CHECKLIST DE LOCALIZACIÓN & FUNCIONALIDAD TOTAL
| Módulo | Android | iOS | Web | Windows | Localización ES |
|--------|---------|-----|-----|---------|-----------------|
| Auth + Perfil | ✅ | ✅ | ✅ | ✅ | 100% ES (campos, errores, diálogos) |
| CRUD Mascotas/Clientes | ✅ | ✅ | ✅ | ✅ | 100% ES (coleccion, campos, validaciones) |
| CRUD Inventario/Proveedores | ✅ | ✅ | ✅ | ✅ | 100% ES |
| CRUD Ventas/Compras | ✅ | ✅ | ✅ | ✅ | 100% ES |
| CRUD Citas/Historial | ✅ | ✅ | ✅ | ✅ | 100% ES |
| Panel Responsivo | ✅ | ✅ | ✅ | ✅ | 100% ES (labels, placeholders, estados vacíos) |
| Builds --release | ✅ | ✅ | ✅ | ✅ | Locale `es_ES` forzado en `MaterialApp` |
| Pruebas Automatizadas | ✅ | ✅ | ✅ | ✅ | Validadores y mensajes en español |

---



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
