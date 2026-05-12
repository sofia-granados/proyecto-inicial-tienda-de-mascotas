Prompt para el Desarrollo de Polivet Pro
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
