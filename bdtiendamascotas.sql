-- =============================================================
--  BASE DE DATOS: TIENDA DE MASCOTAS
--  Archivo  : bdtiendamascotas.sql
--  Motor    : PostgreSQL 15+
--  Creado   : 2026-05-12
--  Descripción: DDL completo con tablas, restricciones,
--               relaciones e índices de la tienda de mascotas.
-- =============================================================

-- Extensión para generar UUIDs
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================
--  ELIMINAR TABLAS SI EXISTEN (orden inverso a las FK)
-- =============================================================
DROP TABLE IF EXISTS audit_log              CASCADE;
DROP TABLE IF EXISTS usuario                CASCADE;
DROP TABLE IF EXISTS inventario_movimiento  CASCADE;
DROP TABLE IF EXISTS detalle_compra         CASCADE;
DROP TABLE IF EXISTS compra                 CASCADE;
DROP TABLE IF EXISTS venta_servicio         CASCADE;
DROP TABLE IF EXISTS detalle_venta          CASCADE;
DROP TABLE IF EXISTS venta                  CASCADE;
DROP TABLE IF EXISTS historial_medico       CASCADE;
DROP TABLE IF EXISTS cita                   CASCADE;
DROP TABLE IF EXISTS servicio               CASCADE;
DROP TABLE IF EXISTS producto               CASCADE;
DROP TABLE IF EXISTS categoria_producto     CASCADE;
DROP TABLE IF EXISTS mascota                CASCADE;
DROP TABLE IF EXISTS empleado               CASCADE;
DROP TABLE IF EXISTS puesto                 CASCADE;
DROP TABLE IF EXISTS cliente                CASCADE;
DROP TABLE IF EXISTS proveedor              CASCADE;

-- =============================================================
--  MÓDULO: NÚCLEO DEL NEGOCIO
-- =============================================================

CREATE TABLE cliente (
    id               UUID          NOT NULL DEFAULT gen_random_uuid(),
    nombre           VARCHAR(80)   NOT NULL,
    apellido         VARCHAR(80)   NOT NULL,
    email            VARCHAR(120)  NOT NULL,
    telefono         VARCHAR(20),
    direccion        TEXT,
    fecha_registro   DATE          NOT NULL DEFAULT CURRENT_DATE,
    activo           BOOLEAN       NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_cliente    PRIMARY KEY (id),
    CONSTRAINT uq_cli_email  UNIQUE (email)
);

COMMENT ON TABLE  cliente         IS 'Clientes registrados en la tienda';
COMMENT ON COLUMN cliente.activo  IS 'FALSE = cliente dado de baja';

-- ------------------------------------------------------------

CREATE TABLE proveedor (
    id              UUID         NOT NULL DEFAULT gen_random_uuid(),
    nombre_empresa  VARCHAR(120) NOT NULL,
    contacto        VARCHAR(100),
    email           VARCHAR(120),
    telefono        VARCHAR(20),
    direccion       TEXT,
    rfc             VARCHAR(15),
    activo          BOOLEAN      NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_proveedor   PRIMARY KEY (id),
    CONSTRAINT uq_prov_email  UNIQUE (email),
    CONSTRAINT uq_prov_rfc    UNIQUE (rfc)
);

COMMENT ON TABLE proveedor IS 'Proveedores de productos para la tienda';

-- ------------------------------------------------------------

CREATE TABLE mascota (
    id               UUID         NOT NULL DEFAULT gen_random_uuid(),
    cliente_id       UUID         NOT NULL,
    nombre           VARCHAR(60)  NOT NULL,
    especie          VARCHAR(40)  NOT NULL,
    raza             VARCHAR(60),
    fecha_nacimiento DATE,
    sexo             CHAR(1),
    peso_kg          DECIMAL(5,2),
    color            VARCHAR(40),
    microchip        VARCHAR(30),
    fecha_ingreso    DATE         NOT NULL DEFAULT CURRENT_DATE,
    estado           VARCHAR(20)  NOT NULL DEFAULT 'activo',

    CONSTRAINT pk_mascota        PRIMARY KEY (id),
    CONSTRAINT uq_mas_microchip  UNIQUE (microchip),
    CONSTRAINT fk_mas_cliente    FOREIGN KEY (cliente_id)
                                 REFERENCES cliente (id)
                                 ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_mas_sexo       CHECK (sexo IN ('M', 'F')),
    CONSTRAINT ck_mas_peso       CHECK (peso_kg > 0),
    CONSTRAINT ck_mas_estado     CHECK (estado IN ('activo', 'inactivo', 'fallecido'))
);

COMMENT ON TABLE mascota IS 'Mascotas registradas vinculadas a un cliente';

-- =============================================================
--  MÓDULO: RECURSOS HUMANOS
-- =============================================================

CREATE TABLE puesto (
    id           UUID        NOT NULL DEFAULT gen_random_uuid(),
    nombre       VARCHAR(60) NOT NULL,
    descripcion  TEXT,
    permisos     JSONB,

    CONSTRAINT pk_puesto    PRIMARY KEY (id),
    CONSTRAINT uq_pue_nombre UNIQUE (nombre)
);

COMMENT ON TABLE puesto IS 'Puestos de trabajo disponibles en la empresa';

-- ------------------------------------------------------------

CREATE TABLE empleado (
    id              UUID          NOT NULL DEFAULT gen_random_uuid(),
    puesto_id       UUID          NOT NULL,
    nombre          VARCHAR(80)   NOT NULL,
    apellido        VARCHAR(80)   NOT NULL,
    email           VARCHAR(120)  NOT NULL,
    telefono        VARCHAR(20),
    curp            VARCHAR(18),
    rfc             VARCHAR(15),
    salario         DECIMAL(10,2) NOT NULL,
    fecha_contrato  DATE          NOT NULL,
    activo          BOOLEAN       NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_empleado      PRIMARY KEY (id),
    CONSTRAINT uq_emp_email     UNIQUE (email),
    CONSTRAINT uq_emp_curp      UNIQUE (curp),
    CONSTRAINT uq_emp_rfc       UNIQUE (rfc),
    CONSTRAINT fk_emp_puesto    FOREIGN KEY (puesto_id)
                                REFERENCES puesto (id)
                                ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_emp_salario   CHECK (salario > 0)
);

COMMENT ON TABLE empleado IS 'Empleados de la tienda (incluye veterinarios y cajeros)';

-- =============================================================
--  MÓDULO: INVENTARIO Y PRODUCTOS
-- =============================================================

CREATE TABLE categoria_producto (
    id           UUID        NOT NULL DEFAULT gen_random_uuid(),
    nombre       VARCHAR(60) NOT NULL,
    descripcion  TEXT,

    CONSTRAINT pk_categoria      PRIMARY KEY (id),
    CONSTRAINT uq_cat_nombre     UNIQUE (nombre)
);

COMMENT ON TABLE categoria_producto IS 'Categorías de clasificación de productos';

-- ------------------------------------------------------------

CREATE TABLE producto (
    id              UUID          NOT NULL DEFAULT gen_random_uuid(),
    categoria_id    UUID          NOT NULL,
    proveedor_id    UUID,
    nombre          VARCHAR(120)  NOT NULL,
    descripcion     TEXT,
    codigo_barras   VARCHAR(30),
    precio_compra   DECIMAL(10,2) NOT NULL,
    precio_venta    DECIMAL(10,2) NOT NULL,
    stock           INT           NOT NULL DEFAULT 0,
    stock_minimo    INT           NOT NULL DEFAULT 5,
    unidad_medida   VARCHAR(20),
    activo          BOOLEAN       NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_producto        PRIMARY KEY (id),
    CONSTRAINT uq_pro_codigo      UNIQUE (codigo_barras),
    CONSTRAINT fk_pro_categoria   FOREIGN KEY (categoria_id)
                                  REFERENCES categoria_producto (id)
                                  ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_pro_proveedor   FOREIGN KEY (proveedor_id)
                                  REFERENCES proveedor (id)
                                  ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT ck_pro_precio_c    CHECK (precio_compra > 0),
    CONSTRAINT ck_pro_precio_v    CHECK (precio_venta > 0),
    CONSTRAINT ck_pro_stock       CHECK (stock >= 0)
);

COMMENT ON TABLE producto IS 'Catálogo de productos en venta';

-- ------------------------------------------------------------

CREATE TABLE inventario_movimiento (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    producto_id     UUID        NOT NULL,
    usuario_id      UUID        NOT NULL,
    tipo            VARCHAR(10) NOT NULL,
    cantidad        INT         NOT NULL,
    stock_anterior  INT         NOT NULL,
    stock_posterior INT         NOT NULL,
    fecha           TIMESTAMP   NOT NULL DEFAULT NOW(),
    motivo          TEXT,

    CONSTRAINT pk_inv_mov         PRIMARY KEY (id),
    CONSTRAINT fk_inv_producto    FOREIGN KEY (producto_id)
                                  REFERENCES producto (id)
                                  ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_inv_tipo        CHECK (tipo IN ('entrada', 'salida', 'ajuste')),
    CONSTRAINT ck_inv_cantidad    CHECK (cantidad != 0)
);

COMMENT ON TABLE inventario_movimiento IS 'Registro de cada movimiento de stock (entradas, salidas, ajustes)';

-- =============================================================
--  MÓDULO: VENTAS Y COMPRAS
-- =============================================================

CREATE TABLE venta (
    id             UUID          NOT NULL DEFAULT gen_random_uuid(),
    cliente_id     UUID,
    empleado_id    UUID          NOT NULL,
    folio          VARCHAR(20)   NOT NULL,
    fecha          TIMESTAMP     NOT NULL DEFAULT NOW(),
    subtotal       DECIMAL(12,2) NOT NULL DEFAULT 0,
    descuento      DECIMAL(12,2) NOT NULL DEFAULT 0,
    impuesto       DECIMAL(12,2) NOT NULL DEFAULT 0,
    total          DECIMAL(12,2) NOT NULL DEFAULT 0,
    metodo_pago    VARCHAR(20)   NOT NULL DEFAULT 'efectivo',
    estado         VARCHAR(15)   NOT NULL DEFAULT 'completada',
    observaciones  TEXT,

    CONSTRAINT pk_venta           PRIMARY KEY (id),
    CONSTRAINT uq_ven_folio       UNIQUE (folio),
    CONSTRAINT fk_ven_cliente     FOREIGN KEY (cliente_id)
                                  REFERENCES cliente (id)
                                  ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_ven_empleado    FOREIGN KEY (empleado_id)
                                  REFERENCES empleado (id)
                                  ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_ven_subtotal    CHECK (subtotal >= 0),
    CONSTRAINT ck_ven_total       CHECK (total >= 0),
    CONSTRAINT ck_ven_metodo      CHECK (metodo_pago IN ('efectivo', 'tarjeta', 'transferencia')),
    CONSTRAINT ck_ven_estado      CHECK (estado IN ('completada', 'cancelada', 'pendiente'))
);

COMMENT ON TABLE venta IS 'Cabecera de cada transacción de venta';

-- ------------------------------------------------------------

CREATE TABLE detalle_venta (
    id               UUID          NOT NULL DEFAULT gen_random_uuid(),
    venta_id         UUID          NOT NULL,
    producto_id      UUID          NOT NULL,
    cantidad         INT           NOT NULL,
    precio_unitario  DECIMAL(10,2) NOT NULL,
    descuento        DECIMAL(10,2) NOT NULL DEFAULT 0,
    subtotal         DECIMAL(12,2) NOT NULL,

    CONSTRAINT pk_det_venta       PRIMARY KEY (id),
    CONSTRAINT fk_dv_venta        FOREIGN KEY (venta_id)
                                  REFERENCES venta (id)
                                  ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_dv_producto     FOREIGN KEY (producto_id)
                                  REFERENCES producto (id)
                                  ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_dv_cantidad     CHECK (cantidad > 0),
    CONSTRAINT ck_dv_precio       CHECK (precio_unitario > 0),
    CONSTRAINT ck_dv_subtotal     CHECK (subtotal >= 0)
);

COMMENT ON TABLE detalle_venta IS 'Líneas de producto de cada venta';

-- ------------------------------------------------------------

CREATE TABLE compra (
    id             UUID          NOT NULL DEFAULT gen_random_uuid(),
    proveedor_id   UUID          NOT NULL,
    empleado_id    UUID          NOT NULL,
    folio          VARCHAR(20)   NOT NULL,
    fecha          TIMESTAMP     NOT NULL DEFAULT NOW(),
    total          DECIMAL(12,2) NOT NULL DEFAULT 0,
    estado         VARCHAR(15)   NOT NULL DEFAULT 'recibida',
    observaciones  TEXT,

    CONSTRAINT pk_compra          PRIMARY KEY (id),
    CONSTRAINT uq_com_folio       UNIQUE (folio),
    CONSTRAINT fk_com_proveedor   FOREIGN KEY (proveedor_id)
                                  REFERENCES proveedor (id)
                                  ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_com_empleado    FOREIGN KEY (empleado_id)
                                  REFERENCES empleado (id)
                                  ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_com_total       CHECK (total >= 0),
    CONSTRAINT ck_com_estado      CHECK (estado IN ('recibida', 'pendiente', 'cancelada'))
);

COMMENT ON TABLE compra IS 'Órdenes de compra realizadas a proveedores';

-- ------------------------------------------------------------

CREATE TABLE detalle_compra (
    id               UUID          NOT NULL DEFAULT gen_random_uuid(),
    compra_id        UUID          NOT NULL,
    producto_id      UUID          NOT NULL,
    cantidad         INT           NOT NULL,
    precio_unitario  DECIMAL(10,2) NOT NULL,
    subtotal         DECIMAL(12,2) NOT NULL,

    CONSTRAINT pk_det_compra      PRIMARY KEY (id),
    CONSTRAINT fk_dc_compra       FOREIGN KEY (compra_id)
                                  REFERENCES compra (id)
                                  ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_dc_producto     FOREIGN KEY (producto_id)
                                  REFERENCES producto (id)
                                  ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_dc_cantidad     CHECK (cantidad > 0),
    CONSTRAINT ck_dc_precio       CHECK (precio_unitario > 0),
    CONSTRAINT ck_dc_subtotal     CHECK (subtotal >= 0)
);

COMMENT ON TABLE detalle_compra IS 'Líneas de producto de cada orden de compra';

-- =============================================================
--  MÓDULO: SERVICIOS VETERINARIOS
-- =============================================================

CREATE TABLE servicio (
    id            UUID          NOT NULL DEFAULT gen_random_uuid(),
    nombre        VARCHAR(80)   NOT NULL,
    descripcion   TEXT,
    precio        DECIMAL(10,2) NOT NULL,
    duracion_min  INT,
    activo        BOOLEAN       NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_servicio      PRIMARY KEY (id),
    CONSTRAINT uq_ser_nombre    UNIQUE (nombre),
    CONSTRAINT ck_ser_precio    CHECK (precio > 0),
    CONSTRAINT ck_ser_duracion  CHECK (duracion_min > 0)
);

COMMENT ON TABLE servicio IS 'Catálogo de servicios ofrecidos (baño, consulta, vacuna, etc.)';

-- ------------------------------------------------------------

CREATE TABLE cita (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    mascota_id      UUID        NOT NULL,
    veterinario_id  UUID        NOT NULL,
    servicio_id     UUID        NOT NULL,
    fecha_hora      TIMESTAMP   NOT NULL,
    motivo          TEXT,
    estado          VARCHAR(15) NOT NULL DEFAULT 'pendiente',
    notas           TEXT,

    CONSTRAINT pk_cita            PRIMARY KEY (id),
    CONSTRAINT fk_cit_mascota     FOREIGN KEY (mascota_id)
                                  REFERENCES mascota (id)
                                  ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cit_veterinario FOREIGN KEY (veterinario_id)
                                  REFERENCES empleado (id)
                                  ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cit_servicio    FOREIGN KEY (servicio_id)
                                  REFERENCES servicio (id)
                                  ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_cit_estado      CHECK (estado IN ('pendiente', 'confirmada', 'completada', 'cancelada'))
);

COMMENT ON TABLE cita IS 'Agenda de citas veterinarias y de estética';

-- ------------------------------------------------------------

CREATE TABLE historial_medico (
    id               UUID          NOT NULL DEFAULT gen_random_uuid(),
    mascota_id       UUID          NOT NULL,
    veterinario_id   UUID          NOT NULL,
    cita_id          UUID,
    fecha            DATE          NOT NULL DEFAULT CURRENT_DATE,
    peso_kg          DECIMAL(5,2),
    temperatura      DECIMAL(4,1),
    diagnostico      TEXT          NOT NULL,
    tratamiento      TEXT,
    medicamentos     TEXT,
    proxima_cita     DATE,
    observaciones    TEXT,

    CONSTRAINT pk_historial         PRIMARY KEY (id),
    CONSTRAINT fk_his_mascota       FOREIGN KEY (mascota_id)
                                    REFERENCES mascota (id)
                                    ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_his_veterinario   FOREIGN KEY (veterinario_id)
                                    REFERENCES empleado (id)
                                    ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_his_cita          FOREIGN KEY (cita_id)
                                    REFERENCES cita (id)
                                    ON UPDATE CASCADE ON DELETE SET NULL
);

COMMENT ON TABLE historial_medico IS 'Expediente médico por mascota y consulta';

-- ------------------------------------------------------------

CREATE TABLE venta_servicio (
    id           UUID          NOT NULL DEFAULT gen_random_uuid(),
    cita_id      UUID          NOT NULL,
    servicio_id  UUID          NOT NULL,
    venta_id     UUID,
    precio       DECIMAL(10,2) NOT NULL,
    descuento    DECIMAL(10,2) NOT NULL DEFAULT 0,
    total        DECIMAL(10,2) NOT NULL,

    CONSTRAINT pk_venta_servicio    PRIMARY KEY (id),
    CONSTRAINT fk_vs_cita           FOREIGN KEY (cita_id)
                                    REFERENCES cita (id)
                                    ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_vs_servicio       FOREIGN KEY (servicio_id)
                                    REFERENCES servicio (id)
                                    ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_vs_venta          FOREIGN KEY (venta_id)
                                    REFERENCES venta (id)
                                    ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT ck_vs_precio         CHECK (precio > 0),
    CONSTRAINT ck_vs_total          CHECK (total >= 0)
);

COMMENT ON TABLE venta_servicio IS 'Cobro de servicios vinculado a cita y ticket de venta';

-- =============================================================
--  MÓDULO: SISTEMA Y SEGURIDAD
-- =============================================================

CREATE TABLE usuario (
    id                UUID        NOT NULL DEFAULT gen_random_uuid(),
    empleado_id       UUID        NOT NULL,
    username          VARCHAR(40) NOT NULL,
    password_hash     VARCHAR(255) NOT NULL,
    rol               VARCHAR(20) NOT NULL DEFAULT 'cajero',
    activo            BOOLEAN     NOT NULL DEFAULT TRUE,
    ultimo_acceso     TIMESTAMP,
    intentos_fallidos INT         NOT NULL DEFAULT 0,

    CONSTRAINT pk_usuario         PRIMARY KEY (id),
    CONSTRAINT uq_usr_empleado    UNIQUE (empleado_id),
    CONSTRAINT uq_usr_username    UNIQUE (username),
    CONSTRAINT fk_usr_empleado    FOREIGN KEY (empleado_id)
                                  REFERENCES empleado (id)
                                  ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_usr_rol         CHECK (rol IN ('admin', 'cajero', 'veterinario', 'almacen'))
);

COMMENT ON TABLE usuario IS 'Credenciales de acceso al sistema por empleado';

-- ------------------------------------------------------------
-- La FK de inventario_movimiento a usuario se agrega aquí
-- porque usuario se crea después de inventario_movimiento
ALTER TABLE inventario_movimiento
    ADD CONSTRAINT fk_inv_usuario
    FOREIGN KEY (usuario_id)
    REFERENCES usuario (id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- ------------------------------------------------------------

CREATE TABLE audit_log (
    id                UUID        NOT NULL DEFAULT gen_random_uuid(),
    usuario_id        UUID,
    tabla             VARCHAR(60) NOT NULL,
    accion            VARCHAR(10) NOT NULL,
    fecha             TIMESTAMP   NOT NULL DEFAULT NOW(),
    ip                INET,
    datos_anteriores  JSONB,
    datos_nuevos      JSONB,

    CONSTRAINT pk_audit           PRIMARY KEY (id),
    CONSTRAINT fk_aud_usuario     FOREIGN KEY (usuario_id)
                                  REFERENCES usuario (id)
                                  ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT ck_aud_accion      CHECK (accion IN ('INSERT', 'UPDATE', 'DELETE'))
);

COMMENT ON TABLE audit_log IS 'Bitácora de auditoría de cambios en el sistema';

-- =============================================================
--  ÍNDICES DE RENDIMIENTO
-- =============================================================

-- cliente
CREATE INDEX idx_cli_email        ON cliente        (email);
CREATE INDEX idx_cli_apellido     ON cliente        (apellido);

-- mascota
CREATE INDEX idx_mas_cliente      ON mascota        (cliente_id);
CREATE INDEX idx_mas_especie      ON mascota        (especie);

-- producto
CREATE INDEX idx_pro_categoria    ON producto       (categoria_id);
CREATE INDEX idx_pro_proveedor    ON producto       (proveedor_id);
CREATE INDEX idx_pro_nombre       ON producto       (nombre);
CREATE INDEX idx_pro_stock        ON producto       (stock)
    WHERE stock <= stock_minimo;    -- índice parcial para alertas de bajo stock

-- inventario_movimiento
CREATE INDEX idx_inv_producto     ON inventario_movimiento (producto_id);
CREATE INDEX idx_inv_fecha        ON inventario_movimiento (fecha DESC);

-- venta
CREATE INDEX idx_ven_cliente      ON venta          (cliente_id);
CREATE INDEX idx_ven_empleado     ON venta          (empleado_id);
CREATE INDEX idx_ven_fecha        ON venta          (fecha DESC);

-- detalle_venta
CREATE INDEX idx_dv_venta         ON detalle_venta  (venta_id);
CREATE INDEX idx_dv_producto      ON detalle_venta  (producto_id);

-- compra
CREATE INDEX idx_com_proveedor    ON compra         (proveedor_id);
CREATE INDEX idx_com_fecha        ON compra         (fecha DESC);

-- detalle_compra
CREATE INDEX idx_dc_compra        ON detalle_compra (compra_id);

-- cita
CREATE INDEX idx_cit_mascota      ON cita           (mascota_id);
CREATE INDEX idx_cit_veterinario  ON cita           (veterinario_id);
CREATE INDEX idx_cit_fecha        ON cita           (fecha_hora);
CREATE INDEX idx_cit_estado       ON cita           (estado);

-- historial_medico
CREATE INDEX idx_his_mascota      ON historial_medico (mascota_id);
CREATE INDEX idx_his_fecha        ON historial_medico (fecha DESC);

-- audit_log
CREATE INDEX idx_aud_usuario      ON audit_log      (usuario_id);
CREATE INDEX idx_aud_fecha        ON audit_log      (fecha DESC);
CREATE INDEX idx_aud_tabla        ON audit_log      (tabla);

-- =============================================================
--  FIN DEL SCRIPT
-- =============================================================
