# 🌐 Plan de Implementación Multiplataforma: Polivet Pro (Android / iOS / Web / Windows)

> ⚠️ **Nota:** Este documento amplía el plan original con directrices específicas para garantizar compatibilidad nativa en **Android, iOS, Web y Windows**. Se mantiene el enfoque en procedimiento, arquitectura y validaciones. **No se incluye código**.

---

## 🧭 1. Estrategia Multiplataforma en Flutter
| Plataforma | Enfoque Técnico | Navegación | Input Principal | Optimización Clave |
|------------|----------------|------------|-----------------|---------------------|
| **Android** | Nativo (Kotlin/Java bridge) | `go_router` con transiciones Material | Táctil | `--split-per-abi`, ProGuard/R8, lazy loading |
| **iOS** | Nativo (Swift/Obj-C bridge) | `go_router` con transiciones Cupertino | Táctil | Bitcode deshabilitado, `Info.plist` permisos, App Thinning |
| **Web** | Compilación a JS/WASM + Canvas/HTML | `go_router` con `URL strategy` (path/hash) | Mouse/Teclado/Táctil | PWA, `--web-renderer canvaskit`, compresión Brotli/Gzip |
| **Windows** | Nativo (C++ runner + WinUI3) | `go_router` sin URL routing | Mouse/Teclado | MSIX packaging, DPI scaling, atajos de teclado |

---

## 🛠️ 2. Fase 0 Actualizada: Configuración Multiplataforma
1. **Habilitar plataformas en el proyecto:**
   - Ejecutar: `flutter create --platforms=android,ios,web,windows .`
   - Verificar estructura generada en `android/`, `ios/`, `web/`, `windows/`
2. **Validar entorno con `flutter doctor -v`:**
   - Android: SDK Manager, emuladores, licencias aceptadas
   - iOS: Xcode, CocoaPods, simuladores
   - Web: Chrome/Edge/Firefox, configuración de `index.html` base
   - Windows: Visual Studio 2022+, C++ Desktop Development, MSVC, Windows 10 SDK
3. **Configurar `pubspec.yaml` con compatibilidad cruzada:**
   - Evitar paquetes con dependencias nativas no soportadas en escritorio
   - Usar `conditional imports` o `dart:io` vs `dart:html` cuando sea necesario
4. **Estructura de assets cross-platform:**
   - Iconos y logos en `SVG` para escalabilidad infinita
   - Imágenes rasterizadas en `@1x`, `@2x`, `@3x` solo si es estrictamente necesario
   - Fuentes locales (`assets/fonts/`) con `pubspec` registrado

---

## 📦 3. Matriz de Compatibilidad de Dependencias
| Paquete | Android | iOS | Web | Windows | Notas de Implementación |
|---------|---------|-----|-----|---------|--------------------------|
| `firebase_core` | ✅ | ✅ | ✅ | ⚠️ | Oficialmente estable en Mobile/Web. En Windows requiere capa REST o plugin experimental |
| `firebase_auth` | ✅ | ✅ | ✅ | ⚠️ | Mismo caso. Se recomienda `http` + REST API Auth para escritorio |
| `cloud_firestore` | ✅ | ✅ | ✅ | ⚠️ | Streams no nativos en Windows. Fallback: REST + `StreamController` manual |
| `go_router` | ✅ | ✅ | ✅ | ✅ | Routing declarativo, soporta URL en Web, navegación nativa en móvil/escritorio |
| `provider` | ✅ | ✅ | ✅ | ✅ | 100% Dart, sin dependencias nativas |
| `flutter_svg` | ✅ | ✅ | ✅ | ✅ | Renderizado vectorial consistente |
| `flutter_form_builder` | ✅ | ✅ | ✅ | ✅ | Compatible con teclado físico/virtual |
| `intl` | ✅ | ✅ | ✅ | ✅ | Formateo regional sin restricciones |
| `uuid` | ✅ | ✅ | ✅ | ✅ | Generación de IDs segura en todas las plataformas |

> 🔍 **Decisión técnica recomendada:** Mantener Firebase como backend principal para **Android, iOS y Web**. Para **Windows**, implementar una capa de abstracción `DataRepository` que use Firebase en mobile/web y `http` + Firebase REST API en escritorio. Esto garantiza paridad funcional sin romper compilaciones.

---

## 🎨 4. UI/UX Adaptativo y Responsive
1. **Layout Dinámico por Breakpoints:**
   - `<600dp`: Columna única, navegación inferior (`BottomNavigationBar`), touch targets ≥48dp
   - `600-900dp`: Grid 2 columnas, `NavigationRail` opcional, hover states activados
   - `>900dp`: Grid 3-4 columnas, sidebar persistente, atajos de teclado (`Ctrl+S`, `Esc`, `Tab`)
2. **Componentes Responsivos:**
   - `Dashboard`: `GridView.builder` con `crossAxisCount` calculado vía `LayoutBuilder`
   - `Formularios`: `SingleChildScrollView` + `SafeArea` + `MediaQuery.viewInsets` para teclado virtual
   - `Listas`: `SliverAppBar` con búsqueda colapsable, `Dismissible` para swipe en móvil, hover en escritorio
3. **Consistencia Visual Cross-Platform:**
   - Material 3 como base, sin dependencias de `Cupertino` para evitar inconsistencias
   - Sombras y bordes redondeados (`BorderRadius.circular(16)`) aplicados uniformemente
   - Tipografía escalable con `MediaQuery.textScaler` y `ThemeData.textTheme`
4. **Accesibilidad y Feedback:**
   - Contraste validado (WCAG AA) para `#bc6c25` sobre `#fefae0`
   - Soporte para lectores de pantalla (`Semantics`, `Tooltip`)
   - Estados de carga y error consistentes (`CircularProgressIndicator`, `SnackBar`/`Toast` adaptable)

---

## 🔥 5. Integración Firebase Multiplataforma (Procedimiento)
1. **Configuración inicial:**
   - `flutterfire configure` → genera `firebase_options.dart` con configs por plataforma
   - En `web/index.html`: inyectar `<script>` de Firebase SDK si se requiere compatibilidad legacy
2. **Autenticación:**
   - Mobile/Web: `FirebaseAuth.instance` nativo
   - Windows: Servicio `FirebaseRestAuthService` con `http.post` a `https://identitytoolkit.googleapis.com/`
3. **Firestore:**
   - Mobile/Web: `FirebaseFirestore.instance.collection()` con `snapshots()`
   - Windows: `FirebaseRestFirestoreService` con endpoints REST (`/v1/projects/{id}/databases/{db}/documents/`) + polling o WebSockets si es viable
4. **Reglas de Seguridad:**
   - Configurar en Firebase Console: `allow read, write: if request.auth != null`
   - Validar tipos y límites en servidor (`match /{document=**}`)

---

## 📦 6. Compilación y Despliegue por Plataforma
| Plataforma | Comando de Build | Configuración Clave | Distribución |
|------------|------------------|---------------------|--------------|
| **Android** | `flutter build apk --release` | `minifyEnabled true`, `shrinkResources true`, `multiDex` si es necesario | Play Console (`.aab`), APK directa |
| **iOS** | `flutter build ios --release` | `Podfile` actualizado, `Info.plist` permisos, Bitcode off | App Store Connect (Xcode Archive) |
| **Web** | `flutter build web --release --web-renderer canvaskit` | `web/index.html` meta tags, PWA `manifest.json`, `service_worker` | Firebase Hosting, Vercel, Netlify, servidor estático |
| **Windows** | `flutter build windows --release` | `windows/runner/` DPI aware, icono `.ico`, `MSIX` signing | Microsoft Store, ejecutable `.msi`/`.exe`, GitHub Releases |

> 🔄 **CI/CD Opcional:** GitHub Actions o Codemagic con matrix build: `runs-on: [ubuntu-latest, macos-latest, windows-latest]`

---

## ✅ 7. Checklist de Validación Cross-Platform
- [ ] `flutter run` funciona en emulador Android, simulador iOS, navegador Chrome/Edge y ventana Windows
- [ ] Autenticación y registro persisten sesión en todas las plataformas
- [ ] CRUD completo sincronizado en tiempo real (mobile/web) y con fallback REST (windows)
- [ ] Navegación responde a redimensionado de ventana y cambios de orientación
- [ ] Formularios validan correctamente con teclado virtual y físico
- [ ] Iconos, fuentes y colores se renderizan sin distorsión en Web/Windows
- [ ] Compilación `--release` genera binarios funcionales sin errores de consola
- [ ] `flutter analyze` y `flutter test` pasan sin warnings críticos

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
