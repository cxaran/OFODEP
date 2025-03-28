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

-- 0.2 Enums para los tipos de datos

-- Se utiliza para definir los tipos de suscripciones de las tiendas
CREATE TYPE subscription_type_enum AS ENUM ('general', 'special', 'premium');

-- Se utiliza para definir los estados de los pedidos
CREATE TYPE order_status_enum AS ENUM ('pending', 'accepted', 'on_the_way', 'delivered', 'cancelled');

-- Se utiliza para definir los métodos de entrega de los pedidos
CREATE TYPE delivery_method_enum AS ENUM ('delivery','pickup');


---------------------------------------------------------------------
-- FASE 1: USUARIOS Y AUTENTICACIÓN
---------------------------------------------------------------------

-- 1.1. Tabla "users" (antes "usuarios")
-- Esta tabla almacena información adicional del usuario, distinta de la información de autenticación
-- Se agrega el campo "auth_id" para relacionar el registro con la tabla nativa auth.users de Supabase.
CREATE TABLE users (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_id uuid UNIQUE NOT NULL,                -- Vincula el registro con auth.users
    name text NOT NULL,                          -- (antes "nombre")
    email text UNIQUE CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' AND email = LOWER(email)),
    phone text CHECK (phone IS NULL OR phone ~ '^\+?[0-9]{7,15}$'),   -- (antes "telefono")
    admin boolean DEFAULT false,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

---------------------------------------------------------------------
-- FASE 2: TIENDAS (COMERCIOS) Y GESTIÓN DE HORARIOS
---------------------------------------------------------------------

-- 2.1. Tabla "stores" (antes "stores")
-- Almacena la información general de cada tienda, incluyendo datos de ubicación y métodos de entrega.
CREATE TABLE stores (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text NOT NULL CHECK (TRIM(name) <> ''),                 -- (antes "nombre")
    logo_url text,                                              -- URL o ruta del logo de la tienda
    address_street text,                                        -- (antes "direccion_calle")
    address_number text,                                        -- (antes "direccion_numero")
    address_colony text,                                        -- (antes "direccion_colonia")
    address_zipcode text CHECK (address_zipcode ~ '^\d{4,10}$'),-- (antes "direccion_cp")
    address_city text,                                          -- (antes "direccion_ciudad")
    address_state text,                                         -- (antes "direccion_estado")
    lat numeric,                                                -- Latitud geográfica
    lng numeric,                                                -- Longitud geográfica
    country_code text CHECK (country_code ~ '^[A-Z]{2,3}$'),    -- Código de país (ej. "MX", "US")
    zipcodes text[],                                            -- Lista de códigos postales asociados (antes "codigos_postales")
    whatsapp text CHECK (whatsapp ~ '^\+?[0-9]{7,15}$'),
    delivery_minimum_order numeric,                             -- (antes "minimo_compra_delivery")
    pickup boolean DEFAULT false,
    delivery boolean DEFAULT false,
    delivery_price numeric,                                     -- (antes "precio_delivery")
    imgur_client_id text,
    imgur_client_secret text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 2.2. Tabla "store_schedules" (antes "store_horarios")
-- Registra los horarios regulares de apertura y cierre para cada tienda.
CREATE TABLE store_schedules (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id uuid REFERENCES stores(id) ON DELETE CASCADE,  -- (antes "store_id")
    days int[],                                             -- (antes "dias"; 1 = lunes, ... , 7 = domingo)
    opening_time time,                                      -- (antes "hora_apertura")
    closing_time time,                                      -- (antes "hora_cierre")
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 2.3. Tabla "store_schedule_exceptions" (antes "store_horarios_excepciones")
-- Registra excepciones en el horario, por ejemplo, festivos o días especiales.
CREATE TABLE store_schedule_exceptions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id uuid REFERENCES stores(id) ON DELETE CASCADE,   -- (antes "store_id")
    date date NOT NULL,                                      -- (antes "fecha")
    is_closed boolean DEFAULT false,                         -- (antes "es_cerrado")
    opening_time time,                                       -- (antes "hora_apertura")
    closing_time time,                                       -- (antes "hora_cierre")
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 2.4. Tabla "store_admins" (antes "store_administradores")
-- Relaciona tiendas con sus administradores. Este registro permite determinar quién
-- tiene privilegios de modificación sobre la tienda y sus elementos asociados.
CREATE TABLE store_admins (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id uuid REFERENCES stores(id) ON DELETE CASCADE,    -- (antes "store_id")
    user_id uuid REFERENCES users(auth_id) ON DELETE CASCADE, -- (antes "usuario_id")
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 2.5. Tabla "store_subscriptions" (antes "store_suscripciones")
-- Define las suscripciones de las tiendas, que permiten definir si la 
-- tienda está activa para las búsquedas y para recibir pedidos.
CREATE TABLE store_subscriptions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id uuid UNIQUE REFERENCES stores(id) ON DELETE CASCADE,  -- (antes "store_id")
    subscription_type subscription_type_enum NOT NULL,             -- (antes "tipo_suscripcion")
    expiration_date timestamptz NOT NULL,                          -- (antes "fecha_expiracion")
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

---------------------------------------------------------------------
-- FASE 3: PRODUCTOS Y CONFIGURACIONES
---------------------------------------------------------------------

-- 3.1. Tabla "products" (antes "productos")
-- Almacena el catálogo de productos de cada tienda, junto con etiquetas y categorías.
CREATE TABLE products (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id uuid REFERENCES stores(id) ON DELETE CASCADE,  -- (antes "store_id")
    name text NOT NULL,                                     -- (antes "nombre")
    description text,                                       -- (antes "descripcion")
    image_url text,                                         -- (antes "imagen_url")
    price numeric,                                          -- (antes "precio")
    category text,                                          -- (antes "categoria")
    tags text[],                                            -- (antes "tags")
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 3.2. Tabla "product_configurations" (antes "producto_configuraciones")
-- Define las configuraciones o personalizaciones disponibles para un producto.
CREATE TABLE product_configurations (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id uuid REFERENCES products(id) ON DELETE CASCADE,  -- (antes "producto_id")
    name text NOT NULL,                                         -- (antes "nombre")
    range_min int,                                              -- (antes "rango_min")
    range_max int,                                              -- (antes "rango_max")
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    CHECK (range_min >= 0 AND range_max >= range_min)
);

-- 3.3. Tabla "product_options" (antes "producto_opciones")
-- Registra las opciones disponibles para cada configuración, incluyendo costos extras.
CREATE TABLE product_options (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    configuration_id uuid REFERENCES product_configurations(id) ON DELETE CASCADE, -- (antes "configuracion_id")
    name text NOT NULL,                                                            -- (antes "nombre")
    option_min int,                                                                -- (antes "opcion_min")
    option_max int,                                                                -- (antes "opcion_max")
    extra_price numeric DEFAULT 0,                                                 -- (antes "precio_extra")
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    CHECK (option_min >= 0 AND option_max >= option_min)
);

---------------------------------------------------------------------
-- FASE 4: PEDIDOS Y DETALLES
---------------------------------------------------------------------

-- 4.1. Tabla "orders" (antes "pedidos")
-- Registra los pedidos realizados. Se han agregado:
--   - "active": indica si el pedido está activo (antes "activo").
--   - "cancellation_request": campo que el usuario puede modificar (solicitar cancelación) 
--     solo si "active" es true (antes "solicitud_cancelacion").
--   - "user_id": para vincular el pedido con el usuario autenticado (antes "usuario_id").
-- Se asume que la validación de que el horario de la tienda esté activo, y que totales y
-- detalles coincidan, se implementará mediante lógica de negocio (por ejemplo, triggers o validaciones en la aplicación).
CREATE TABLE orders (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id uuid REFERENCES stores(id) ON DELETE CASCADE,      -- (antes "store_id")
    user_id uuid REFERENCES users(auth_id) NOT NULL,            -- (antes "usuario_id")
    customer_name text,                                         -- (antes "nombre_cliente")
    customer_email text CHECK (customer_email = LOWER(customer_email)),  -- (antes "email_cliente")
    customer_phone text,                                        -- (antes "telefono_cliente")
    address_street text,                                        -- (antes "direccion_calle")
    address_number text,                                        -- (antes "direccion_numero")
    address_colony text,                                        -- (antes "direccion_colonia")
    address_zipcode text CHECK (address_zipcode ~ '^\d{4,10}$'),-- (antes "direccion_cp")
    address_city text,                                          -- (antes "direccion_ciudad")
    address_state text,                                         -- (antes "direccion_estado")
    location_lat numeric,                                       -- Latitud (obligatoria en delivery) (antes "ubicacion_lat")
    location_lng numeric,                                       -- Longitud (obligatoria en delivery) (antes "ubicacion_lng")
    delivery_method delivery_method_enum NOT NULL,              -- (antes "metodo_entrega")
    delivery_price numeric CHECK (delivery_price >= 0) DEFAULT 0,   -- (antes "precio_delivery")
    total numeric CHECK (total >= 0),
    status order_status_enum DEFAULT 'pending',                 -- (antes "estado")
    active boolean DEFAULT true,                                -- (antes "activo")
    cancellation_request timestamptz NULL,                      -- (antes "solicitud_cancelacion")
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    CHECK (delivery_method <> 'delivery' OR (location_lat IS NOT NULL AND location_lng IS NOT NULL))
);

-- 4.1.1 Tabla "order_reviews" (antes "pedido_reviews")
-- Registra las valoraciones y comentarios del usuario que realizó el pedido después de recibirlo.
CREATE TABLE order_reviews (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id uuid UNIQUE REFERENCES orders(id) ON DELETE CASCADE,  -- (antes "pedido_id")
    rating numeric CHECK (rating >= 0 AND rating <= 5),            -- (antes "calificacion", 0-5)
    review text,                                                   -- Comentarios del usuario
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 4.2. Tabla "order_products" (antes "pedido_productos")
-- Detalla cada ítem del pedido, vinculando el producto y la cantidad solicitada, además del precio final.
CREATE TABLE order_products (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id uuid REFERENCES orders(id) ON DELETE CASCADE,   -- (antes "pedido_id")
    product_id uuid REFERENCES products(id),                 -- (antes "producto_id")
    quantity int DEFAULT 1,                                  -- (antes "cantidad")
    price numeric CHECK (price >= 0) DEFAULT 0,              -- (antes "precio")
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 4.3. Tabla "order_configurations" (antes "pedido_configuraciones")
-- Registra las configuraciones seleccionadas para cada ítem del pedido.
CREATE TABLE order_configurations (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_item_id uuid REFERENCES order_products(id) ON DELETE CASCADE,  -- (antes "pedido_item_id")
    configuration_id uuid REFERENCES product_configurations(id),         -- (antes "configuracion_id")
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 4.4. Tabla "order_options" (antes "pedido_opciones")
-- Registra las opciones seleccionadas para cada configuración de un ítem, junto con
-- la cantidad elegida y el costo extra aplicado.
CREATE TABLE order_options (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_item_configuration_id uuid REFERENCES order_configurations(id) ON DELETE CASCADE, -- (antes "pedido_item_configuracion_id")
    option_id uuid REFERENCES product_options(id),                                          -- (antes "opcion_id")
    quantity int DEFAULT 0,                                                                 -- (antes "cantidad")
    extra_price numeric DEFAULT 0,                                                          -- (antes "precio_extra")
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
    order_id uuid REFERENCES orders(id) ON DELETE CASCADE,    -- (antes "pedido_id")
    link_token text UNIQUE NOT NULL,                          -- Token único enviado al repartidor
    delivery_user_id uuid,                                    -- (antes "usuario_repartidor")
    repartidor_lat numeric,                                   -- Latitud de la ubicación del repartidor
    repartidor_lng numeric,                                   -- Longitud de la ubicación del repartidor
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);


---------------------------------------------------------------------
-- SECCIÓN: ÍNDICES ADICIONALES: OPTIMIZACIÓN DE CONSULTAS Y BÚSQUEDAS
---------------------------------------------------------------------

-- FASE 1: Users
-- Índice para búsquedas rápidas por email (útil para autenticación o consultas de perfil)
CREATE INDEX idx_users_email ON users(email);

-- Índice para búsquedas por nombre (en caso de filtrar por nombre de usuario)
CREATE INDEX idx_users_name ON users(name);

---------------------------------------------------------------------
-- FASE 2: Stores y Horarios
-- Índice para la tabla store_schedules para búsquedas por días (utilizando GIN para arrays)
CREATE INDEX idx_store_schedules_days ON store_schedules USING gin(days);

-- Índice en la tabla store_schedule_exceptions para búsquedas por fecha
CREATE INDEX idx_store_schedule_exceptions_date ON store_schedule_exceptions(date);

-- Índice en la tabla store_admins para búsquedas por user
CREATE INDEX idx_store_admins_user_id ON store_admins(user_id);

-- Índice en la tabla store_subscriptions para búsquedas por fecha de expiración
CREATE INDEX idx_store_subscriptions_expiration_date ON store_subscriptions(expiration_date);

---------------------------------------------------------------------
-- FASE 3: Products y Configurations
-- Índice para búsquedas en el nombre de products (además del índice en category)
CREATE INDEX idx_products_name ON products(name);

---------------------------------------------------------------------
-- FASE 4: Orders y Detalles
-- Índice en la tabla orders para búsquedas rápidas por user
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Índice en la tabla orders para búsquedas por status
CREATE INDEX idx_orders_status ON orders(status);

-- Índice en la tabla order_products para agrupar ítems por order
CREATE INDEX idx_order_products_order_id ON order_products(order_id);

-- Índice en la tabla orders para búsquedas por fecha de creación
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);

-- Índice en la tabla orders para búsquedas por user y status
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

---------------------------------------------------------------------
-- FASE 5: Información de Delivery
-- Índice en delivery_info para búsquedas por order
CREATE INDEX idx_delivery_info_order_id ON delivery_info(order_id);


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
       - Tiendas (stores)
       - Productos (products)
       - Configuraciones (product_configurations)
       - Opciones (product_options)
       - Horarios (store_schedules)
       - Excepciones de Horarios (store_schedule_exceptions)
   • Siempre que la suscripción de la tienda esté activa.

3. ADMINISTRADORES DE TIENDAS (STORE ADMINS):
   • Operaciones completas (INSERT, UPDATE, DELETE) en su tienda y tablas relacionadas:
       - Horarios (store_schedules)
       - Productos (products)
       - Configuraciones (product_configurations)
       - Opciones (product_options)
   • Pueden modificar su propio registro en la tabla de tiendas (UPDATE) SOLO si la
     suscripción está activa.
   • La relación se verifica a través de la tabla "store_admins".

4. TABLA "USERS":
   • SELECT:
       - Usuarios regulares: Solo su propio registro.
       - Administradores: Cualquier registro.
   • UPDATE:
       - Usuarios regulares: Solo pueden modificar su propio registro en los campos
         "name" y "email" (antes "nombre" y "email").
       - Administradores: Pueden actualizar cualquier registro.
   • DELETE:
       - Usuarios regulares: Solo pueden eliminar su propio registro.
       - Administradores: Pueden eliminar cualquier registro, EXCEPTO el propio.

5. TABLA "ORDERS":
   • Un usuario autenticado puede ver únicamente sus propios orders.
   • Un usuario puede insertar un order siempre que:
       - El campo "user_id" coincida con su propio UUID.
       - La suscripción de la tienda esté activa (expiration_date > now()).
       - El horario de la tienda esté activo.
       - Los totales y detalles del pedido sean correctos (controlado por lógica de negocio o triggers).
   • Un usuario podrá modificar únicamente el campo "cancellation_request" si el pedido está activo.
   • Un usuario podrá ver y modificar registros en "delivery_info" si:
       - El campo "delivery_user_id" es nulo, o
       - El campo "delivery_user_id" coincide con su propio UUID.
   • Un usuario podrá ver un order si está asignado como repartidor en la "delivery_info" del order.
*/

---------------------------------------------------------------------
-- SECCIÓN: TRIGGERS Y FUNCIONES AUXILIARES (POR FASE)
---------------------------------------------------------------------

/*
Ejemplos de funciones y triggers para reforzar la lógica de negocio:

1. Función y trigger en la tabla USERS:
   • Permite que los usuarios regulares solo modifiquen los campos "name" y "phone".
---------------------------------------------------------------
*/
CREATE OR REPLACE FUNCTION check_user_update()
RETURNS TRIGGER AS $$
DECLARE
    current_user uuid;
    is_admin boolean;
BEGIN
    -- Se obtiene el ID del usuario autenticado (configurado por Supabase en jwt.claims.sub)
    SELECT current_setting('jwt.claims.sub')::uuid INTO current_user;
    
    -- Se verifica si el usuario es administrador
    SELECT admin INTO is_admin FROM users WHERE auth_id = current_user;
    
    IF NOT is_admin THEN
        -- Para usuarios regulares, solo se permite modificar "name" y "phone"
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

CREATE TRIGGER trg_check_user_update
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION check_user_update();

/*
   • Permite que se actualicen los datos de los usuarios cuando se crean en Supabase
---------------------------------------------------------------
*/
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (auth_id, email, name, phone) 
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'name', ''), 
    COALESCE(NEW.raw_user_meta_data->>'phone', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

---------------------------------------------------------------
/*
2. Función y trigger en la tabla ORDERS (antes PEDIDOS):
   • Permite que usuarios regulares únicamente modifiquen el campo "cancellation_request"
     (y solo si el pedido está activo). Los administradores globales pueden actualizar libremente.
---------------------------------------------------------------
*/
CREATE OR REPLACE FUNCTION check_order_update()
RETURNS TRIGGER AS $$
DECLARE
    current_user uuid;
    is_admin boolean;
    is_store_admin uuid;
BEGIN
    SELECT current_setting('jwt.claims.sub')::uuid INTO current_user;
    SELECT admin INTO is_admin FROM users WHERE auth_id = current_user;
    
    IF NOT is_admin THEN

        -- Verifica si el usuario es administrador de la tienda del pedido
        SELECT user_id INTO is_store_admin 
        FROM store_admins 
        WHERE store_id = OLD.store_id 
          AND user_id = current_user;
        
        IF is_store_admin IS NULL THEN

          -- Verifica que ningún otro campo se modifique, excepto "cancellation_request"
          IF NEW.store_id IS DISTINCT FROM OLD.store_id OR
            NEW.user_id IS DISTINCT FROM OLD.user_id OR
            NEW.customer_name IS DISTINCT FROM OLD.customer_name OR
            NEW.customer_email IS DISTINCT FROM OLD.customer_email OR
            NEW.customer_phone IS DISTINCT FROM OLD.customer_phone OR
            NEW.address_street IS DISTINCT FROM OLD.address_street OR
            NEW.address_number IS DISTINCT FROM OLD.address_number OR
            NEW.address_colony IS DISTINCT FROM OLD.address_colony OR
            NEW.address_zipcode IS DISTINCT FROM OLD.address_zipcode OR
            NEW.address_city IS DISTINCT FROM OLD.address_city OR
            NEW.address_state IS DISTINCT FROM OLD.address_state OR
            NEW.location_lat IS DISTINCT FROM OLD.location_lat OR
            NEW.location_lng IS DISTINCT FROM OLD.location_lng OR
            NEW.delivery_method IS DISTINCT FROM OLD.delivery_method OR
            NEW.delivery_price IS DISTINCT FROM OLD.delivery_price OR
            NEW.total IS DISTINCT FROM OLD.total OR
            NEW.status IS DISTINCT FROM OLD.status OR
            NEW.active IS DISTINCT FROM OLD.active THEN
              RAISE EXCEPTION 'Usuario no autorizado para modificar campos distintos a cancellation_request';
          END IF;
          
          IF NEW.cancellation_request IS DISTINCT FROM OLD.cancellation_request THEN
              IF NOT OLD.active THEN
                  RAISE EXCEPTION 'No se puede modificar cancellation_request en un pedido inactivo';
              END IF;
          END IF;
        
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_order_update
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION check_order_update();

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

-- FASE 1: Users
CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- FASE 2: Stores y Horarios
CREATE TRIGGER trg_stores_updated_at
BEFORE UPDATE ON stores
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_store_schedules_updated_at
BEFORE UPDATE ON store_schedules
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_store_schedule_exceptions_updated_at
BEFORE UPDATE ON store_schedule_exceptions
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_store_admins_updated_at
BEFORE UPDATE ON store_admins
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- FASE 3: Products y Configuraciones
CREATE TRIGGER trg_products_updated_at
BEFORE UPDATE ON products
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_product_configurations_updated_at
BEFORE UPDATE ON product_configurations
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_product_options_updated_at
BEFORE UPDATE ON product_options
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- FASE 4: Orders y Detalles
CREATE TRIGGER trg_orders_updated_at
BEFORE UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_order_products_updated_at
BEFORE UPDATE ON order_products
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_order_configurations_updated_at
BEFORE UPDATE ON order_configurations
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_order_options_updated_at
BEFORE UPDATE ON order_options
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- FASE 5: Delivery
CREATE TRIGGER trg_delivery_info_updated_at
BEFORE UPDATE ON delivery_info
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


---------------------------------------------------------------
/*
4. Función auxiliar para verificar si una tienda está abierta para pedidos (antes "store_horario_activo").
---------------------------------------------------------------
*/
CREATE OR REPLACE FUNCTION store_schedule_active(store uuid)
RETURNS boolean AS $$
DECLARE
  current_date date := CURRENT_DATE;
  current_time time := CURRENT_TIME;
  current_dow integer := EXTRACT(ISODOW FROM now())::integer; -- 1=lunes, 7=domingo
  exception_record RECORD;
  regular_record RECORD;
  is_open boolean := false;
BEGIN
  -- Verificar si existe una excepción para la tienda en la fecha actual
  SELECT *
  INTO exception_record
  FROM store_schedule_exceptions
  WHERE store_id = store
    AND date = current_date
  LIMIT 1;
  
  IF exception_record IS NOT NULL THEN
    -- Si se marca como cerrado en la excepción, la tienda está cerrada
    IF exception_record.is_closed THEN
      RETURN false;
    ELSE
      -- Si hay horario especial, se comprueba si la hora actual está dentro del rango especial
      IF current_time >= exception_record.opening_time 
         AND current_time <= exception_record.closing_time THEN
         RETURN true;
      ELSE
         RETURN false;
      END IF;
    END IF;
  END IF;
  
  -- En ausencia de excepción, se verifica el horario regular
  FOR regular_record IN
    SELECT *
    FROM store_schedules
    WHERE store_id = store
  LOOP
    -- Se verifica que el día actual se encuentre en el arreglo de días y que la hora esté dentro del rango
    IF current_dow = ANY(regular_record.days) THEN
      IF current_time >= regular_record.opening_time 
         AND current_time <= regular_record.closing_time THEN
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
5. Función auxiliar para verificar si un pedido es consistente con la tienda
   (antes "verificar_consistencia_pedido").
---------------------------------------------------------------
*/
CREATE OR REPLACE FUNCTION verify_order_consistency()
RETURNS TRIGGER AS $$
DECLARE
    suma_total numeric := 0;
    prod RECORD;
    suma_opciones numeric;
    prod_store uuid;
BEGIN
    -- Recorre cada producto asociado al pedido
    FOR prod IN
        SELECT id, quantity, price, product_id
        FROM order_products
        WHERE order_id = NEW.id
    LOOP
        -- Verificar que el producto pertenece a la tienda del pedido
        SELECT store_id INTO prod_store
        FROM products
        WHERE id = prod.product_id;
        
        IF prod_store IS NULL OR prod_store <> NEW.store_id THEN
            RAISE EXCEPTION 'El producto % no pertenece a la tienda del pedido', prod.product_id;
        END IF;
        
        -- Sumar el costo base del producto (price * quantity)
        suma_total := suma_total + (prod.price * prod.quantity);
        
        -- Sumar el costo extra de las opciones asociadas
        SELECT COALESCE(SUM(o.extra_price * o.quantity), 0)
          INTO suma_opciones
          FROM order_configurations c
          JOIN order_options o ON o.order_item_configuration_id = c.id
          WHERE c.order_item_id = prod.id;
        
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
CREATE CONSTRAINT TRIGGER trg_verify_order_consistency
AFTER INSERT ON orders
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION verify_order_consistency();

---------------------------------------------------------------------
-- SECCIÓN: HABILITACIÓN DE ROW LEVEL SECURITY (RLS)
---------------------------------------------------------------------

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_schedule_exceptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_configurations ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_configurations ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_options ENABLE ROW LEVEL SECURITY;
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
  FROM public.users 
  WHERE auth_id = auth.uid();
  RETURN admin_status;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;



---------------------------------------------------------------------
-- SECCIÓN: POLÍTICAS DE SEGURIDAD (RLS)
---------------------------------------------------------------------

-- Tabla USERS (antes "usuarios")

-- 1.a. Administrador global: acceso total en la tabla (salvo eliminación de su propio registro)
CREATE POLICY admin_full_access ON users
FOR ALL
USING (
  public.is_global_admin()
);

-- 1.b. Usuario regular: puede SELECT, UPDATE y DELETE únicamente su propio registro.
CREATE POLICY user_self_access ON users
FOR ALL
USING ( auth.uid() = users.auth_id )
WITH CHECK ( auth.uid() = users.auth_id );

---------------------------------------------------------------------
-- Tablas de STORES (antes "stores") y Horarios

-- 2.a. Lectura Pública de stores:
-- Permite la lectura si la suscripción de la tienda está activa, o el usuario es administrador
-- global o administrador de la tienda.
CREATE POLICY public_read_stores ON stores
FOR SELECT
USING (
    EXISTS (
      SELECT 1 FROM store_subscriptions ss
      WHERE ss.store_id = stores.id
        AND ss.expiration_date > now()
    )
    OR EXISTS (
      SELECT 1 FROM store_admins sa
      WHERE sa.store_id = stores.id AND sa.user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);

-- 2.b. Modificación de stores:
-- Permite UPDATE solo a administradores de la tienda y únicamente cuando la suscripción esté activa.
CREATE POLICY update_stores_admin ON stores
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM store_admins sa
    WHERE sa.store_id = stores.id AND sa.user_id = auth.uid()
  )
  OR EXISTS (
    SELECT 1 FROM store_subscriptions ss
    WHERE ss.store_id = stores.id
      AND ss.expiration_date > now()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM store_admins sa
    WHERE sa.store_id = stores.id OR sa.user_id = auth.uid()
  )
);

-- Permite modificar y eliminar stores solo si es el administrador global.
CREATE POLICY update_stores_admin_global ON stores
FOR ALL
USING (
 EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);

-- 2.c. Horarios (store_schedules) y Excepciones de horarios (store_schedule_exceptions):
-- Lectura pública y modificación solo para administradores de la tienda.

-- Política de lectura pública para la tabla store_schedules
CREATE POLICY public_read_store_schedules ON store_schedules
FOR SELECT
USING (
    EXISTS (
      SELECT 1 FROM store_subscriptions ss
      WHERE ss.store_id = store_schedules.store_id
        AND ss.expiration_date > now()
    )
    OR EXISTS (
      SELECT 1 FROM store_admins sa
      WHERE sa.store_id = store_schedules.store_id
        AND sa.user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);

-- Política de modificación (INSERT, UPDATE, DELETE) para la tabla store_schedules
CREATE POLICY modify_store_schedules_admin ON store_schedules
FOR ALL
USING (
    EXISTS (
      SELECT 1 FROM store_admins sa
      WHERE sa.store_id = store_schedules.store_id
        AND sa.user_id = auth.uid()
    )
);

-- POLÍTICAS PARA LA TABLA store_schedule_exceptions

-- Política de lectura pública para la tabla store_schedule_exceptions
CREATE POLICY public_read_store_schedule_exceptions ON store_schedule_exceptions
FOR SELECT
USING (
    EXISTS (
      SELECT 1 FROM store_subscriptions ss
      WHERE ss.store_id = store_schedule_exceptions.store_id
        AND ss.expiration_date > now()
    )
    OR EXISTS (
      SELECT 1 FROM store_admins sa
      WHERE sa.store_id = store_schedule_exceptions.store_id
        AND sa.user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);

-- Política de modificación (INSERT, UPDATE, DELETE) para la tabla store_schedule_exceptions
CREATE POLICY modify_store_schedule_exceptions_admin ON store_schedule_exceptions
FOR ALL
USING (
    EXISTS (
      SELECT 1 FROM store_admins sa
      WHERE sa.store_id = store_schedule_exceptions.store_id
        AND sa.user_id = auth.uid()
    )
);

---------------------------------------------------------------------
-- Tabla de store_subscriptions (antes "store_suscripciones")

-- 2.1.a. Lectura Pública de suscripciones:
CREATE POLICY public_read_store_subscriptions ON store_subscriptions
FOR SELECT
USING (true);

-- 2.1.b. Modificación de suscripciones:
-- Permite insertar, actualizar y eliminar suscripciones de tiendas siempre que:
--   - El usuario es administrador global.
CREATE POLICY modify_store_subscriptions_admin ON store_subscriptions
FOR ALL
USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);

CREATE POLICY public_read_store_admins ON store_admins
FOR SELECT
USING (true);

CREATE POLICY modify_store_admins ON store_admins
FOR ALL
USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);

---------------------------------------------------------------------
-- Tablas de PRODUCTS y CONFIGURATIONS

-- 3.a. Lectura Pública de products, configurations y options:
CREATE POLICY public_read_products ON products
FOR SELECT
USING (
    EXISTS (
      SELECT 1 FROM store_subscriptions ss
      WHERE ss.store_id = products.store_id
        AND ss.expiration_date > now()
    )
    OR EXISTS (
      SELECT 1 FROM store_admins sa
      WHERE sa.store_id = products.store_id AND sa.user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);

CREATE POLICY public_read_product_configurations ON product_configurations
FOR SELECT
USING (
    EXISTS (
      SELECT 1
      FROM store_subscriptions ss
      JOIN products p ON p.store_id = ss.store_id
      WHERE p.id = product_configurations.product_id
        AND ss.expiration_date > now()
    )
    OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    OR EXISTS (
      SELECT 1
      FROM store_admins sa
      JOIN products p ON p.store_id = sa.store_id
      WHERE p.id = product_configurations.product_id
        AND sa.user_id = auth.uid()
    )
);

CREATE POLICY public_read_product_options ON product_options
FOR SELECT
USING (
    EXISTS (
      SELECT 1
      FROM store_subscriptions ss
      JOIN product_configurations pc ON pc.id = product_options.configuration_id
      JOIN products p ON p.id = pc.product_id
      WHERE ss.store_id = p.store_id
        AND ss.expiration_date > now()
    )
    OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    OR EXISTS (
      SELECT 1
      FROM store_admins sa
      JOIN product_configurations pc ON pc.id = product_options.configuration_id
      JOIN products p ON p.id = pc.product_id
      WHERE sa.store_id = p.store_id
        AND sa.user_id = auth.uid()
    )
);

-- 3.b. Modificación de products:
-- Solo administradores de la tienda pueden insertar, actualizar o eliminar productos.
-- Los usuarios administradores globales pueden modificar productos siempre.
CREATE POLICY modify_products_admin ON products
FOR ALL
USING (
   EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    OR EXISTS (
      SELECT 1 FROM store_admins sa
      WHERE sa.store_id = products.store_id AND sa.user_id = auth.uid()
    )
);

-- 3.c. Modificación de configuraciones y opciones:
CREATE POLICY modify_product_configurations_admin ON product_configurations
FOR ALL
USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    OR EXISTS (
      SELECT 1 FROM store_admins sa
      JOIN products p ON p.id = product_configurations.product_id
      WHERE sa.store_id = p.store_id AND sa.user_id = auth.uid()
    )
);

CREATE POLICY modify_product_options_admin ON product_options
FOR ALL
USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    OR EXISTS (
      SELECT 1
      FROM store_admins sa
      JOIN product_configurations pc ON pc.id = product_options.configuration_id
      JOIN products p ON p.id = pc.product_id
      WHERE sa.store_id = p.store_id AND sa.user_id = auth.uid()
    )
);


---------------------------------------------------------------------
-- Tabla ORDERS (antes "pedidos")

-- 4.a. Selección (SELECT):
-- El pedido es visible si:
--   - El usuario es el que realizó el pedido,
--   - El usuario está asignado como repartidor en delivery_info,
--   - O el usuario es administrador global.
--   - O el usuario es administrador de la tienda.
CREATE POLICY select_own_orders ON orders
FOR SELECT
USING (
    user_id = auth.uid()
    OR EXISTS (
       SELECT 1 FROM delivery_info di
       WHERE di.order_id = orders.id
         AND di.delivery_user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    OR EXISTS (
      SELECT 1 FROM store_admins sa
      WHERE sa.store_id = orders.store_id
        AND sa.user_id = auth.uid()
    )
);

-- 4.b. Inserción (INSERT):
-- Se permite si:
--   - El usuario que inserta coincide con el user_id del pedido.
--   - La suscripción de la tienda está activa.
--   - La tienda se encuentra abierta (verificado mediante la función auxiliar store_schedule_active).
CREATE POLICY insert_orders ON orders
FOR INSERT
WITH CHECK (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM store_subscriptions ss
      WHERE ss.store_id = orders.store_id
        AND ss.expiration_date > now()
    )
    AND store_schedule_active(orders.store_id)
);

-- 4.c. Actualización (UPDATE):
-- Permite que el usuario propietario del pedido (o un administrador global o administrador de la tienda) pueda actualizar.
-- Se complementa con el trigger "check_order_update" que verifica restricciones adicionales.
CREATE POLICY update_orders_user ON orders
FOR UPDATE
USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    OR EXISTS (
      SELECT 1 FROM store_admins sa
      WHERE sa.store_id = orders.store_id
        AND sa.user_id = auth.uid()
    )
);

-- 4.d. Eliminación (DELETE):
-- Restringe la eliminación de pedidos a administradores globales.
CREATE POLICY delete_orders_admin ON orders
FOR DELETE
USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);

---------------------------------------------------------------------
-- Tabla DELIVERY_INFO

-- 5.a. Selección (SELECT):
-- Un registro de delivery es visible si:
--   - El usuario es el propietario del pedido,
--   - O coincide con el repartidor asignado (delivery_user_id),
--   - O es administrador global.
--   - O el usuario es administrador de la tienda.
CREATE POLICY select_delivery_info ON delivery_info
FOR SELECT
USING (
    EXISTS (
       SELECT 1 FROM orders o
       WHERE o.id = delivery_info.order_id AND o.user_id = auth.uid()
    )
    OR delivery_user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    OR EXISTS (
      SELECT 1
      FROM store_admins sa
      JOIN orders o ON o.store_id = sa.store_id
      WHERE o.id = delivery_info.order_id
        AND sa.user_id = auth.uid()
    )
);

-- 5.b. Inserción:
-- Se permite insertar un registro en delivery_info si:
--   - El usuario es administrador de la tienda.
--   - O es administrador global.
CREATE POLICY insert_delivery_info ON delivery_info
FOR INSERT
WITH CHECK (
    EXISTS (
       SELECT 1
       FROM store_admins sa
       JOIN orders o ON o.store_id = sa.store_id
       WHERE o.id = delivery_info.order_id
         AND sa.user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);

-- 5.c. Actualización:
-- Se permite actualizar delivery_info si:
--   - El campo delivery_user_id es nulo o coincide con el usuario autenticado,
--   - O el usuario es administrador global,
--   - O el usuario es administrador de la tienda.
CREATE POLICY update_delivery_info ON delivery_info
FOR UPDATE
USING (
    (delivery_user_id IS NULL OR delivery_user_id = auth.uid())
    OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
    OR EXISTS (
       SELECT 1
       FROM store_admins sa
       JOIN orders o ON o.store_id = sa.store_id
       WHERE o.id = delivery_info.order_id
         AND sa.user_id = auth.uid()
    )
);

-- 5.d. Eliminación:
-- Restringida a administradores globales.
CREATE POLICY delete_delivery_info_admin ON delivery_info
FOR DELETE
USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);


---------------------------------------------------------------------
-- Tabla de order_reviews (antes "pedido_reviews")
-- Política de lectura pública: cualquier usuario puede leer las reviews
CREATE POLICY public_read_order_reviews ON order_reviews
FOR SELECT
USING (true);

-- Política de inserción: solo se puede insertar si el usuario autenticado es el dueño del pedido o admin global
CREATE POLICY insert_order_reviews ON order_reviews
FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1 FROM orders
        WHERE id = order_reviews.order_id
          AND user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);

-- Política de actualización: solo el dueño del pedido o admin global
CREATE POLICY update_order_reviews ON order_reviews
FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM orders
        WHERE id = order_reviews.order_id
          AND user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);

-- Política de eliminación: solo el dueño del pedido o admin global
CREATE POLICY delete_order_reviews ON order_reviews
FOR DELETE
USING (
    EXISTS (
        SELECT 1 FROM orders
        WHERE id = order_reviews.order_id
          AND user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = auth.uid() AND u.admin = true
    )
);
