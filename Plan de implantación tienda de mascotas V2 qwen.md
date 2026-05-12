# 📘 PLAN DE IMPLEMENTACIÓN TOTALMENTE FUNCIONAL: Polivet Pro (Flutter Multiplataforma)

> ⚠️ **Alcance:** Este documento es un **blueprint de ejecución exacta**. Sigue estos pasos en orden y obtendrás una aplicación 100% funcional, compilable y desplegable en Android, iOS, Web y Windows. **No contiene código**. Está diseñado para ser seguido por un desarrollador o equipo sin ambigüedades.

---

## 📋 0. PRE-REQUISITOS OBLIGATORIOS
| Elemento | Acción Requerida | Validación |
|----------|------------------|------------|
| **SDK** | Flutter `stable` ≥ 3.22, Dart ≥ 3.4 | `flutter --version` muestra canal estable |
| **IDE** | VS Code + Extensiones: `Flutter`, `Dart`, `Firebase`, `Error Lens` | `flutter doctor` sin críticos |
| **Plataformas** | Android SDK, Xcode (macOS), Visual Studio 2022+ (Windows), Chrome/Edge | `flutter devices` lista ≥1 dispositivo por plataforma |
| **Firebase** | Cuenta activa, Proyecto creado, Billing habilitado (Spark es suficiente) | Consola Firebase accesible con proyecto activo |
| **Control de Versiones** | Git instalado, repo inicializado | `git init` ejecutado, `.gitignore` generado |

---

## 🏗️ FASE 1: CONFIGURACIÓN BASE & ARQUITECTURA
### 🎯 Objetivo
Estructurar el proyecto con arquitectura escalable, tema global, router seguro y gestores de estado inicializados.

### 📝 Procedimiento Paso a Paso
1. Crear proyecto multiplataforma:  
   `flutter create polivet_pro --platforms=android,ios,web,windows`
2. Vincular Firebase:  
   `flutterfire configure` → Seleccionar proyecto → Habilitar `android, ios, web, windows` → Generar `firebase_options.dart`
3. Crear estructura de carpetas exacta:
   ```
   lib/
   ├── core/          # theme, constants, router, utils
   ├── domain/        # entities, repository_interfaces, usecases
   ├── data/          # models, repositories_impl, datasources
   ├── presentation/  # providers, screens, widgets
   └── main.dart
   ```
4. Configurar `pubspec.yaml`:
   - Agregar dependencias exactas: `firebase_core`, `firebase_auth`, `cloud_firestore`, `provider`, `go_router`, `flutter_svg`, `intl`, `uuid`, `collection`, `flutter_form_builder`, `form_builder_validators`, `fluttertoast`
   - Registrar fuentes: `assets/fonts/Poppins/` (Regular, Medium, SemiBold, Bold)
   - Registrar assets: `assets/icons/`, `assets/images/`
5. Definir `AppTheme` en `core/theme/`:
   - `primaryColor: #bc6c25`, `secondaryColor: #dda15e`, `backgroundColor: #fefae0`, `textColor: #3e2723`
   - `borderRadius: 16.0`, `cardElevation: 2`, `buttonGradient: linear-gradient(#bc6c25 → #dda15e)`
   - `textTheme` con jerarquía clara y `fontFamily: 'Poppins'`
6. Configurar `go_router`:
   - Rutas: `/welcome`, `/login`, `/register`, `/dashboard`, `/module/:name`
   - `redirect` lógico: si `!auth.isAuthenticated` → `/welcome`, si `auth.isAuthenticated` → `/dashboard`
   - `errorBuilder` para rutas no encontradas
7. Inicializar `MultiProvider` en `main.dart`:
   - `AuthProvider`, `PetProvider`, `ClientProvider`, `InventoryProvider`, `AppointmentProvider`, `SalesProvider`, `StaffProvider`
   - `Firebase.initializeApp()` antes de `runApp()`
   - `GoRouter` inyectado como dependencia global

### 📦 Entregables
- Estructura de carpetas creada
- `pubspec.yaml` configurado
- Tema global aplicado
- Router con redirección condicional
- Providers instanciados

### ✅ Criterios de Validación
- [ ] `flutter run -d chrome` compila sin warnings
- [ ] Tema se refleja en `Scaffold` base
- [ ] Router redirige correctamente según estado simulado
- [ ] `flutter analyze` muestra 0 errores críticos

---

## 🔐 FASE 2: AUTENTICACIÓN & ONBOARDING
### 🎯 Objetivo
Implementar registro, login, perfil de usuario y redirección segura con Firebase Auth + Firestore.

### 📝 Procedimiento Paso a Paso
1. **Firebase Console:**
   - Authentication → Sign-in method → Habilitar `Correo electrónico/Contraseña`
   - Firestore Database → Crear base → Modo `Pruebas` (luego cambiar a producción)
2. **Capa de Dominio & Datos:**
   - Definir entidad `UserEntity`: `uid`, `email`, `firstName`, `lastName`, `birthDate`, `createdAt`
   - Crear modelo `UserModel` con `fromJson`/`toJson` y validaciones de tipo
   - Interfaz `AuthRepository` con métodos: `signIn()`, `register()`, `signOut()`, `userStream()`
   - Implementación `FirebaseAuthRepository` usando `FirebaseAuth.instance` y `FirebaseFirestore.instance`
3. **Proveedor de Estado:**
   - `AuthProvider extends ChangeNotifier`
   - Estado: `isAuthenticated`, `isLoading`, `user`, `errorMessage`
   - Métodos: `login()`, `register()`, `logout()`, `listenAuthChanges()`
   - Usar `notifyListeners()` solo en cambios de estado relevantes
4. **Pantallas UI:**
   - `WelcomeScreen`: Logo centrado, ilustración veterinaria, botones `Iniciar Sesión` y `Crear Cuenta`
   - `LoginScreen`: Campos email, password. Validación en tiempo real. Botón con gradiente. Manejo de errores Firebase (`wrong-password`, `user-not-found`, `invalid-email`)
   - `RegisterScreen`: Campos nombre, apellidos, fecha nacimiento (DatePicker), email, password, confirmar password. Validación de longitud, formato email, coincidencia contraseñas. Al éxito: crear usuario en Auth → escribir documento en `users/{uid}` → redirigir a `/dashboard`
5. **Flujo de Sesión:**
   - Al iniciar app, `AuthProvider` escucha `authStateChanges`
   - Si token válido → redirige a dashboard
   - Si expirado/inválido → redirige a welcome
   - Implementar "Cerrar sesión" que limpie estado y navegue a `/welcome`

### 📦 Entregables
- Flujo completo de auth funcional
- Perfil de usuario persistido en Firestore
- Manejo de errores y estados de carga
- Redirección segura por rol/estado

### ✅ Criterios de Validación
- [ ] Registro crea usuario en Auth + documento en `users/`
- [ ] Login redirige al dashboard con datos cargados
- [ ] Contraseña incorrecta/email inválido muestra toast amigable
- [ ] Logout limpia sesión y redirige correctamente
- [ ] `flutter test` unitario para `AuthProvider` pasa

---

## 🗃️ FASE 3: ARQUITECTURA DE DATOS & CRUD EN TIEMPO REAL
### 🎯 Objetivo
Implementar modelos, repositorios y providers para las 10 entidades con sincronización Firestore.

### 📝 Procedimiento Paso a Paso
1. **Definir Esquemas Firestore:**
   - `pets`: `id`, `name`, `species`, `breed`, `birthDate`, `ownerId`, `createdAt`
   - `clients`: `id`, `firstName`, `lastName`, `email`, `phone`, `address`, `createdAt`
   - `products`: `id`, `name`, `category`, `price`, `stock`, `supplierId`, `isActive`
   - `suppliers`: `id`, `name`, `contact`, `phone`, `email`, `address`
   - `sales`: `id`, `clientId`, `date`, `total`, `status`, `details[]`
   - `purchases`: `id`, `supplierId`, `date`, `total`, `status`, `details[]`
   - `appointments`: `id`, `petId`, `date`, `time`, `type`, `status`, `notes`
   - `medicalRecords`: `id`, `petId`, `date`, `diagnosis`, `treatment`, `vetId`
   - `staff`: `id`, `name`, `role`, `phone`, `email`, `schedule`
   - `roles`: `id`, `name`, `permissions[]`
2. **Capa de Datos:**
   - Crear `FirestoreRepository<T>` genérico con: `create()`, `read()`, `update()`, `delete()`, `watchAll()`, `search()`
   - Implementar `QueryBuilders` para filtrado por campo, ordenamiento y límites
   - Manejar `FirebaseException` y mapear a `AppError` personalizado
3. **Providers por Módulo:**
   - Cada provider extiende `ChangeNotifier`
   - Estado: `items`, `isLoading`, `isSubmitting`, `error`, `searchQuery`, `filter`
   - Métodos: `loadItems()`, `addItem()`, `updateItem()`, `deleteItem()`, `search()`, `applyFilter()`
   - Usar `StreamSubscription` para `watchAll()` y cancelar en `dispose()`
4. **Reglas de Seguridad Firestore:**
   - Configurar en consola: `allow read, write: if request.auth != null && request.resource.data.keys().hasAll(['createdAt'])`
   - Validar tipos: `is string`, `is number`, `is timestamp`
   - Limitar por rol si se implementa más adelante

### 📦 Entregables
- 10 modelos serializables
- Repositorio genérico funcional
- 10 providers aislados por entidad
- Reglas de seguridad activas

### ✅ Criterios de Validación
- [ ] CRUD completo funciona en consola Firebase
- [ ] Actualizaciones se reflejan en <500ms en UI
- [ ] Búsqueda filtra correctamente sin recargar
- [ ] Eliminación pide confirmación y elimina documento
- [ ] `flutter analyze` sin warnings de memoria/fugas

---

## 🎨 FASE 4: INTERFAZ DE USUARIO & DASHBOARD RESPONSIVO
### 🎯 Objetivo
Construir UI consistente, adaptable a 4 plataformas, con navegación modular y componentes reutilizables.

### 📝 Procedimiento Paso a Paso
1. **Dashboard Principal:**
   - `GridView.builder` con `crossAxisCount` calculado vía `LayoutBuilder`
   - 6-8 módulos visibles inicialmente, navegación a `/module/:name`
   - Cada card: icono SVG, título, badge de estado, fondo `#fefae0`, borde `#dda15e`, sombra sutil
   - Hover effect en escritorio (escala 1.02, cambio opacidad)
2. **ListScreen Genérico:**
   - `SliverAppBar` con búsqueda colapsable
   - `SearchDelegate` integrado que actualiza `searchQuery` en provider
   - `ListView.builder` con `Dismissible` (móvil) / botón eliminar (escritorio)
   - Pull-to-refresh para recargar datos
   - Estado vacío con ilustración y CTA "Agregar primero"
3. **FormScreen Dinámico:**
   - Campos renderizados según esquema de entidad
   - Validación inline con `form_builder_validators`
   - Botones `Guardar` (gradiente) y `Cancelar`
   - Teclado virtual se ajusta con `MediaQuery.viewInsets`
   - Atajos de teclado en escritorio: `Ctrl+S` (guardar), `Esc` (cancelar)
4. **Componentes Reutilizables:**
   - `CustomButton`: gradiente, ripple effect, loading state
   - `CustomTextField`: border focused/unfocused, error text, prefix icon
   - `LoadingOverlay`: semitransparente, spinner centrado, bloquea interacción
   - `DeleteConfirmationDialog`: título, mensaje, botones `Eliminar`/`Cancelar` con colores semánticos
5. **Consistencia Visual:**
   - Todos los bordes `16px` (cards), `12px` (inputs), `20px` (botones)
   - Sombras: `box-shadow: 0 4px 12px rgba(188, 108, 37, 0.15)`
   - Texto: `Poppins`, contraste WCAG AA verificado
   - Iconos: temática veterinaria, formato SVG, escalado automático

### 📦 Entregables
- Dashboard responsivo
- 10 pantallas CRUD completas
- Biblioteca de widgets reutilizables
- Navegación fluida y accesible

### ✅ Criterios de Validación
- [ ] Dashboard se adapta a `320px`, `768px`, `1280px`
- [ ] Búsqueda filtra en <200ms sin bloquear UI
- [ ] Formularios validan correctamente en móvil y teclado físico
- [ ] Diálogos de eliminación bloquean interacción hasta respuesta
- [ ] `flutter run -d web` y `-d windows` renderizan sin distorsión

---

## 🌍 FASE 5: OPTIMIZACIÓN MULTIPLATAFORMA
### 🎯 Objetivo
Garantizar rendimiento nativo, compatibilidad de input y empaquetado en las 4 plataformas.

### 📝 Procedimiento Paso a Paso
1. **Web:**
   - `flutter build web --release --web-renderer canvaskit`
   - Agregar `web/manifest.json` con nombre, icono, tema, scope
   - Configurar `index.html`: meta viewport, favicon, PWA service worker (opcional)
   - Validar URL routing: `setUrlStrategy(PathUrlStrategy())`
2. **Windows:**
   - `windows/runner/win32_window.cpp`: habilitar DPI awareness (`DPI_AWARENESS_PER_MONITOR_AWARE`)
   - Configurar `MSIX` packaging: icono `.ico`, versión, firma digital (opcional)
   - Validar atajos de teclado y navegación con `Tab`/`Enter`
   - Ejecutar en Windows 10/11, resolución 1920x1080 y 1366x768
3. **Android/iOS:**
   - `android/app/build.gradle`: `minifyEnabled true`, `shrinkResources true`, `multiDex` si es necesario
   - `ios/Runner/Info.plist`: permisos de red, orientación, tema
   - Generar APK/AAB y IPA de prueba
4. **Rendimiento:**
   - Usar `const` en todos los widgets estáticos
   - `ListView.builder`/`GridView.builder` para listas dinámicas
   - `StreamProvider` solo para datos en tiempo real, `ChangeNotifierProvider` para formularios
   - Caché de imágenes con `flutter_cache_manager` si se agregan fotos de mascotas
   - Evitar `setState()` en árbol alto; usar `Provider.of<T>(context, listen: false)` en callbacks

### 📦 Entregables
- Builds funcionales por plataforma
- Configuraciones de empaquetado listas
- Métricas de rendimiento validadas

### ✅ Criterios de Validación
- [ ] Web carga en <3s en red 3G simulada
- [ ] Windows abre en <1.5s, redimensiona sin crash
- [ ] Android/iOS navegan a 60 FPS en scroll
- [ ] `flutter build apk/ios/web/windows --release` sin errores

---

## 🧪 FASE 6: PRUEBAS, SEGURIDAD & DESPLIEGUE
### 🎯 Objetivo
Validar funcionalidad, proteger datos y preparar distribución.

### 📝 Procedimiento Paso a Paso
1. **Pruebas:**
   - Unitarias: `AuthProvider`, `FirestoreRepository`, `Validators`
   - Widget: `LoginScreen`, `CustomForm`, `DashboardCard`
   - Integración: flujo completo `registro → login → crear mascota → ver en lista → editar → eliminar`
   - Ejecutar: `flutter test`, `flutter drive` o `integration_test`
2. **Seguridad:**
   - Actualizar reglas Firestore a modo producción
   - Validar entrada de datos en backend y frontend
   - Habilitar App Check (reCAPTCHA v3 para web, Play Integrity para Android, DeviceCheck para iOS)
   - No hardcodear claves; usar `flutter_dotenv` o variables de compilación
3. **Despliegue:**
   - **Web:** `firebase deploy --only hosting` o Vercel/Netlify
   - **Android:** Play Console → subida `.aab`, screenshots, política de privacidad
   - **iOS:** Xcode → Archive → App Store Connect, certificados, provisioning
   - **Windows:** Microsoft Store o distribuir `.msi`/`.exe` firmado
4. **Documentación:**
   - `README.md` con arquitectura, setup, dependencias, comandos de build
   - `.env.example` para variables sensibles
   - Guía de contribución y flujo Git

### 📦 Entregables
- Reportes de pruebas
- Reglas de seguridad activas
- Binarios listos para distribución
- Documentación técnica completa

### ✅ Criterios de Validación
- [ ] Cobertura de pruebas ≥ 70% en lógica crítica
- [ ] Reglas Firestore bloquean escrituras no autenticadas
- [ ] App Check activo en producción
- [ ] `flutter clean && flutter pub get && flutter build` exitoso en todas las plataformas

---

## 📊 CHECKLIST DE FUNCIONALIDAD TOTAL
| Módulo | Android | iOS | Web | Windows | Estado |
|--------|---------|-----|-----|---------|--------|
| Auth + Perfil | ✅ | ✅ | ✅ | ✅ | Listo para implementar |
| CRUD Mascotas/Clientes | ✅ | ✅ | ✅ | ✅ | Listo para implementar |
| CRUD Inventario/Proveedores | ✅ | ✅ | ✅ | ✅ | Listo para implementar |
| CRUD Ventas/Compras | ✅ | ✅ | ✅ | ✅ | Listo para implementar |
| CRUD Citas/Historial | ✅ | ✅ | ✅ | ✅ | Listo para implementar |
| Dashboard Responsivo | ✅ | ✅ | ✅ | ✅ | Listo para implementar |
| Builds --release | ✅ | ✅ | ✅ | ✅ | Listo para implementar |
| Pruebas Automatizadas | ✅ | ✅ | ✅ | ✅ | Listo para implementar |

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
