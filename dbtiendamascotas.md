# actua como un administrador de bases de datos: proyecto tienda de mascotas, que entidades se necesitan para su gestion
## Entidades para una Tienda de Mascotas

Como DBA, definiría las siguientes entidades agrupadas por módulo:

---

### 🐾 Núcleo del Negocio

**MASCOTA** — el corazón del sistema
`id, nombre, especie, raza, edad, sexo, peso, color, microchip, fecha_ingreso, estado`

**CLIENTE**
`id, nombre, apellido, email, teléfono, dirección, fecha_registro`

**PROVEEDOR**
`id, nombre_empresa, contacto, email, teléfono, dirección, RFC`

---

### 📦 Inventario y Productos

**PRODUCTO**
`id, nombre, descripción, precio_compra, precio_venta, stock, stock_mínimo, categoría_id, proveedor_id`

**CATEGORÍA_PRODUCTO**
`id, nombre` *(alimento, accesorio, medicamento, higiene…)*

**INVENTARIO_MOVIMIENTO**
`id, producto_id, tipo (entrada/salida/ajuste), cantidad, fecha, motivo, usuario_id`

---

### 💰 Ventas y Compras

**VENTA**
`id, cliente_id, empleado_id, fecha, subtotal, descuento, impuesto, total, método_pago, estado`

**DETALLE_VENTA**
`id, venta_id, producto_id, cantidad, precio_unitario, subtotal`

**COMPRA** *(a proveedor)*
`id, proveedor_id, empleado_id, fecha, total, estado`

**DETALLE_COMPRA**
`id, compra_id, producto_id, cantidad, precio_unitario, subtotal`

---

### 🏥 Servicios Veterinarios

**CITA**
`id, mascota_id, cliente_id, veterinario_id, fecha_hora, tipo_servicio, motivo, estado`

**HISTORIAL_MEDICO**
`id, mascota_id, veterinario_id, fecha, diagnóstico, tratamiento, observaciones`

**SERVICIO**
`id, nombre, descripción, precio, duración_min` *(baño, corte, consulta, vacuna…)*

**VENTA_SERVICIO**
`id, cita_id, servicio_id, precio, descuento`

---

### 👥 Recursos Humanos

**EMPLEADO**
`id, nombre, apellido, puesto, email, teléfono, salario, fecha_contrato, activo`

**PUESTO**
`id, nombre, descripción, permisos`

---

### 🔐 Sistema

**USUARIO**
`id, empleado_id, username, password_hash, rol, activo, último_acceso`

**AUDIT_LOG**
`id, usuario_id, tabla, acción, fecha, ip, datos_anteriores, datos_nuevos`

---

## Relaciones clave

```
CLIENTE ──< VENTA >── DETALLE_VENTA >── PRODUCTO
CLIENTE ──< MASCOTA ──< CITA >── SERVICIO
MASCOTA ──< HISTORIAL_MEDICO
PROVEEDOR ──< COMPRA >── DETALLE_COMPRA >── PRODUCTO
EMPLEADO ──< CITA (como veterinario)
EMPLEADO ──< VENTA (como cajero)
```

---

# proporciona con sus atributos y tipo en forma de tabla para cada una de las entidades
### tablas 
<img width="770" height="588" alt="image" src="https://github.com/user-attachments/assets/85d34562-3595-4e43-8b60-06182524d852" />
<img width="371" height="406" alt="image" src="https://github.com/user-attachments/assets/320679a9-e4a9-49a8-956d-2b963e20b5f9" />
<img width="692" height="571" alt="image" src="https://github.com/user-attachments/assets/05604aab-4eca-4db6-9183-47c9f11a7df3" />
<img width="360" height="399" alt="image" src="https://github.com/user-attachments/assets/3c840113-0b31-4976-930b-1a4e947fdc40" />
<img width="661" height="558" alt="image" src="https://github.com/user-attachments/assets/96739846-4432-49b5-816e-57be7529db8a" />
<img width="665" height="381" alt="image" src="https://github.com/user-attachments/assets/184d496e-80a1-4cae-86d1-5555427ca6af" />
<img width="664" height="368" alt="image" src="https://github.com/user-attachments/assets/aa9064e6-e101-4a09-ad1d-d40d130fae73" />
<img width="664" height="457" alt="image" src="https://github.com/user-attachments/assets/211a6073-f958-49cf-a212-aa3ee2936e8c" />
<img width="667" height="494" alt="image" src="https://github.com/user-attachments/assets/78072dc2-d60f-4a55-8060-89033a58a6c3" />
<img width="694" height="430" alt="image" src="https://github.com/user-attachments/assets/af47da48-ec75-463e-b8ad-93ee85457246" />


