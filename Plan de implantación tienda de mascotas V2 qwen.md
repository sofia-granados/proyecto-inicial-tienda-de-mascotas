# 📋 Plan de Implementación: Polivet Pro (Tienda de Mascotas)

> ⚠️ **Nota:** Este documento contiene exclusivamente el procedimiento estructurado, arquitectura y directrices. No se incluye código fuente. La generación de código se realizará por fases en las siguientes iteraciones.

---

## 🛠️ 1. Herramientas y Entorno de Desarrollo Requerido
| Herramienta | Propósito | Configuración Recomendada |
|-------------|-----------|---------------------------|
| **VS Code** | Editor principal | Extensiones: `Flutter`, `Dart`, `Firebase`, `Error Lens`, `Pubspec Assist`, `Bloc` (opcional para snippets) |
| **Flutter SDK** | Framework multiplataforma | Canal `stable` (última versión LTS) |
| **Dart SDK** | Lenguaje de programación | Viene integrado con Flutter SDK |
| **Android Studio / Xcode** | Emuladores y compilación nativa | Android Studio (SDK Manager + AVD), Xcode (Simuladores iOS) |
| **Firebase CLI & Console** | Backend como servicio | Proyecto creado, Auth habilitado (Email/Password), Firestore en modo `production` o `test` según etapa |
| **Git** | Control de versiones | Flujo con ramas `main`, `dev`, `feature/*` |
| **Figma** (Opcional) | Diseño UI/UX y export de assets | Prototipo de pantallas, guía de estilos, iconos SVG |

---

## 📦 2. Dependencias Principales (`pubspec.yaml`)
Se organizarán por categoría funcional. Solo se listarán paquetes esenciales para cumplir los requerimientos:

| Categoría | Paquetes | Justificación |
|-----------|----------|---------------|
| **Core Firebase** | `firebase_core`, `firebase_auth`, `cloud_firestore` | Inicialización, autenticación, base de datos NoSQL |
| **Gestión de Estado** | `provider` | Inyección de lógica de negocio, notificación de cambios UI |
| **Navegación** | `go_router` | Enrutamiento declarativo, manejo de estados de auth/redirección |
| **Utilidades** | `intl`, `uuid`, `collection` | Formato de fechas/monedas, generación de IDs, utilidades de listas |
| **UI/UX** | `flutter_svg`, `flutter_slidable`, `fluttertoast` | Iconos vectoriales, gestos en listas, feedback visual |
| **Formularios/Validación** | `flutter_form_builder`, `form_builder_validators` | Construcción dinámica de formularios, reglas de validación |

---

## 🎨 3. Directrices de UI/UX y Sistema de Diseño
### 🎨 Paleta de Colores (Estricta)
- **Primario:** `#bc6c25` (Tierra profundo) → Botones principales, headers, acentos fuertes
- **Secundario/Acento:** `#dda15e` (Arena suave) → Iconos, badges, bordes, hover states
- **Fondo/Contraste:** `#fefae0` (Crema claro) → Background general, cards, modales
- **Texto:** `#3e2723` (Marrón oscuro) para legibilidad sobre crema, `#fefae0` para texto sobre primario

### 🖼️ Principios de Diseño
- **Formas:** Bordes redondeados entre `15dp` y `20dp` en cards, botones y diálogos
- **Sombras:** Suaves y difuminadas (`boxShadow` con opacidad ≤ 15%) para profundidad sin saturar
- **Gradientes:** Transiciones sutiles `#bc6c25 → #dda15e` en botones CTA y headers de módulos
- **Tipografía:** Familia sans-serif amigable (ej. `Poppins` o `Nunito`). Jerarquía clara: `Title > Subtitle > Body > Caption`
- **Iconografía:** Temática veterinaria (huellas, jeringas, calendarios, paquetes, usuarios). Formato SVG para escalabilidad
- **Feedback UX:** Estados de carga con `CircularProgressIndicator` personalizado, toasts para éxito/error, diálogos de confirmación antes de eliminación

---

## 🏗️ 4. Arquitectura del Proyecto (Clean Architecture + Provider)
```
lib/
├── core/               # Constantes, temas, utilidades globales, router
├── domain/             # Entidades puras, interfaces de repositorio, casos de uso
├── data/               # Modelos (fromJson/toJson), implementaciones de repositorios, fuentes de datos (Firebase)
├── presentation/       # Providers, screens, widgets reutilizables, componentes UI
└── main.dart           # Punto de entrada, configuración de MultiProvider, MaterialApp
```
- **State Management:** `ChangeNotifier` encapsulado en `Providers` por módulo (Auth, Mascotas, Inventario, Citas, Ventas, etc.)
- **Inyección:** Instanciación manual en `main.dart` o mediante `get_it` si se escala
- **Flujo de Datos:** UI → Provider → UseCase/Service → Firestore → Stream/Future → UI (reconstrucción controlada)

---

## 🚀 5. Procedimiento Paso a Paso (Fases de Desarrollo)

### 🔹 FASE 0: Configuración Inicial y Estructura
1. Crear proyecto Flutter en VS Code (`flutter create polivet_pro`)
2. Ejecutar `flutterfire configure` para vincular Firebase (Auth + Firestore)
3. Crear estructura de carpetas siguiendo Clean Architecture
4. Configurar `pubspec.yaml` con dependencias listadas y assets (iconos, logos, fuentes)
5. Definir `AppTheme` global con paleta de colores, tipografía y espaciados base
6. Configurar `go_router` con rutas protegidas por estado de autenticación

### 🔹 FASE 1: Autenticación y Onboarding
1. Habilitar `Email/Password` en Firebase Console
2. Crear entidad `UserEntity` y modelo `UserModel` con campos: nombre, apellidos, fecha nacimiento, email, uid
3. Implementar `AuthService` (registro, login, logout, escucha de stream de autenticación)
4. Crear `AuthProvider` con `ChangeNotifier` para exponer estado de sesión y perfil
5. Diseñar `WelcomeScreen` con logo, ilustración y botones `Iniciar Sesión` / `Crear Cuenta`
6. Desarrollar `LoginScreen` con validaciones en tiempo real y manejo de errores Firebase
7. Desarrollar `RegisterScreen` con `DatePicker` para fecha de nacimiento y validación de contraseña
8. Implementar redirección automática post-autenticación al Dashboard
9. Validar flujo completo sin conexión y con errores simulados

### 🔹 FASE 2: Arquitectura de Datos (Firestore)
1. Definir esquemas JSON para cada entidad: `Mascota`, `Cliente`, `Producto`, `Proveedor`, `Venta`, `Compra`, `Cita`, `HistorialMedico`, `Empleado`, `Puesto`
2. Crear modelos Dart con métodos `fromJson` / `toJson` y validaciones de campos obligatorios
3. Implementar `FirestoreService` genérico con métodos CRUD y escucha en tiempo real (`snapshots`)
4. Estructurar colecciones en Firestore:
   - `users/{uid}` → perfil principal
   - `pets`, `clients`, `inventory`, `suppliers`, `appointments`, `medical_records`, `sales`, `purchases`, `staff`, `roles`
5. Crear `Providers` individuales por módulo para aislar estados y notificaciones
6. Configurar reglas de seguridad básicas en Firestore (lectura/escritura autenticada, validación de tipos)
7. Implementar paginación o límites en listas grandes para optimizar rendimiento

### 🔹 FASE 3: Interfaz de Usuario y Dashboard CRUD
1. Construir `BaseScaffold` con AppBar personalizada, drawer opcional y bottom navigation si es necesario
2. Diseñar `DashboardScreen` con grid responsivo de cards por módulo (icono, título, badge de estado)
3. Crear componente `CustomCard` con gradientes, sombras y bordes redondeados según guía UI
4. Desarrollar `ListScreen` genérico reutilizable: `ListView.builder`, `SearchDelegate`, filtros por categoría/estado
5. Desarrollar `FormScreen` dinámico: campos según entidad, validación inline, botón guardar/editar
6. Implementar diálogos de confirmación estilizados para acciones destructivas (eliminar registro)
7. Integrar `fluttertoast` para feedback de éxito/error y `CircularProgressIndicator` para estados de carga
8. Aplicar temas de colores consistentes en todos los widgets y verificar contraste WCAG básico
9. Optimizar reconstrucciones UI con `Consumer`, `Selector` o `context.watch` selectivo

### 🔹 FASE 4: Integración, Testing y Entrega
1. Conectar Auth + Dashboard + CRUDs mediante `MultiProvider` en `main.dart`
2. Implementar manejo global de errores (try/catch, mensajes amigables, fallback UI)
3. Ejecutar pruebas unitarias de servicios y pruebas de widgets básicos (login, formulario, lista)
4. Configurar icono de app y splash screen (`flutter_launcher_icons`)
5. Verificar compilación limpia para Android (`flutter build apk`) y iOS (`flutter build ios`)
6. Documentar estructura, flujos y dependencias en `README.md`
7. Preparar checklist de release (permisos, versión, minSDK, targetSDK, optimización de assets)

---

## ✅ 6. Criterios de Aceptación y Validación
- [ ] Flujo de registro/login funcional con Firebase Auth y persistencia en Firestore
- [ ] CRUD completo para las 10 entidades con actualización en tiempo real
- [ ] Interfaz visual consistente con paleta `#bc6c25`, `#dda15e`, `#fefae0`
- [ ] Navegación segura y condicional basada en estado de autenticación
- [ ] Arquitectura modular y escalable (separación clara UI/Lógica/Datos)
- [ ] App compilada sin errores para al menos Android e iOS simulador
- [ ] Código organizado, comentado y listo para mantenimiento o extensión

---

## 🔜 Siguiente Paso
Este plan establece la base técnica, de diseño y procedimental completa. **Cuando estés listo, indícame por cuál fase deseas comenzar a generar el código** (ej. `Fase 1: Auth + Onboarding` o `Fase 0: Estructura + Configuración`). Entregaré el código modular, comentado y listo para copiar en VS Code, siguiendo estrictamente esta arquitectura y guías.
Prompt para el Desarrollo de Polivet Pro
Actúa como un Desarrollador Senior Experto en Flutter y Firebase. Tu misión es construir una aplicación veterinaria de alto rendimiento llamada Polivet, utilizando una arquitectura limpia (Clean Architecture) con Provider para la gestión de estado.El diseño debe ser minimalista, moderno y acogedor, utilizando estrictamente la siguiente paleta de colores:
Primario: #bc6c25 (Tierra profundo)
Secundario/Acentos: #dda15e (Arena suave)
Fondo/Contraste: #fefae0 (Crema claro)
 FASE 1: Autenticación y OnboardingDesarrolla el flujo inicial de usuario conectándolo directamente con Firebase Authentication:
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
 FASE 3: Interfaz de Usuario (UI/UX)Diseña la pantalla principal con un Dashboard Moderno que utilice Widgets personalizados para navegar a cada carpeta/módulo:
Dashboard de Widgets: Cada entidad (Mascotas, Inventario, Citas, etc.) debe representarse con un Card elegante que use los colores #dda15e y #bc6c25.
Sistema CRUD Universal:
List Screen: Una vista de lista con búsqueda y filtros para cada entidad.
Form Screen: Un formulario dinámico para Crear/Editar datos.
Delete Action: Diálogos de confirmación estilizados antes de borrar datos de Firestore.
Consistencia Visual: Usa bordes redondeados (15-20dp), tipografías claras y botones con gradientes sutiles entre los tonos café y arena.
 FASE 4: Requerimientos Técnicos FinalesUsa cloud_firestore para la persistencia de datos.Usa firebase_auth para la seguridad.Usa provider para inyectar la lógica de negocio en las pantallas.Asegúrate de que todas las imágenes o iconos sean coherentes con la temática veterinaria.Entrega el código organizado por carpetas (models, services, providers, screens, widgets) listo para ser ejecutado en Flutter
TOTALMENTE FUNCIONAL. 
