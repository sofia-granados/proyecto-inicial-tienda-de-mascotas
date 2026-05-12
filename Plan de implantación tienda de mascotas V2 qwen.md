# 📋 Plan de Implementación Procedimental: Polivet Pro
**Stack:** Flutter + Dart | Firebase (Auth + Firestore) | Provider | Clean Architecture  
**Enfoque:** Procedimiento paso a paso (sin código) | Diseño minimalista y veterinario  
**Paleta Estricta:** `#bc6c25` (Primario), `#dda15e` (Acento), `#fefae0` (Fondo/Contraste)

---

## 🏗️ 0. Preparación del Entorno y Estructura Base
1. **Inicialización del Proyecto:** Crear proyecto Flutter con nombre `polivet_pro`. Configurar `pubspec.yaml` con dependencias base (`firebase_core`, `firebase_auth`, `cloud_firestore`, `provider`, `intl`, `cached_network_image`, `go_router`, `flutter_svg`).
2. **Estructura de Carpetas (Clean Architecture):** Organizar `lib/` en capas diferenciadas:
   - `core/`: Constantes, tema global (`app_theme.dart`), rutas, utilidades y extensiones.
   - `domain/`: Entidades puras, casos de uso y contratos de repositorios.
   - `data/`: Implementaciones de repositorios, modelos DTO (`fromMap`/`toMap`), y servicios Firebase.
   - `presentation/`: Providers (`ChangeNotifier`), pantallas (`screens/`), componentes reutilizables (`widgets/`).
   - `main.dart`: Punto de entrada, inicialización de Firebase y inyección de `MultiProvider`.
3. **Configuración Firebase Console:** 
   - Crear proyecto, registrar apps Android/iOS/Web.
   - Habilitar **Authentication** → Método: Correo/Contraseña.
   - Habilitar **Firestore Database** → Modo prueba inicial (luego se aplicarán reglas).
   - Configurar persistencia offline en cliente desde `FirebaseFirestore.instance.settings`.

---

## 🚀 FASE 1: Autenticación y Onboarding
### Paso 1.1: Diseño del Flujo de Bienvenida
- Crear `WelcomeScreen` con layout centrado, logo vectorial de Polivet y dos botones prominentes: "Iniciar Sesión" y "Crear Cuenta".
- Aplicar fondo `#fefae0`, botones con gradiente `#bc6c25` → `#dda15e` y bordes redondeados (18dp).
- Implementar navegación condicional: si ya existe sesión activa, saltar directamente al Dashboard.

### Paso 1.2: Pantalla de Login
- Diseñar formulario con campos: Correo electrónico, Nombre (solo para display/UI), Contraseña.
- Validar formato de email y longitud mínima de contraseña (≥6).
- Conectar botón "Ingresar" a `FirebaseAuth.signInWithEmailAndPassword`.
- Manejar estados de UI: botón deshabilitado durante carga, snackbars para errores (credenciales inválidas, red, etc.).
- Al éxito, almacenar estado en `AuthProvider` y navegar a Home.

### Paso 1.3: Pantalla de Registro
- Diseñar formulario con: Nombre, Apellidos, Fecha de Nacimiento (usar `showDatePicker`), Correo, Contraseña + Confirmación.
- Ejecutar `FirebaseAuth.createUserWithEmailAndPassword`.
- **Post-autenticación:** Crear documento en Firestore colección `users` con `uid` como ID, guardando nombre, apellidos, fecha de nacimiento, email, rol por defecto (`usuario`) y `createdAt`.
- Implementar verificación de correo opcional (`sendEmailVerification`) y manejo de errores de duplicado.

### Paso 1.4: Proveedor de Autenticación (`AuthProvider`)
- Extender `ChangeNotifier` para exponer: `User? currentUser`, `bool isLoading`, `String? errorMessage`, `bool isAuthenticated`.
- Inicializar listener de `FirebaseAuth.instance.authStateChanges()` para mantener sesión persistente entre reinicios.
- Centralizar métodos: `login()`, `register()`, `logout()`, `resetPassword()`.
- Inyectar en `main.dart` como primer proveedor global.

---

## 📂 FASE 2: Arquitectura de Datos (Firestore)
### Paso 2.1: Definición de Modelos y Entidades
- Crear clases Dart inmutables para cada módulo en `domain/entities/`:
  - `Mascota`: id, nombre, especie, raza, edad, peso, id_cliente, foto_url.
  - `Cliente`: id, nombre, apellidos, teléfono, email, dirección, mascotas_ids.
  - `Producto`: id, nombre, categoría, stock, precio, proveedor_id, activo.
  - `Proveedor`: id, nombre, contacto, email, teléfono, dirección.
  - `Venta`/`Compra`: id, fecha, total, cliente_id/empleado_id, lista_items.
  - `DetalleVenta`/`DetalleCompra`: id_documento, producto_id, cantidad, precio_unitario, subtotal.
  - `Cita`: id, fecha_hora, mascota_id, cliente_id, empleado_id, motivo, estado.
  - `HistorialMedico`: id, mascota_id, fecha, diagnóstico, tratamiento, empleado_id, notas.
  - `Empleado`: id, nombre, cargo_id, teléfono, email, activo.
  - `Puesto`: id, nombre, descripción, salario_base.
- Implementar `fromJson`/`toJson` y validaciones básicas en `data/models/`.

### Paso 2.2: Capa de Servicios y Repositorios
- Crear clases `FirestoreXxxService` en `data/datasources/` con métodos:
  - `streamAll()`: Retorna `Stream<List<Entity>>` usando `collection().snapshots()`.
  - `add()`, `update()`, `delete()`: Operaciones atómicas con `try/catch`.
  - `search()`: Consultas con `where()` y `orderBy()` para filtros.
- Implementar repositorios en `data/repositories/` que abstraigan la fuente de datos y manejen transformaciones modelo ↔ entidad.
- Configurar índices compuestos en Firebase Console para consultas frecuentes (ej: `citas` por `fecha_hora` + `estado`).

### Paso 2.3: Providers por Módulo
- Crear un `ChangeNotifier` por módulo (`PetProvider`, `InventoryProvider`, `SalesProvider`, etc.) en `presentation/providers/`.
- Cada proveedor debe:
  - Suscribirse al stream del servicio correspondiente.
  - Exponer listas filtradas, estado de carga y mensajes de error.
  - Manejar operaciones CRUD llamando al repositorio y actualizando estado local.
  - Implementar métodos de búsqueda y paginación virtual (`limit` + `startAfter`).
- Inyectar todos los proveedores en `MultiProvider` con `create: (_) => XxxProvider()` y `lazy: false` solo para los críticos.

### Paso 2.4: Reglas de Seguridad de Firestore
- Definir políticas en `firestore.rules`:
  - `users`: solo lectura/escritura por el propio `request.auth.uid`.
  - `mascotas`, `clientes`, `citas`, `historial_medico`: lectura para autenticados, escritura solo para empleados/admin.
  - `productos`, `proveedores`, `ventas`, `compras`, `empleados`, `puestos`: acceso restringido a rol `empleado` o `admin`.
- Probar reglas con Firebase Console Simulator antes de deploy.

---

## 🎨 FASE 3: Interfaz de Usuario (UI/UX)
### Paso 3.1: Sistema de Diseño Global (`AppTheme`)
- Configurar `ThemeData` con:
  - `primaryColor`: `#bc6c25`, `colorScheme.secondary`: `#dda15e`, `scaffoldBackgroundColor`: `#fefae0`.
  - Tipografía: `fontFamily` limpia (ej. `Inter` o `Poppins`), `headlineMedium`, `bodyLarge`, `labelLarge`.
  - `shape`: `RoundedRectangleBorder` con `borderRadius: 15-20` para cards y botones.
  - Botones: gradiente lineal `#bc6c25` → `#dda15e`, texto blanco, elevación sutil, estado `hover`/`pressed` con opacidad.
- Crear `custom_widgets/`: `PrimaryButton`, `SecondaryButton`, `InputField`, `LoadingIndicator`, `EmptyStateWidget`, `ConfirmDialog`.

### Paso 3.2: Dashboard Principal
- Diseñar `DashboardScreen` con `GridView.builder` (2 columnas en móvil, 3-4 en tablet).
- Cada celda es un `ModuleCard` que contiene:
  - Icono veterinario (jeringa, huella, caja, calendario, etc.) en color `#bc6c25`.
  - Título del módulo en `#dda15e` o `#bc6c25`.
  - Fondo crema `#fefae0` con sombra suave y bordes redondeados.
- Tap en card navega a la pantalla de lista del módulo correspondiente usando `go_router`.

### Paso 3.3: Sistema CRUD Universal (Patrón Consistente)
- **List Screen:** 
  - AppBar con título y botón flotante "+ Agregar".
  - Barra de búsqueda superior con debounce.
  - `ListView.builder` conectado al stream del Provider.
  - Filtros rápidos (ej: categoría, estado, stock bajo) con chips horizontales.
  - Swipe-to-delete o botón contextual con `ConfirmDialog`.
- **Form Screen (Crear/Editar):**
  - Layout vertical con `SingleChildScrollView`.
  - Campos dinámicos según entidad (Text, Dropdown, DatePicker, Numeric, ImageUpload).
  - Validación en tiempo real (`Form` + `TextFormField` validators).
  - Botón "Guardar" deshabilitado si hay errores o campos vacíos.
  - Mostrar `CircularProgressIndicator` durante operación asíncrona.
- **Delete Action:**
  - Modal estilizado con fondo semitransparente, icono de advertencia, texto explicativo y botones "Cancelar"/"Eliminar".
  - Ejecutar eliminación en Firestore, manejar error de red, actualizar lista local sin necesidad de recargar stream completo.

### Paso 3.4: Consistencia y Detalles Visuales
- Aplicar padding uniforme (`16` horizontal, `12` vertical entre elementos).
- Usar `Divider` sutil `#dda15e` con opacidad `0.3` para separar secciones.
- Implementar `Hero` animations para transiciones entre lista y detalle.
- Asegurar contraste WCAG AA: texto oscuro `#1a1a1a` sobre fondo `#fefae0`, texto blanco sobre botones primarios.

---

## 🛠️ FASE 4: Integración, Validación y Despliegue
### Paso 4.1: Enrutamiento y Protección de Rutas
- Configurar `GoRouter` con:
  - Rutas públicas: `/welcome`, `/login`, `/register`.
  - Rutas protegidas: `/dashboard`, `/pets`, `/inventory`, `/health`, `/staff`, `/commercial`.
  - `redirect`: verificar `AuthProvider.isAuthenticated`. Si false → `/welcome`.
  - Manejar estado de navegación con `RefreshIndicator` en listas.

### Paso 4.2: Manejo Global de Errores y Estados
- Implementar `ErrorBoundary` widget para capturar fallos de renderizado.
- Centralizar excepciones Firebase (`FirebaseAuthException`, `FirebaseFirestoreException`) en un `ErrorHandler` que mapee códigos a mensajes amigables en español.
- Usar `SnackBar` estilizado con colores de la paleta para feedback no intrusivo.

### Paso 4.3: Optimización y Rendimiento
- Aplicar `const` en widgets estáticos y `ValueListenableBuilder`/`Selector` para minimizar rebuilds.
- Implementar paginación real en listas grandes (cargar 20 items, scroll trigger para siguiente batch).
- Habilitar `cacheWidth`/`cacheHeight` en imágenes para reducir consumo de memoria.
- Ejecutar `flutter analyze` y corregir advertencias de rendimiento y accesibilidad.

### Paso 4.4: Pruebas y Validación
- **Unitarias:** Validación de modelos, lógica de cálculo en ventas/compras, estados de providers.
- **Widget:** Renderizado correcto de formularios, diálogos, tarjetas de dashboard, estados de carga/vacío.
- **Integración:** Flujo completo registro → login → agregar mascota → crear cita → eliminar producto.
- **Firebase:** Verificar que los datos se escriben/leen correctamente en consola, que las reglas de seguridad bloquean accesos no autorizados y que los streams actualizan UI en tiempo real.

### Paso 4.5: Preparación para Release
- Generar iconos adaptativos y splash screen con paleta oficial.
- Configurar `android/app/build.gradle` y `ios/Runner` para firma y minificación.
- Ejecutar `flutter build apk --release` y `flutter build ipa`.
- Documentar estructura, flujos y credenciales de desarrollo en `README.md` y `ARCHITECTURE.md`.
- Configurar Crashlytics y Analytics para monitoreo post-lanzamiento.

---

## ✅ Checklist de Validación Final
- [ ] Paleta `#bc6c25`, `#dda15e`, `#fefae0` aplicada consistentemente en todo el UI.
- [ ] Autenticación funcional con persistencia de sesión y creación de perfil en Firestore.
- [ ] 10 módulos implementados con CRUD completo y streams en tiempo real.
- [ ] Arquitectura limpia respetada: `presentation` → `domain` → `data` → `core`.
- [ ] Providers gestionan estado, carga, errores y notificaciones sin `setState` disperso.
- [ ] Formularios validados, diálogos de confirmación estilizados, navegación protegida.
- [ ] Reglas de Firestore activas y probadas.
- [ ] App compila sin errores, responde a <16ms/frame, sin memory leaks detectados.

---

📌 **Siguiente Paso:**  
Este plan está listo para ser ejecutado fase por fase. Cuando lo indiques, puedo generar **el código completo y funcional** para:
1. `pubspec.yaml` + estructura de carpetas exacta.
2. `AuthProvider` + pantallas de Login/Registro/Welcome.
3. Modelos, Servicios Firestore y Providers de los módulos principales.
4. Dashboard + Sistema CRUD Universal con la paleta estricta aplicada.

¿Por cuál fase deseas que comience la generación de código?
