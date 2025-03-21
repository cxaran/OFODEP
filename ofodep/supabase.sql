-- Proyecto OFODEP - 2025-01-01
-- Versión 0.1.0
--------------------------------------------------------------------------------
-- Autor: Jordan Aran
-- Supabase schema para la aplicación OFODEP
--------------------------------------------------------------------------------

---------------------------------------------------------------------
-- SECCIÓN 0: FUNCIONES GENERALES
---------------------------------------------------------------------

-- 0.1. Habilitar extensión para generación de UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS postgis;

-- 0.2 Enumns para los tipos de datos

-- Se utiliza para definir los tipos de suscripciones de comercios
CREATE TYPE tipo_suscripcion_enum AS ENUM ('general', 'especial', 'premium');

-- Se utiliza para definir los estados de los pedidos
CREATE TYPE estado_pedido_enum AS ENUM ('pendiente', 'aceptado', 'en_camino', 'entregado', 'cancelado');

-- Se utiliza para definir los metodo_entrega de los pedidos
CREATE TYPE metodo_entrega_enum AS ENUM ('delivery','pickup');


---------------------------------------------------------------------
-- FASE 1: USUARIOS Y AUTENTICACIÓN
---------------------------------------------------------------------

-- 1.1. Tabla "usuarios"
-- Esta tabla almacena información adicional del usuario, distinta de la información de autenticación
-- Se agrega el campo "auth_id" para relacionar el registro con la tabla nativa auth.users de Supabase.
CREATE TABLE usuarios (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_id uuid UNIQUE NOT NULL,                -- Vincula el registro con auth.users
    nombre text NOT NULL,
    email text UNIQUE CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' AND email = LOWER(email)),
    telefono text CHECK (telefono IS NULL OR telefono ~ '^\+?[0-9]{7,15}$'),
    admin boolean DEFAULT false,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

---------------------------------------------------------------------
-- FASE 2: COMERCIOS Y GESTIÓN DE HORARIOS
---------------------------------------------------------------------

-- 2.1. Tabla "comercios"
-- Almacena la información general de cada comercio, incluyendo datos de ubicación y métodos de entrega.
CREATE TABLE comercios (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre text NOT NULL CHECK (TRIM(nombre) <> ''),
    logo_url text,                     -- URL o ruta del logo del comercio
    direccion_calle text,
    direccion_numero text,
    direccion_colonia text,
    direccion_cp text CHECK (direccion_cp ~ '^\d{4,10}$'),
    direccion_ciudad text,
    direccion_estado text,
    lat numeric,                       -- Latitud geográfica
    lng numeric,                       -- Longitud geográfica
    codigos_postales text[],           -- Lista de códigos postales asociados
    whatsapp text CHECK (whatsapp ~ '^\+?[0-9]{7,15}$'),
    minimo_compra_delivery numeric,    -- Monto mínimo para delivery
    pickup boolean DEFAULT false,      -- Permite recogida en local
    delivery boolean DEFAULT false,    -- Permite delivery
    precio_delivery numeric,           -- Costo de delivery
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 2.2. Tabla "comercio_horarios"
-- Registra los horarios regulares de apertura y cierre para cada comercio.
CREATE TABLE comercio_horarios (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    comercio_id uuid REFERENCES comercios(id) ON DELETE CASCADE,
    dias int[],            -- Arreglo de días (1 = lunes, ... , 7 = domingo)
    hora_apertura time,    -- Hora de apertura
    hora_cierre time,      -- Hora de cierre
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 2.3. Tabla "comercio_horarios_excepciones"
-- Registra excepciones en el horario, por ejemplo, festivos o días especiales.
CREATE TABLE comercio_horarios_excepciones (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    comercio_id uuid REFERENCES comercios(id) ON DELETE CASCADE,
    fecha date NOT NULL,                -- Fecha específica de excepción
    es_cerrado boolean DEFAULT false,   -- Si es true, el comercio estará cerrado ese día
    hora_apertura time,                 -- Hora de apertura especial (NULL si cerrado)
    hora_cierre time,                   -- Hora de cierre especial (NULL si cerrado)
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 2.4. Tabla "comercio_administradores"
-- Relaciona comercios con sus administradores. Este registro permite determinar quién
-- tiene privilegios de modificación sobre el comercio y sus elementos asociados.
CREATE TABLE comercio_administradores (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    comercio_id uuid REFERENCES comercios(id) ON DELETE CASCADE,
    usuario_id uuid REFERENCES usuarios(auth_id) ON DELETE CASCADE,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 2.5. Tabla "comercio_suscripciones"
-- Define las suscripciones de comercios, que permiten definir si el 
-- comercio es esta actvo para las busquedas y para recibir pedidos.
CREATE TABLE comercio_suscripciones (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    comercio_id uuid UNIQUE REFERENCES comercios(id) ON DELETE CASCADE,  -- Solo una suscripción por comercio
    tipo_suscripcion tipo_suscripcion_enum NOT NULL,
    fecha_expiracion timestamptz NOT NULL,    -- Fecha de vencimiento
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

---------------------------------------------------------------------
-- FASE 3: PRODUCTOS Y producto_configuraciones
---------------------------------------------------------------------

-- 3.1. Tabla "productos"
-- Almacena el catálogo de productos de cada comercio, junto con etiquetas y categorías.
CREATE TABLE productos (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    comercio_id uuid REFERENCES comercios(id) ON DELETE CASCADE,
    nombre text NOT NULL,
    descripcion text,
    imagen_url text,
    precio numeric,
    categoria text,     -- Categoría para filtrar o agrupar productos
    tags text[],        -- Etiquetas asociadas al producto
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 3.2. Tabla "producto_configuraciones"
-- Define las producto_configuraciones o personalizaciones disponibles para un producto.
CREATE TABLE producto_configuraciones (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    producto_id uuid REFERENCES productos(id) ON DELETE CASCADE,
    nombre text NOT NULL,
    rango_min int,   -- Número mínimo de producto_opciones a seleccionar
    rango_max int,   -- Número máximo de producto_opciones a seleccionar
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    CHECK (rango_min >= 0 AND rango_max >= rango_min)
);

-- 3.3. Tabla "producto_opciones"
-- Registra las producto_opciones disponibles para cada configuración, incluyendo costos extras.
CREATE TABLE producto_opciones (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    configuracion_id uuid REFERENCES producto_configuraciones(id) ON DELETE CASCADE,
    nombre text NOT NULL,
    opcion_min int,  -- Cantidad mínima que se puede seleccionar
    opcion_max int,  -- Cantidad máxima que se puede seleccionar
    precio_extra numeric DEFAULT 0,  -- Costo adicional si se selecciona la opción
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    CHECK (opcion_min >= 0 AND opcion_max >= opcion_min)
);

---------------------------------------------------------------------
-- FASE 4: PEDIDOS Y DETALLES
---------------------------------------------------------------------

-- 4.1. Tabla "pedidos"
-- Registra los pedidos realizados. Se han agregado:
--   - "activo": indica si el pedido está activo.
--   - "solicitud_cancelacion": campo que el usuario puede modificar (solicitar cancelación) solo si "activo" es true.
--   - "usuario_id": para vincular el pedido con el usuario autenticado.
-- Se asume que la validación de que el horario del comercio esté activo, y que totales y
-- detalles coincidan, se implementará mediante lógica de negocio (por ejemplo, triggers o validaciones en la aplicación).
CREATE TABLE pedidos (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    comercio_id uuid REFERENCES comercios(id) ON DELETE CASCADE,
    usuario_id uuid REFERENCES usuarios(auth_id) NOT NULL,   -- ID del usuario que realizó el pedido
    nombre_cliente text,         -- Nombre del cliente
    email_cliente text CHECK (email_cliente = LOWER(email_cliente)),          -- Email de contacto
    telefono_cliente text,       -- Teléfono de contacto
    direccion_calle text,        -- Dirección de entrega
    direccion_numero text,
    direccion_colonia text,
    direccion_cp text CHECK (direccion_cp ~ '^\d{4,10}$'),
    direccion_ciudad text,
    direccion_estado text,
    ubicacion_lat numeric,       -- Latitud (obligatoria en delivery)
    ubicacion_lng numeric,       -- Longitud (obligatoria en delivery)
    metodo_entrega metodo_entrega_enum NOT NULL,
    precio_delivery numeric CHECK (precio_delivery >= 0) DEFAULT 0,     -- Costo de delivery aplicado
    total numeric CHECK (total >= 0),        -- Total del pedido
    estado estado_pedido_enum DEFAULT 'pendiente',
    activo boolean DEFAULT true,             -- Indica si el pedido está activo
    solicitud_cancelacion timestamptz NULL,  -- Fecha de solicitud de cancelación (NULL si no ha sido solicitada)
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    CHECK (metodo_entrega <> 'delivery' OR (ubicacion_lat IS NOT NULL AND ubicacion_lng IS NOT NULL))
);

-- 4.1.1 Tabla "pedido_reviews"
-- Registra las valoraciones y comentarios del usuario que realizó el pedido después de recibirlo.
CREATE TABLE pedido_reviews (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    pedido_id uuid UNIQUE REFERENCES pedidos(id) ON DELETE CASCADE,
    calificacion numeric CHECK (calificacion >= 0 AND calificacion <= 5),  -- Valoración (0-5)
    review text,                                                         -- Comentarios del usuario
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);


-- 4.2. Tabla "pedido_productos"
-- Detalla cada item del pedido, vinculando el producto y la cantidad solicitada, además del precio final.
CREATE TABLE pedido_productos (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    pedido_id uuid REFERENCES pedidos(id) ON DELETE CASCADE,
    producto_id uuid REFERENCES productos(id),
    cantidad int DEFAULT 1,
    precio numeric CHECK (precio >= 0) DEFAULT 0,  -- Precio final del item, con ajustes de producto_configuraciones/producto_opciones
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 4.3. Tabla "pedido_configuraciones"
-- Registra las producto_configuraciones seleccionadas para cada item del pedido.
CREATE TABLE pedido_configuraciones (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    pedido_item_id uuid REFERENCES pedido_productos(id) ON DELETE CASCADE,
    configuracion_id uuid REFERENCES producto_configuraciones(id),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 4.4. Tabla "pedido_opciones"
-- Registra las producto_opciones seleccionadas para cada configuración de un item, junto con
-- la cantidad elegida y el costo extra aplicado.
CREATE TABLE pedido_opciones (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    pedido_item_configuracion_id uuid REFERENCES pedido_configuraciones(id) ON DELETE CASCADE,
    opcion_id uuid REFERENCES producto_opciones(id),
    cantidad int DEFAULT 0,
    precio_extra numeric DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

---------------------------------------------------------------------
-- FASE 5: INFORMACIÓN DE DELIVERY
---------------------------------------------------------------------

-- 5.1. Tabla "delivery_info"
-- Almacena los datos necesarios para la asignación de repartidor: token único,
-- coordenadas y el ID del repartidor que acepte el pedido.
CREATE TABLE delivery_info (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    pedido_id uuid REFERENCES pedidos(id) ON DELETE CASCADE,
    link_token text UNIQUE NOT NULL,  -- Token único enviado al repartidor
    usuario_repartidor uuid,          -- ID del repartidor que acepta el pedido (se asigna al abrir el link)
    repartidor_lat numeric,           -- Latitud de la ubicación del repartidor
    repartidor_lng numeric,           -- Longitud de la ubicación del repartidor
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);


---------------------------------------------------------------------
-- SECCIÓN: ÍNDICES ADICIONALES: OPTIMIZACIÓN DE CONSULTAS Y BÚSQUEDAS
---------------------------------------------------------------------

-- FASE 1: Usuarios
-- Índice para búsquedas rápidas por email (útil para autenticación o consultas de perfil)
CREATE INDEX idx_usuarios_email ON usuarios(email);

-- Índice para búsquedas por nombre (en caso de filtrar por nombre de usuario)
CREATE INDEX idx_usuarios_nombre ON usuarios(nombre);

---------------------------------------------------------------------
-- FASE 2: Comercios y Horarios
-- Índice en el campo "nombre" ya se creó para la tabla comercios.
-- Índice adicional en la tabla comercio_horarios para búsquedas por días (utilizando GIN para arrays)
CREATE INDEX idx_comercio_horarios_dias ON comercio_horarios USING gin(dias);

-- Índice en la tabla comercio_horarios_excepciones para búsquedas por fecha
CREATE INDEX idx_comercio_horarios_excepciones_fecha ON comercio_horarios_excepciones(fecha);

-- Índice en la tabla comercio_administradores para búsquedas por usuario
CREATE INDEX idx_comercio_administradores_usuario_id ON comercio_administradores(usuario_id);

-- Índice en la tabla comercio_suscripciones para búsquedas por fecha de expiración
CREATE INDEX idx_comercio_suscripciones_fecha_expiracion ON comercio_suscripciones(fecha_expiracion);

---------------------------------------------------------------------
-- FASE 3: Productos y producto_configuraciones
-- Índice para búsquedas en el nombre de productos (además del índice en categoría)
CREATE INDEX idx_productos_nombre ON productos(nombre);

---------------------------------------------------------------------
-- FASE 4: Pedidos y Detalles
-- Índice en la tabla pedidos para búsquedas rápidas por usuario (útil para que los usuarios vean sus pedidos)
CREATE INDEX idx_pedidos_usuario_id ON pedidos(usuario_id);

-- Índice en la tabla pedidos para búsquedas por estado
CREATE INDEX idx_pedidos_estado ON pedidos(estado);

-- Índice en la tabla pedido_productos para agrupar items por pedido
CREATE INDEX idx_pedido_productos_pedido_id ON pedido_productos(pedido_id);

-- Índice en la tabla pedidos para búsquedas por fecha de creación
CREATE INDEX idx_pedidos_created_at ON pedidos(created_at DESC);

-- Índice en la tabla pedidos para búsquedas por usuario y estado
CREATE INDEX idx_pedidos_usuario_estado ON pedidos(usuario_id, estado);

---------------------------------------------------------------------
-- FASE 5: Información de Delivery
-- Índice en delivery_info para búsquedas por pedido
CREATE INDEX idx_delivery_info_pedido_id ON delivery_info(pedido_id);


------------------------------------------------------------------------------------
-- SEGURIDAD: DESCRIPCIÓN DE LAS RESTRICCIONES DE SEGURIDAD EN EL FLUJO DE NEGOCIOS
------------------------------------------------------------------------------------
/*
Políticas de Seguridad:

1. ADMINISTRADORES GLOBALES:
   • Pueden realizar cualquier operación (INSERT, UPDATE, DELETE) en todas las tablas,
     EXCEPTO la eliminación de su propio usuario.

2. LECTURA PÚBLICA:
   • Cualquier usuario (incluso sin autenticar) puede leer:
       - Comercios
       - Productos
       - Producto_configuraciones
       - Producto_opciones
       - Horarios
       - Excepciones de Horarios
   • Siempre que la suscripción del comercio esté activa.

3. ADMINISTRADORES DE COMERCIOS:
   • Operaciones completas (INSERT, UPDATE, DELETE) en su comercio y tablas relacionadas:
       - Horarios
       - Productos
       - Producto_configuraciones
       - Producto_opciones
   • Pueden modificar su propio registro en la tabla de comercios (UPDATE) SOLO si la
     suscripción está activa.
   • La relación se verifica a través de la tabla "comercio_administradores".

4. TABLA "USUARIOS":
   • SELECT:
       - Usuarios regulares: Solo su propio registro.
       - Administradores: Cualquier registro.
   • UPDATE:
       - Usuarios regulares: Solo pueden modificar su propio registro en los campos
         "nombre" y "email".
       - Administradores: Pueden actualizar cualquier registro.
   • DELETE:
       - Usuarios regulares: Solo pueden eliminar su propio registro.
       - Administradores: Pueden eliminar cualquier registro, EXCEPTO el propio.

5. TABLA "PEDIDOS":
   • Un usuario autenticado puede ver únicamente sus propios pedidos.
   • Un usuario puede insertar un pedido siempre que:
       - El campo "usuario_id" coincida con su propio UUID.
       - La suscripción del comercio esté activa (fecha_expiracion > now()).
       - El horario del comercio esté activo.
       - Los totales y detalles del pedido sean correctos (controlado por lógica de negocio o triggers).
   • Un usuario podrá modificar únicamente el campo "solicitud_cancelacion" si el pedido está activo.
   • Un usuario podrá ver y modificar registros en "delivery_info" si:
       - El campo "usuario_repartidor" es nulo, o
       - El campo "usuario_repartidor" coincide con su propio UUID.
   • Un usuario podrá ver un pedido si está asignado como repartidor en la "delivery_info" del pedido.
*/

---------------------------------------------------------------------
-- SECCIÓN: TRIGGERS Y FUNCIONES AUXILIARES (POR FASE)
---------------------------------------------------------------------

/*
Ejemplos de funciones y triggers para reforzar la lógica de negocio:

1. Función y trigger en la tabla USUARIOS:
   • Permite que los usuarios regulares solo modifiquen los campos "nombre y "telefono".
---------------------------------------------------------------
*/
CREATE OR REPLACE FUNCTION check_usuario_update()
RETURNS TRIGGER AS $$
DECLARE
    current_user uuid;
    es_admin boolean;
BEGIN
    -- Se obtiene el ID del usuario autenticado (configurado por Supabase en jwt.claims.sub)
    SELECT current_setting('jwt.claims.sub')::uuid INTO current_user;
    
    -- Se verifica si el usuario es administrador
    SELECT admin INTO es_admin FROM usuarios WHERE auth_id = current_user;
    
    IF NOT es_admin THEN
        -- Para usuarios regulares, solo se permite modificar "nombre y "telefono"
        IF NEW.email IS DISTINCT FROM OLD.email OR
           NEW.admin IS DISTINCT FROM OLD.admin OR
           NEW.created_at IS DISTINCT FROM OLD.created_at OR
           NEW.auth_id IS DISTINCT FROM OLD.auth_id THEN
            RAISE EXCEPTION 'Usuario no autorizado para modificar estos campos';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_usuario_update
BEFORE UPDATE ON usuarios
FOR EACH ROW
EXECUTE FUNCTION check_usuario_update();

/*
   • Permite que se actualicen los datos de los usuarios cuando se crean en Supabase
---------------------------------------------------------------
*/
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.usuarios (auth_id, email, nombre, telefono) 
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'nombre', ''), 
    COALESCE(NEW.raw_user_meta_data->>'telefono', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

---------------------------------------------------------------
/*
2. Función y trigger en la tabla PEDIDOS:
   • Permite que usuarios regulares únicamente modifiquen el campo "solicitud_cancelacion"
     (y solo si el pedido está activo). Los administradores globales pueden actualizar libremente.
---------------------------------------------------------------
*/
CREATE OR REPLACE FUNCTION check_pedido_update()
RETURNS TRIGGER AS $$
DECLARE
    current_user uuid;
    es_admin boolean;
    admin_comercio uuid;
BEGIN
    SELECT current_setting('jwt.claims.sub')::uuid INTO current_user;
    SELECT admin INTO es_admin FROM usuarios WHERE auth_id = current_user;
    
    IF NOT es_admin  THEN

        -- Verifica que el comercio del pedido sea el propio del usuario
        SELECT usuario_id INTO admin_comercio FROM comercio_administradores WHERE comercio_id = OLD.comercio_id AND usuario_id = current_user;
        IF admin_comercio IS NULL THEN

          -- Verifica que ningún otro campo se modifique, excepto solicitud_cancelacion
          IF NEW.comercio_id IS DISTINCT FROM OLD.comercio_id OR
            NEW.usuario_id IS DISTINCT FROM OLD.usuario_id OR
            NEW.nombre_cliente IS DISTINCT FROM OLD.nombre_cliente OR
            NEW.email_cliente IS DISTINCT FROM OLD.email_cliente OR
            NEW.telefono_cliente IS DISTINCT FROM OLD.telefono_cliente OR
            NEW.direccion_calle IS DISTINCT FROM OLD.direccion_calle OR
            NEW.direccion_numero IS DISTINCT FROM OLD.direccion_numero OR
            NEW.direccion_colonia IS DISTINCT FROM OLD.direccion_colonia OR
            NEW.direccion_cp IS DISTINCT FROM OLD.direccion_cp OR
            NEW.direccion_ciudad IS DISTINCT FROM OLD.direccion_ciudad OR
            NEW.direccion_estado IS DISTINCT FROM OLD.direccion_estado OR
            NEW.ubicacion_lat IS DISTINCT FROM OLD.ubicacion_lat OR
            NEW.ubicacion_lng IS DISTINCT FROM OLD.ubicacion_lng OR
            NEW.metodo_entrega IS DISTINCT FROM OLD.metodo_entrega OR
            NEW.precio_delivery IS DISTINCT FROM OLD.precio_delivery OR
            NEW.total IS DISTINCT FROM OLD.total OR
            NEW.estado IS DISTINCT FROM OLD.estado OR
            NEW.activo IS DISTINCT FROM OLD.activo THEN
              RAISE EXCEPTION 'Usuario no autorizado para modificar campos distintos a solicitud_cancelacion';
          END IF;
          
          IF NEW.solicitud_cancelacion IS DISTINCT FROM OLD.solicitud_cancelacion THEN
              IF NOT OLD.activo THEN
                  RAISE EXCEPTION 'No se puede modificar solicitud_cancelacion en un pedido inactivo';
              END IF;
          END IF;
        
        END IF;

    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_pedido_update
BEFORE UPDATE ON pedidos
FOR EACH ROW
EXECUTE FUNCTION check_pedido_update();

---------------------------------------------------------------
/*
3. Trigger para actualizar automáticamente el campo updated_at en todas las tablas.
---------------------------------------------------------------
*/
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- A continuación se listan los triggers (utilizando la función update_updated_at_column())
-- e índices adicionales para optimizar las consultas.

-- FASE 1: Usuarios
CREATE TRIGGER trg_usuarios_updated_at
BEFORE UPDATE ON usuarios
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- FASE 2: Comercios y Horarios
CREATE TRIGGER trg_comercios_updated_at
BEFORE UPDATE ON comercios
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_comercio_horarios_updated_at
BEFORE UPDATE ON comercio_horarios
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_comercio_horarios_excepciones_updated_at
BEFORE UPDATE ON comercio_horarios_excepciones
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_comercio_administradores_updated_at
BEFORE UPDATE ON comercio_administradores
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- FASE 3: Productos y producto_configuraciones
CREATE TRIGGER trg_productos_updated_at
BEFORE UPDATE ON productos
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_producto_configuraciones_updated_at
BEFORE UPDATE ON producto_configuraciones
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_producto_opciones_updated_at
BEFORE UPDATE ON producto_opciones
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- FASE 4: Pedidos y Detalles
CREATE TRIGGER trg_pedidos_updated_at
BEFORE UPDATE ON pedidos
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_pedido_productos_updated_at
BEFORE UPDATE ON pedido_productos
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_pedido_configuraciones_updated_at
BEFORE UPDATE ON pedido_configuraciones
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_pedido_opciones_updated_at
BEFORE UPDATE ON pedido_opciones
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- FASE 5: Delivery
CREATE TRIGGER trg_delivery_info_updated_at
BEFORE UPDATE ON delivery_info
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


---------------------------------------------------------------
/*
4. Función auxiliar para verificar si un comercio está abierto para pedidos.
---------------------------------------------------------------
*/
CREATE OR REPLACE FUNCTION comercio_horario_activo(comercio uuid)
RETURNS boolean AS $$
DECLARE
  current_date date := CURRENT_DATE;
  current_time time := CURRENT_TIME;
  current_dow integer := EXTRACT(ISODOW FROM now())::integer; -- 1=lunes, 7=domingo
  exception_record RECORD;
  regular_record RECORD;
  is_open boolean := false;
BEGIN
  -- Verificar si existe una excepción para el comercio en la fecha actual
  SELECT *
  INTO exception_record
  FROM comercio_horarios_excepciones
  WHERE comercio_id = comercio AND fecha = current_date
  LIMIT 1;
  
  IF exception_record IS NOT NULL THEN
    -- Si se marca como cerrado en la excepción, el comercio está cerrado
    IF exception_record.es_cerrado THEN
      RETURN false;
    ELSE
      -- Si hay horario especial, se comprueba si la hora actual está dentro del rango especial
      IF current_time >= exception_record.hora_apertura 
         AND current_time <= exception_record.hora_cierre THEN
         RETURN true;
      ELSE
         RETURN false;
      END IF;
    END IF;
  END IF;
  
  -- En ausencia de excepción, se verifica el horario regular
  FOR regular_record IN
    SELECT *
    FROM comercio_horarios
    WHERE comercio_id = comercio
  LOOP
    -- Se verifica que el día actual se encuentre en el arreglo de días y que la hora esté dentro del rango
    IF current_dow = ANY(regular_record.dias) THEN
      IF current_time >= regular_record.hora_apertura 
         AND current_time <= regular_record.hora_cierre THEN
         is_open := true;
         EXIT;  -- Se encontró un horario que cumple la condición, se sale del bucle
      END IF;
    END IF;
  END LOOP;
  
  RETURN is_open;
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------
/*
5. Función auxiliar para verificar si un pedido es consistente con el comercio.
---------------------------------------------------------------
*/
CREATE OR REPLACE FUNCTION verificar_consistencia_pedido()
RETURNS TRIGGER AS $$
DECLARE
    suma_total numeric := 0;
    prod RECORD;
    suma_opciones numeric;
    prod_comercio uuid;
BEGIN
    -- Recorre cada producto asociado al pedido
    FOR prod IN
        SELECT id, cantidad, precio, producto_id
        FROM pedido_productos
        WHERE pedido_id = NEW.id
    LOOP
        -- Verificar que el producto pertenece al comercio del pedido
        SELECT comercio_id INTO prod_comercio
        FROM productos
        WHERE id = prod.producto_id;
        
        IF prod_comercio IS NULL OR prod_comercio <> NEW.comercio_id THEN
            RAISE EXCEPTION 'El producto % no pertenece al comercio del pedido', prod.producto_id;
        END IF;
        
        -- Sumar el costo base del producto (precio * cantidad)
        suma_total := suma_total + (prod.precio * prod.cantidad);
        
        -- Sumar el costo extra de las opciones asociadas a las configuraciones del producto
        SELECT COALESCE(SUM(po.precio_extra * po.cantidad), 0)
          INTO suma_opciones
          FROM pedido_configuraciones pc
          JOIN pedido_opciones po ON po.pedido_item_configuracion_id = pc.id
          WHERE pc.pedido_item_id = prod.id;
        
        suma_total := suma_total + suma_opciones;
    END LOOP;
    
    -- Comparar totales redondeados a dos decimales para evitar errores por diferencias mínimas
    IF ROUND(suma_total, 2) <> ROUND(NEW.total, 2) THEN
        RAISE EXCEPTION 'El total declarado del pedido (%.2f) no coincide con la suma calculada de productos y opciones (%.2f)', NEW.total, suma_total;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Al definir este trigger como constraint y diferido, se garantiza que la validación se ejecute al finalizar la transacción, momento en el que ya deben existir todos los registros en las tablas de detalles:
CREATE CONSTRAINT TRIGGER trg_verificar_consistencia_pedido
AFTER INSERT ON pedidos
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION verificar_consistencia_pedido();

---------------------------------------------------------------------
-- SECCIÓN: HABILITACIÓN DE ROW LEVEL SECURITY (RLS)
---------------------------------------------------------------------

ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE comercios ENABLE ROW LEVEL SECURITY;
ALTER TABLE comercio_horarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE comercio_horarios_excepciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE comercio_suscripciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE comercio_administradores ENABLE ROW LEVEL SECURITY;
ALTER TABLE productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE producto_configuraciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE producto_opciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedido_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedido_productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedido_configuraciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedido_opciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_info ENABLE ROW LEVEL SECURITY;

-- NOTA: Se utiliza auth.uid() para identificar al usuario autenticado.

-- Usuario Admin Global tiene acceso total a la base de datos
CREATE OR REPLACE FUNCTION public.is_global_admin() 
RETURNS boolean AS $$
DECLARE
  admin_status boolean;
BEGIN
  SELECT admin 
  INTO admin_status 
  FROM public.usuarios 
  WHERE auth_id = auth.uid();
  RETURN admin_status;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;



---------------------------------------------------------------------
-- SECCIÓN: POLÍTICAS DE SEGURIDAD (RLS)
---------------------------------------------------------------------

-- Tabla USUARIOS

-- 1.a. Administrador global: acceso total en la tabla (salvo eliminación de su propio registro)
CREATE POLICY admin_full_access ON usuarios
FOR ALL
USING (
  public.is_global_admin()
);

-- 1.b. Usuario regular: puede SELECT, UPDATE y DELETE únicamente su propio registro.
CREATE POLICY user_self_access ON usuarios
FOR ALL
USING ( auth.uid() = usuarios.auth_id)
WITH CHECK ( auth.uid() = usuarios.auth_id);

---------------------------------------------------------------------
-- Tablas de COMERCIOS y HORARIOS

-- 2.a. Lectura Pública de comercios:
-- Permite la lectura si la suscripción del comercio está activa, o el usuario es administrador
-- global o administrador del comercio.
CREATE POLICY public_read_comercios ON comercios
FOR SELECT
USING (
    EXISTS (
      SELECT 1 FROM comercio_suscripciones cs
      WHERE cs.comercio_id = comercios.id
        AND cs.fecha_expiracion > now()
    )
    OR EXISTS (
      SELECT 1 FROM comercio_administradores ca
      WHERE ca.comercio_id = comercios.id AND ca.usuario_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);

-- 2.b. Modificación de comercios:
-- Permite UPDATE solo a administradores de comercio y únicamente cuando la suscripción esté activa.
CREATE POLICY update_comercios_admin ON comercios
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM comercio_administradores ca
    WHERE ca.comercio_id = comercios.id AND ca.usuario_id = auth.uid()
  )
  AND EXISTS (
      SELECT 1 FROM comercio_suscripciones cs
      WHERE cs.comercio_id = comercios.id
        AND cs.fecha_expiracion > now()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM comercio_administradores ca
    WHERE ca.comercio_id = comercios.id AND ca.usuario_id = auth.uid()
  )
);

-- 2.c. Horarios y Excepciones de horarios:
-- Lectura pública y modificación solo para administradores de comercio.

-- Política de lectura pública para la tabla comercio_horarios
CREATE POLICY public_read_comercio_horarios ON comercio_horarios
FOR SELECT
USING (
    EXISTS (
      SELECT 1 FROM comercio_suscripciones cs
      WHERE cs.comercio_id = comercio_horarios.comercio_id
        AND cs.fecha_expiracion > now()
    )
    OR EXISTS (
      SELECT 1 FROM comercio_administradores ca
      WHERE ca.comercio_id = comercio_horarios.comercio_id
        AND ca.usuario_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);

-- Política de modificación (INSERT, UPDATE, DELETE) para la tabla comercio_horarios
CREATE POLICY modify_comercio_horarios_admin ON comercio_horarios
FOR ALL
USING (
    EXISTS (
      SELECT 1 FROM comercio_administradores ca
      WHERE ca.comercio_id = comercio_horarios.comercio_id
        AND ca.usuario_id = auth.uid()
    )
);

-- POLÍTICAS PARA LA TABLA comercio_horarios_excepciones:

-- Política de lectura pública para la tabla comercio_horarios_excepciones
CREATE POLICY public_read_comercio_horarios_excepciones ON comercio_horarios_excepciones
FOR SELECT
USING (
    EXISTS (
      SELECT 1 FROM comercio_suscripciones cs
      WHERE cs.comercio_id = comercio_horarios_excepciones.comercio_id
        AND cs.fecha_expiracion > now()
    )
    OR EXISTS (
      SELECT 1 FROM comercio_administradores ca
      WHERE ca.comercio_id = comercio_horarios_excepciones.comercio_id
        AND ca.usuario_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);

-- Política de modificación (INSERT, UPDATE, DELETE) para la tabla comercio_horarios_excepciones
CREATE POLICY modify_comercio_horarios_excepciones_admin ON comercio_horarios_excepciones
FOR ALL
USING (
    EXISTS (
      SELECT 1 FROM comercio_administradores ca
      WHERE ca.comercio_id = comercio_horarios_excepciones.comercio_id
        AND ca.usuario_id = auth.uid()
    )
);

---------------------------------------------------------------------
-- Tabla de comercio_suscripciones

-- 2.1.a. Lectura Pública de suscripciones:
CREATE POLICY public_read_comercio_suscripciones ON comercio_suscripciones
FOR SELECT
USING (true);

-- 2.1.b. Modificación de suscripciones:
-- Permite insertar, actualizar y eliminar suscripciones de comercios siempre que:
--   - El usuario es administrador global.
CREATE POLICY modify_comercio_suscripciones_admin ON comercio_suscripciones
FOR ALL
USING (
    EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    
);

---------------------------------------------------------------------
-- Tablas de PRODUCTOS y CONFIGURACIONES

-- 3.a. Lectura Pública de productos, configuraciones y opciones:
CREATE POLICY public_read_productos ON productos
FOR SELECT
USING (
    EXISTS (
      SELECT 1 FROM comercio_suscripciones cs
      WHERE cs.comercio_id = productos.comercio_id
        AND cs.fecha_expiracion > now()
    )
    OR EXISTS (
      SELECT 1 FROM comercio_administradores ca
      WHERE ca.comercio_id = productos.comercio_id AND ca.usuario_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);
CREATE POLICY public_read_producto_configuraciones ON producto_configuraciones
FOR SELECT
USING (
    EXISTS (
      SELECT 1
      FROM comercio_suscripciones cs
      JOIN productos p ON p.comercio_id = cs.comercio_id
      WHERE p.id = producto_configuraciones.producto_id
        AND cs.fecha_expiracion > now()
    )
    OR EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    OR EXISTS (
      SELECT 1
      FROM comercio_administradores ca
      JOIN productos p ON p.comercio_id = ca.comercio_id
      WHERE p.id = producto_configuraciones.producto_id
        AND ca.usuario_id = auth.uid()
    )
);
CREATE POLICY public_read_producto_opciones ON producto_opciones
FOR SELECT
USING (
    EXISTS (
      SELECT 1
      FROM comercio_suscripciones cs
      JOIN producto_configuraciones pc ON pc.id = producto_opciones.configuracion_id
      JOIN productos p ON p.id = pc.producto_id
      WHERE cs.comercio_id = p.comercio_id
        AND cs.fecha_expiracion > now()
    )
    OR EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    OR EXISTS (
      SELECT 1
      FROM comercio_administradores ca
      JOIN producto_configuraciones pc ON pc.id = producto_opciones.configuracion_id
      JOIN productos p ON p.id = pc.producto_id
      WHERE ca.comercio_id = p.comercio_id
        AND ca.usuario_id = auth.uid()
    )
);

-- 3.b. Modificación de productos:
-- Solo administradores de comercio pueden insertar, actualizar o eliminar productos.
-- Los usuarios administradores globales pueden modificar productos siempre.
CREATE POLICY modify_productos_admin ON productos
FOR ALL
USING (
   EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    OR EXISTS (
      SELECT 1 FROM comercio_administradores ca
      WHERE ca.comercio_id = productos.comercio_id AND ca.usuario_id = auth.uid()
    )
);

-- 3.c. Modificación de configuraciones y opciones:
CREATE POLICY modify_producto_configuraciones_admin ON producto_configuraciones
FOR ALL
USING (
    EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    OR EXISTS (
      SELECT 1 FROM comercio_administradores ca
      JOIN productos p ON p.id = producto_configuraciones.producto_id
      WHERE ca.comercio_id = p.comercio_id AND ca.usuario_id = auth.uid()
    )
);

CREATE POLICY modify_producto_opciones_admin ON producto_opciones
FOR ALL
USING (
    EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    OR EXISTS (
      SELECT 1 FROM comercio_administradores ca
      JOIN producto_configuraciones pc ON pc.id = producto_opciones.configuracion_id
      JOIN productos p ON p.id = pc.producto_id
      WHERE ca.comercio_id = p.comercio_id AND ca.usuario_id = auth.uid()
    )
);


---------------------------------------------------------------------
-- Tabla PEDIDOS

-- 4.a. Selección (SELECT):
-- El pedido es visible si:
--   - El usuario es el que realizó el pedido,
--   - El usuario está asignado como repartidor en delivery_info,
--   - O el usuario es administrador global.
--   - O el usuario administrador del comercio.
CREATE POLICY select_own_pedidos ON pedidos
FOR SELECT
USING (
    usuario_id = auth.uid()
    OR EXISTS (
       SELECT 1 FROM delivery_info di
       WHERE di.pedido_id = pedidos.id
         AND di.usuario_repartidor = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    OR EXISTS (
      SELECT 1 FROM comercio_administradores ca
      WHERE ca.comercio_id = pedidos.comercio_id
        AND ca.usuario_id = auth.uid()
    )
);

-- 4.b. Inserción (INSERT):
-- Se permite si:
--   - El usuario que inserta coincide con el usuario_id del pedido.
--   - La suscripción del comercio está activa.
--   - El comercio se encuentra abierto (verificado mediante la función auxiliar comercio_horario_activo).
CREATE POLICY insert_pedidos ON pedidos
FOR INSERT
WITH CHECK (
    usuario_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM comercio_suscripciones cs
      WHERE cs.comercio_id = pedidos.comercio_id
        AND cs.fecha_expiracion > now()
    )
    AND comercio_horario_activo(pedidos.comercio_id)
);

-- 4.c. Actualización (UPDATE):
-- Permite que el usuario propietario del pedido (o un administrador global o administrador del comercio) pueda actualizar.
-- Se recomienda complementar esta política con un trigger que verifique que, en el caso de un usuario
-- regular, únicamente se modifique el campo "solicitud_cancelacion" si el pedido está activo.
CREATE POLICY update_pedidos_user ON pedidos
FOR UPDATE
USING (
    usuario_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    OR EXISTS (
      SELECT 1 FROM comercio_administradores ca
      WHERE ca.comercio_id = pedidos.comercio_id
        AND ca.usuario_id = auth.uid()
    )
);

-- 4.d. Eliminación (DELETE):
-- Restringe la eliminación de pedidos a administradores globales.
CREATE POLICY delete_pedidos_admin ON pedidos
FOR DELETE
USING (
    EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);

---------------------------------------------------------------------
-- Tabla DELIVERY_INFO

-- 5.a. Selección (SELECT):
-- Un registro de delivery es visible si:
--   - El usuario es el propietario del pedido,
--   - O coincide con el repartidor asignado,
--   - O es administrador global.
--   - O el usuario es administrador del comercio.
CREATE POLICY select_delivery_info ON delivery_info
FOR SELECT
USING (
    EXISTS (
       SELECT 1 FROM pedidos p
       WHERE p.id = delivery_info.pedido_id AND p.usuario_id = auth.uid()
    )
    OR usuario_repartidor = auth.uid()
    OR EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    OR EXISTS (
      SELECT 1
      FROM comercio_administradores ca
      JOIN pedidos p ON p.comercio_id = ca.comercio_id
      WHERE p.id = delivery_info.pedido_id
        AND ca.usuario_id = auth.uid()
    )
);

-- 5.b. Inserción:
-- Se permite insertar un registro en delivery_info si:
--   - El usuario es administrador del comercio.
--   - El usuario es administrador global.
CREATE POLICY insert_delivery_info ON delivery_info
FOR INSERT
WITH CHECK (
    EXISTS (
       SELECT 1
       FROM comercio_administradores ca
       JOIN pedidos p ON p.comercio_id = ca.comercio_id
       WHERE p.id = delivery_info.pedido_id
         AND ca.usuario_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);

-- 5.c. Actualización:
-- Se permite actualizar delivery_info si:
--   - El campo usuario_repartidor es nulo o coincide con el usuario autenticado,
--   - O el usuario es administrador global.
CREATE POLICY update_delivery_info ON delivery_info
FOR UPDATE
USING (
    (usuario_repartidor IS NULL OR usuario_repartidor = auth.uid())
    OR EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    OR EXISTS (
       SELECT 1
       FROM comercio_administradores ca
       JOIN pedidos p ON p.comercio_id = ca.comercio_id
       WHERE p.id = delivery_info.pedido_id
         AND ca.usuario_id = auth.uid()
    )
);

-- 5.d. Eliminación:
-- Restringida a administradores globales.
CREATE POLICY delete_delivery_info_admin ON delivery_info
FOR DELETE
USING (
    EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);


---------------------------------------------------------------------
-- Tabla de pedido_reviews
-- Política de lectura pública: cualquier usuario puede leer las reviews
CREATE POLICY public_read_pedido_reviews ON pedido_reviews
FOR SELECT
USING (true);

-- Política de inserción: solo se puede insertar si el usuario autenticado es el dueño del pedido y el admin global
CREATE POLICY insert_pedido_reviews ON pedido_reviews
FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1 FROM pedidos
        WHERE id = pedido_reviews.pedido_id
          AND usuario_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);

-- Política de actualización: solo el dueño del pedido puede modificar la review y el admin global
CREATE POLICY update_pedido_reviews ON pedido_reviews
FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM pedidos
        WHERE id = pedido_reviews.pedido_id
          AND usuario_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);

-- Política de eliminación: solo el dueño del pedido puede borrar la review y el admin global
CREATE POLICY delete_pedido_reviews ON pedido_reviews
FOR DELETE
USING (
    EXISTS (
        SELECT 1 FROM pedidos
        WHERE id = pedido_reviews.pedido_id
          AND usuario_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM usuarios u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);