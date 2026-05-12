# 📋 Plan de Implementación: Aplicación "Tienda de Mascotas"
**Stack:** Flutter + Dart | Firebase (Auth + Firestore) | Provider | VS Code / Android Studio  
**Formato:** Procedimiento paso a paso (sin código)  

> 📝 *Nota aclaratoria:* "Antigravity" no corresponde a un entorno de desarrollo reconocido para Flutter. Asumiré que te refieres a **Android Studio** o **Visual Studio Code**. El plan está optimizado para VS Code, pero es totalmente aplicable a Android Studio.

---

## 🛠️ 1. Herramientas y Entorno de Desarrollo Requeridas
| Categoría | Herramienta | Propósito |
|-----------|-------------|-----------|
| **IDE** | Visual Studio Code o Android Studio | Edición, depuración y ejecución |
| **SDK** | Flutter SDK + Dart SDK | Framework base y lenguaje |
| **Consola** | Firebase Console + Firebase CLI | Gestión de proyectos, autenticación y reglas |
| **Control de Versiones** | Git + GitHub/GitLab | Historial, ramas y colaboración |
| **Diseño** | Figma o Adobe XD | Prototipado, assets y guía de estilo |
| **Emuladores/Dispositivos** | Android Studio Emulator / iOS Simulator / Dispositivo físico | Pruebas multiplataforma |
| **Análisis de Rendimiento** | Flutter DevTools | Monitoreo de FPS, memoria y red |

---

## 🎨 2. Fase de Diseño UI/UX
1. **Definición de flujo de usuario:**  
   - Splash → Onboarding (opcional) → Login/Registro → Catálogo → Detalle producto → Carrito → Checkout → Perfil.
2. **Sistema de diseño:**  
   - Paleta de colores (tonos cálidos, verdes/naranjas para temática mascota).  
   - Tipografía legible y escalable (ej. Inter, Roboto o Poppins).  
   - Iconografía consistente (paquetes de íconos como `phosphor_flutter` o `lucide_icons`).
3. **Componentes reutilizables:**  
   - Tarjetas de producto, campos de formulario, botones primarios/secundarios, barras de navegación inferior, diálogos de confirmación.
4. **Responsividad y accesibilidad:**  
   - Soporte para tablet y modo oscuro.  
   - Contraste WCAG AA, tamaños de fuente dinámicos, etiquetas `Semantics` para lectores de pantalla.
5. **Exportación de assets:**  
   - Imágenes en `1x`, `2x`, `3x` (`.png` o `.webp`).  
   - Vectoriales en `.svg` o `.svg_flutter` compatible.

---

## 🔧 3. Configuración Inicial y Estructura del Proyecto
1. Crear proyecto Flutter con nombre y organización claros.
2. Configurar estructura de carpetas recomendada (Feature-First o Clean Architecture básica):
   ```
   lib/
   ├── core/          (constantes, temas, utilidades, rutas)
   ├── features/      (auth, home, products, cart, profile)
   ├── data/          (modelos, repositorios, servicios Firebase)
   ├── presentation/  (widgets, pantallas, proveedores Provider)
   └── main.dart      (punto de entrada, inicialización Firebase)
   ```
3. Configurar variables de entorno (no hardcodear claves de Firebase).
4. Activar formateo automático y linter en el IDE.
5. Inicializar repositorio Git con `.gitignore` oficial para Flutter.

---

## 📦 4. Dependencias para `pubspec.yaml`
*(Listado listo para agregar a la sección `dependencies`)*

| Paquete | Propósito |
|---------|-----------|
| `firebase_core` | Inicialización del SDK de Firebase |
| `firebase_auth` | Autenticación correo/contraseña |
| `cloud_firestore` | Base de datos Firestore y consultas |
| `provider` | Gestión de estado y inyección de dependencias |
| `flutter_riverpod` (opcional) | Alternativa moderna a Provider (si decides migrar) |
| `cached_network_image` | Carga y caché de imágenes de productos |
| `intl` | Formateo de fechas y monedas |
| `go_router` o `auto_route` | Enrutamiento tipado y gestión de navegación |
| `flutter_dotenv` | Manejo seguro de variables de entorno |
| `firebase_crashlytics` | Reporte de errores en producción |
| `firebase_analytics` | Métricas de uso y funnel de conversión |

> ⚠️ Mantén las versiones estables más recientes compatibles con tu SDK de Flutter. Usa `flutter pub outdated` para verificar.

---

## 🔐 5. Integración de Firebase y Autenticación
1. Crear proyecto en Firebase Console.
2. Registrar apps Android, iOS y Web; descargar/configurar archivos de credenciales (`google-services.json`, `GoogleService-Info.plist`).
3. Habilitar método de inicio de sesión: **Correo electrónico/Contraseña**.
4. Configurar reglas de acceso por defecto (se refinan en Fase 6).
5. Diseñar flujo de autenticación:
   - Validación de formularios (email válido, contraseña ≥ 6 caracteres).
   - Manejo de estados: cargando, éxito, error.
   - Persistencia de sesión automática de Firebase.
   - Flujo de recuperación de contraseña y verificación de email.
6. Centralizar lógica de auth en un proveedor (`AuthProvider`) para exponer estado a la UI.

---

## 🗃️ 6. Diseño e Implementación de Firestore
1. **Modelo de colecciones:**
   - `users`: UID, nombre, email, dirección, rol, fecha de registro.
   - `products`: ID, nombre, categoría, descripción, precio, stock, imagen URL, estado activo.
   - `categories`: ID, nombre, icono, orden.
   - `orders`: ID, UID usuario, lista de items, total, estado, fecha, dirección envío.
   - `cart` (opcional como subcolección de `users` o colección independiente con referencia a UID).
2. **Reglas de seguridad:**
   - Lectura de productos pública.
   - Escritura/lectura de perfil solo por el usuario autenticado.
   - Órdenes y carrito protegidos por `request.auth != null && request.auth.uid == resource.data.userId`.
3. **Optimización:**
   - Índices compuestos para filtros (categoría + precio + stock).
   - Paginación con `limit()` y `startAfter()`.
   - Activar persistencia offline en cliente para catálogos y carrito.
4. **Estrategia de datos:**
   - Separar lógica de acceso a Firestore en repositorios.
   - Usar streams para datos en tiempo real (carrito, estado de orden).
   - Usar consultas únicas (`get`) para detalles estáticos.

---

## 🧠 7. Arquitectura y Gestión de Estado con Provider
1. Implementar patrón **MVVM simplificado**:
   - **View:** Pantallas y widgets UI.
   - **ViewModel:** `ChangeNotifier` que maneja estado, llama a repositorios y notifica cambios.
   - **Model:** Clases Dart inmutables o `freezed` para representar datos de Firestore.
2. Proovedores principales:
   - `AuthProvider`: estado de sesión, métodos login/register/logout.
   - `ProductProvider`: carga, filtrado, paginación y búsqueda.
   - `CartProvider`: agregar, eliminar, actualizar cantidad, calcular total.
   - `ThemeProvider` (opcional): modo claro/oscuro y personalización.
3. Inyección en `main.dart` con `MultiProvider`.
4. Evitar `setState` para lógica de negocio; usar `Consumer` o `context.read()` para acciones sin reconstruir UI innecesaria.
5. Centralizar manejo de errores y estados de carga (`LoadingState`, `SuccessState`, `ErrorState`).

---

## 📱 8. Desarrollo de Pantallas y Flujo de Usuario
1. **Pantalla de Inicio/Splash:** Verifica estado de autenticación y redirige.
2. **Autenticación:** Formularios de login/registro con validación, mensajes de error amigables, enlace a recuperación.
3. **Catálogo Principal:** Grid de productos, barra de búsqueda, filtros por categoría/precio, indicador de stock.
4. **Detalle de Producto:** Galería de imágenes, descripción, selector de cantidad, botón agregar al carrito.
5. **Carrito de Compras:** Lista editable, resumen de costos, botón checkout, sincronización con Firestore.
6. **Perfil de Usuario:** Datos personales, historial de pedidos, cierre de sesión, configuración.
7. **Navegación:** `BottomNavigationBar` o `Drawer` con rutas protegidas (requieren auth) y públicas.
8. **Manejo de rutas:** Proteger rutas privadas con `redirect` basado en `AuthProvider`.

---

## 🧪 9. Pruebas, Optimización y Calidad
1. **Pruebas unitarias:** Validación de modelos, lógica de carrito, cálculo de totales.
2. **Pruebas de widgets:** Renderizado correcto de formularios, estados de carga, diálogos.
3. **Pruebas de integración:** Flujo completo login → catálogo → carrito → checkout simulado.
4. **Análisis estático:** `flutter analyze`, `dart format`, corrección de warnings.
5. **Perfilado:** 
   - Reducir rebuilds innecesarios con `Provider.of(context, listen: false)`.
   - Optimizar carga de imágenes (`CachedNetworkImage`, placeholders).
   - Verificar consumo de memoria en listas largas (usar `ListView.builder`).
6. **Monitoreo:** Integrar Crashlytics y Analytics para capturar fallos y métricas post-lanzamiento.

---

## 🚀 10. Despliegue y Publicación
1. **Configuración de firma:** Keystore Android, certificados iOS.
2. **Build release:** `flutter build apk --release`, `flutter build ipa`.
3. **Metadatos:** Capturas de pantalla, descripción, categorías, políticas de privacidad.
4. **Consolas de desarrollador:** Subir a Google Play Console y App Store Connect.
5. **CI/CD (opcional):** GitHub Actions o Codemagic para builds automáticos y pruebas.
6. **Post-lanzamiento:** Revisar crash reports, actualizar reglas de Firestore según feedback, planificar versiones iterativas.

---

## 💡 Notas y Buenas Prácticas para el Desarrollo
- ✅ **Nunca expongas claves de Firebase** en el repositorio; usa archivos `.env` y agrégalos al `.gitignore`.
- ✅ **Valida siempre en el cliente y en el servidor** (reglas de Firestore son la última línea de defensa).
- ✅ **Mantén los proveedores delgados**; la lógica compleja va en repositorios o casos de uso.
- ✅ **Usa nombres descriptivos** para archivos, variables y rutas; sigue convenciones `snake_case` y `PascalCase` según corresponda.
- ✅ **Documenta decisiones arquitectónicas** en un `ARCHITECTURE.md` dentro del proyecto.
- ✅ **Planifica escalabilidad:** Firestore tiene límites de escritura/ancho de banda; diseña agregaciones y lectura optimizada desde el día 1.

---

