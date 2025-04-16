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

-- Se utiliza para definir los tipos de suscripciones de las comercios
CREATE TYPE subscription_type_enum AS ENUM ('general', 'special', 'premium');

-- Se utiliza para definir los estados de los pedidos
CREATE TYPE order_status_enum AS ENUM ('pending', 'accepted', 'on_the_way', 'delivered', 'cancelled');

-- Se utiliza para definir los métodos de entrega de los pedidos
CREATE TYPE delivery_method_enum AS ENUM ('delivery','pickup');


---------------------------------------------------------------------
-- 1: USUARIOS Y AUTENTICACIÓN
---------------------------------------------------------------------

-- 1.1. Tablas
-- users
-- Esta tabla almacena información adicional del usuario, distinta de la información de autenticación
-- Se agrega el campo "auth_id" para relacionar el registro con la tabla nativa auth.users de Supabase.
CREATE TABLE users (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_id uuid UNIQUE NOT NULL,                -- Vincula el registro con auth.users
    email text UNIQUE CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' AND email = LOWER(email)),
    name text NOT NULL,
    phone text CHECK (phone IS NULL OR phone ~ '^\+?[0-9]{7,15}$'),
    picture text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- admin_global
-- Esta tabla almacena los usuarios administradores globales.
CREATE TABLE admin_global (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_id uuid REFERENCES users(auth_id) ON DELETE CASCADE UNIQUE NOT NULL, -- Vincula el registro con auth.users
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

ALTER TABLE admin_global ENABLE ROW LEVEL SECURITY;

-- 1.2 Funcion para agregar un usuario en la tabla "users" después de crear su registro en auth.users.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (auth_id, email, name, phone, picture)
  VALUES (
    NEW.id,  
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', ''), 
    COALESCE(NEW.raw_user_meta_data->>'phone', null),
    COALESCE(NEW.raw_user_meta_data->>'picture', null)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 1.3 Funciones auxiliares
CREATE OR REPLACE FUNCTION public.is_global_admin()
RETURNS boolean
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM admin_global
    WHERE auth_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE POLICY admin_global_access ON admin_global
FOR ALL
USING (
  public.is_global_admin()
);


-- 1.4 Politicas "users" y "admin_global".

-- 1.4.1 Politicas "users".

-- Admin global
CREATE POLICY admin_users_access ON users
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM admin_global ag
    WHERE ag.auth_id = auth.uid()
  )
);

-- Usuario regular
CREATE POLICY user_self_access ON users
FOR ALL
USING ( auth.uid() = users.auth_id )
WITH CHECK ( auth.uid() = users.auth_id );

-- 1.4.2 Politicas "admin_global".
CREATE POLICY admin_global_access ON admin_global
FOR ALL
USING (
  public.is_global_admin()
);




-- 1.5 View para obtener los datos publicos de los usuarios

-- Crea la vista con los campos públicos deseados
CREATE OR REPLACE VIEW public.users_public AS
SELECT id, name, picture
FROM public.users

---------------------------------------------------------------------
-- 2: ComercioS (COMERCIOS) 
---------------------------------------------------------------------

-- 2.1. Tablas
-- stores
CREATE TABLE stores (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text NOT NULL CHECK (TRIM(name) <> ''),
    logo_url text,                                              -- URL o ruta del logo de el comercio
    address_street text,
    address_number text,
    address_colony text,
    address_zipcode text CHECK (address_zipcode ~ '^\d{4,10}$'),
    address_city text,
    address_state text,
    country_code text CHECK (country_code ~ '^[A-Z]{2,3}$'),    -- Código de país (ej. "MX", "US")
    timezone text DEFAULT 'UTC',
    lat numeric,                                                -- Latitud geográfica
    lng numeric,                                                -- Longitud geográfica
    geom geometry(Polygon, 4326),                               -- Polígono para delimitar la zona de delivery (SRID 4326)
    whatsapp text CHECK (whatsapp ~ '^\+?[0-9]{7,15}$'),
    whatsapp_allow boolean DEFAULT false,
    facebook_link text,
    instagram_link text,
    delivery_minimum_order numeric DEFAULT 0, 
    pickup boolean DEFAULT false,
    delivery boolean DEFAULT false,
    delivery_price numeric DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

ALTER TABLE stores ENABLE ROW LEVEL SECURITY;

-- store_admins
CREATE TABLE store_admins (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id uuid REFERENCES stores(id) ON DELETE CASCADE,
    user_id uuid UNIQUE REFERENCES users(id) ON DELETE CASCADE,

    -- Datos de contacto (obligatorios)
    contact_name text NOT NULL,
    contact_email text NOT NULL CHECK (contact_email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    contact_phone text NOT NULL CHECK (contact_phone ~ '^\+?[0-9]{7,15}$'),

    -- Bandera de contacto principal
    is_primary_contact boolean NOT NULL DEFAULT false,

    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

ALTER TABLE store_admins ENABLE ROW LEVEL SECURITY;

-- store_subscriptions
CREATE TABLE store_subscriptions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id uuid UNIQUE REFERENCES stores(id) ON DELETE CASCADE,
    subscription_type subscription_type_enum NOT NULL DEFAULT 'general',
    expiration_date timestamptz DEFAULT (now() - interval '2 day'),  -- Genera una suscripción inactiva por defecto.
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

ALTER TABLE store_subscriptions ENABLE ROW LEVEL SECURITY;

-- 2.2. Funciones auxiliares

-- Funcion para generar una store, una suscripción y un admin global, recibe como parámetros el nombre de el comercio.
-- Se hace admin de el comercio al usuario autenticado.
-- 2.2. Función para registrar una comercio junto con su suscripción y admin
CREATE OR REPLACE FUNCTION public.create_store(
    store_id uuid,
    store_name text,
    contact_name text,
    contact_email text,
    contact_phone text,
    country_code text,
    timezone text
)

RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    new_store_id uuid;
    existing_store_count integer;
    current_user_id uuid;
BEGIN
    -- Validaciones mínimas
    IF store_name IS NULL OR TRIM(store_name) = '' THEN
        RAISE EXCEPTION 'El nombre de el comercio no puede estar vacío.';
    ELSIF contact_name IS NULL OR TRIM(contact_name) = '' THEN
        RAISE EXCEPTION 'El nombre del contacto no puede estar vacío.';
    ELSIF contact_email IS NULL OR contact_email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'El correo electrónico del contacto no es válido.';
    ELSIF contact_phone IS NULL OR contact_phone !~ '^\+?[0-9]{7,15}$' THEN
        RAISE EXCEPTION 'El teléfono del contacto no es válido.';
    END IF;

    -- Obtener el identificador interno de usuario basado en auth.uid()
    SELECT id
      INTO current_user_id
      FROM users
      WHERE auth_id = auth.uid();

    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuario no encontrado en la tabla de users para auth.uid()';
    END IF;

    -- Verifica que el usuario no sea admin en otra comercio
    SELECT COUNT(*) INTO existing_store_count
    FROM store_admins
    WHERE user_id = current_user_id;

    IF existing_store_count > 0 THEN
        RAISE EXCEPTION 'El usuario ya es administrador de otra comercio.';
    END IF;

    -- Crear comercio
    INSERT INTO stores (
        id, name, country_code, timezone
    )
    VALUES (
        store_id, TRIM(store_name), country_code, timezone
    )
    RETURNING id INTO new_store_id;

    -- Crear suscripción
    INSERT INTO store_subscriptions (store_id)
    VALUES (new_store_id);

    -- Crear admin con contacto principal
    INSERT INTO store_admins (
        store_id, user_id, contact_name, contact_email, contact_phone, is_primary_contact
    )
    VALUES (
        new_store_id, current_user_id, contact_name, contact_email, contact_phone, true
    );

    RETURN new_store_id;
END;
$$;

-- Función auxiliar para verificar si un usuario es administrador de una comercio
CREATE OR REPLACE FUNCTION public.is_store_admin(target_store_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1
    FROM store_admins sa
    JOIN users u ON u.id = sa.user_id
    WHERE sa.store_id = target_store_id
      AND u.auth_id = auth.uid()
  );
$$;

-- Función auxiliar para verificar una comercio tiene su subscripcion activa 
CREATE OR REPLACE FUNCTION public.is_store_subscription_active(target_store_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1
    FROM store_subscriptions
    WHERE store_id = target_store_id
      AND expiration_date >= current_date
  );
$$;



-- 2.3 Politicas de seguridad

-- Table: stores
---------------------------------------------------------------------
--              | ALL | SELECT | INSERT | UPDATE | DELETE |
-- admin_global |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- store_admin  |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- public       |  X  |    ✓*   |    X   |    X   |    X   |
-- * Se permite el acceso público solo si la expiration_date está en el futuro.
-- store_admin  se refiere al registro de su propia comercio.
---------------------------------------------------------------------
-- Permitir acceso completo a admin_global
-- Permitir acceso completo a store_admin de su propia comercio
CREATE POLICY admin_stores_access ON stores
FOR ALL
USING (
  public.is_store_admin(stores.id)
  OR public.is_global_admin()
);

-- Permitir lectura pública solo si la suscripción está activa
CREATE POLICY public_stores_access ON stores
FOR SELECT
USING (
  public.is_store_subscription_active(stores.id)
);

-- Table: store_admins
---------------------------------------------------------------------
--              | ALL | SELECT | INSERT | UPDATE | DELETE |
-- admin_global |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- store_admin  |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- public       |  X  |    X   |    X   |    X   |    X   |
-- store_admin  se refiere al registro de su propia comercio.
---------------------------------------------------------------------

-- Select
CREATE POLICY store_admins_select ON store_admins
FOR SELECT
USING (
  public.is_store_admin(store_admins.store_id)
  OR public.is_global_admin()
);

-- Insert
CREATE POLICY store_admins_insert ON store_admins
FOR INSERT
WITH CHECK (
  public.is_store_admin(store_admins.store_id)
  OR public.is_global_admin()
);

-- Update
CREATE POLICY store_admins_update ON store_admins
FOR UPDATE
USING (
  public.is_store_admin(store_admins.store_id)
  OR public.is_global_admin()
)
WITH CHECK (
  store_id = store_admins.store_id -- impide cambiar el store_id
);

-- Delete
CREATE POLICY store_admins_delete ON store_admins
FOR DELETE
USING (
  public.is_store_admin(store_admins.store_id)
  OR public.is_global_admin()
);

-- Table: store_subscriptions
---------------------------------------------------------------------
--              | ALL | SELECT | INSERT | UPDATE | DELETE |
-- admin_global |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- store_admin  |  X  |    ✓   |    X   |    X   |    X   |
-- public       |  X  |    X   |    X   |    X   |    X   |
-- store_admin  se refiere al registro de su propia comercio.
---------------------------------------------------------------------

-- Permitir acceso completo a admin_global
CREATE POLICY admin_global_store_subscriptions_access ON store_subscriptions
FOR ALL
USING (
  public.is_global_admin()
);

-- Permitir lectura a store_admin de su comercio
CREATE POLICY store_admin_store_subscriptions_access ON store_subscriptions
FOR SELECT
USING (
  public.is_store_admin(store_subscriptions.store_id)
);

-- 2.4 Vistas para obtener los datos del comercio
CREATE OR REPLACE VIEW public.store_info WITH (security_invoker = on) AS
SELECT 
    s.id,
    s.name,
    s.logo_url,
    s.country_code,
    s.timezone,
    s.lat,
    s.lng,
    s.created_at,
    ss.subscription_type,
    ss.expiration_date
FROM stores s
LEFT JOIN store_subscriptions ss ON ss.store_id = s.id;


---------------------------------------------------------------------
-- 3: HORARIOS DE COMERCIOS
---------------------------------------------------------------------

-- 3.1: Tablas 
-- Registra los horarios regulares de apertura y cierre para cada comercio.
CREATE TABLE store_schedules (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id uuid REFERENCES stores(id) ON DELETE CASCADE,  
    days int[] DEFAULT '{}',                             -- "dias"; 1 = lunes, ... , 7 = domingo  
    opening_time time,
    closing_time time,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

ALTER TABLE store_schedules ENABLE ROW LEVEL SECURITY;

-- Registra excepciones en el horario, por ejemplo, festivos o días especiales.
CREATE TABLE store_schedule_exceptions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id uuid REFERENCES stores(id) ON DELETE CASCADE,
    date date NOT NULL,
    is_closed boolean DEFAULT false,
    opening_time time,
    closing_time time,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

ALTER TABLE store_schedule_exceptions ENABLE ROW LEVEL SECURITY;

-- 3.2: Funciones auxiliares

-- Funcion para verificar si un comercio está abierto
CREATE OR REPLACE FUNCTION public.store_is_open(s stores)
RETURNS boolean AS $$
DECLARE
    local_ts timestamp without time zone;
    local_date date;
    local_time time;
    day_of_week int;
    exception_record record;
    schedule_record record;
BEGIN
    -- Convertir CURRENT_TIMESTAMP a la zona horaria del comercio.
    SELECT CURRENT_TIMESTAMP AT TIME ZONE s.timezone INTO local_ts;
    local_date := local_ts::date;
    local_time := local_ts::time;
    
    -- Obtener el día de la semana (ajustar para que 1 = lunes y 7 = domingo)
    SELECT EXTRACT(DOW FROM local_ts)::int INTO day_of_week;
    IF day_of_week = 0 THEN
        day_of_week := 7;
    END IF;
    
    -- Verificar si existe una excepción para la fecha actual.
    SELECT *
    INTO exception_record
    FROM store_schedule_exceptions
    WHERE store_id = s.id
      AND date = local_date
    LIMIT 1;
    
    IF FOUND THEN
        IF exception_record.is_closed THEN
            RETURN false;
        ELSE
            IF local_time >= exception_record.opening_time AND local_time <= exception_record.closing_time THEN
                RETURN true;
            ELSE
                RETURN false;
            END IF;
        END IF;
    END IF;
    
    -- Verificar en los horarios regulares.
    FOR schedule_record IN
         SELECT *
         FROM store_schedules
         WHERE store_id = s.id
    LOOP
        IF day_of_week = ANY(schedule_record.days) THEN
            IF local_time >= schedule_record.opening_time AND local_time <= schedule_record.closing_time THEN
                RETURN true;
            END IF;
        END IF;
    END LOOP;
    
    RETURN false;
END;
$$ LANGUAGE plpgsql;

-- 3.3: Politicas de seguridad

-- Table: store_schedules
---------------------------------------------------------------------
--              | ALL | SELECT | INSERT | UPDATE | DELETE |
-- admin_global |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- store_admin  |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- public       |  X  |    ✓*   |    X   |    X   |    X   |
-- * Se permite el acceso público solo si la store tiene su subscripción activa.
-- store_admin  se refiere al registro de su propia comercio.
---------------------------------------------------------------------

-- Permitir acceso completo a admin_global y store_admin de su propia comercio
CREATE POLICY admin_store_schedules_access ON store_schedules
FOR ALL
USING (
  public.is_store_admin(store_schedules.store_id)
  OR public.is_global_admin()
);

-- Permitir lectura pública solo si la suscripción está activa
CREATE POLICY public_store_schedules_access ON store_schedules
FOR SELECT
USING (
  public.is_store_subscription_active(store_schedules.store_id)
);

-- Table: store_schedule_exceptions
---------------------------------------------------------------------
--              | ALL | SELECT | INSERT | UPDATE | DELETE |
-- admin_global |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- store_admin  |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- public       |  X  |    ✓*   |    X   |    X   |    X   |
-- * Se permite el acceso público solo si la store tiene su subscripción activa.
-- store_admin  se refiere al registro de su propia comercio.
---------------------------------------------------------------------

-- Permitir acceso completo a admin_global y store_admin de su propia comercio
CREATE POLICY admin_store_exceptions_access ON store_schedule_exceptions
FOR ALL
USING (
  public.is_store_admin(store_schedule_exceptions.store_id)
  OR public.is_global_admin()
);

-- Permitir lectura pública solo si la suscripción está activa
CREATE POLICY public_store_exceptions_access ON store_schedule_exceptions
FOR SELECT
USING (
  public.is_store_subscription_active(store_schedule_exceptions.store_id)
);

---------------------------------------------------------------------
-- 4: IMGUR DE COMERCIOS
---------------------------------------------------------------------

-- 4.1: Tablas
-- Registra las configuraciones de imagen de los comercios.
CREATE TABLE store_images (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id uuid UNIQUE REFERENCES stores(id) ON DELETE CASCADE,
    imgur_client_id text NOT NULL,                      -- Imgur Client ID
    imgur_client_secret text NOT NULL,                  -- Imgur Client Secret
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

ALTER TABLE store_images ENABLE ROW LEVEL SECURITY;

-- 4.2: Politicas de seguridad

-- Table: store_images
---------------------------------------------------------------------
--              | ALL | SELECT | INSERT | UPDATE | DELETE |
-- admin_global |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- store_admin  |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- public       |  X  |    X    |    X   |    X   |    X   |
-- store_admin  se refiere al registro de su propia comercio.
---------------------------------------------------------------------

-- Permitir acceso completo a admin_global y store_admin de su propia comercio
CREATE POLICY admin_store_images_access ON store_images
FOR ALL
USING (
  public.is_store_admin(store_images.store_id)
  OR public.is_global_admin()
);

---------------------------------------------------------------------
-- 5: PRODUCTOS 
---------------------------------------------------------------------

-- 5.1: Tablas

-- category
-- Registra las categorías de productos.
CREATE TABLE products_categories (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id uuid REFERENCES stores(id) ON DELETE CASCADE, 
    name text NOT NULL CHECK (TRIM(name) <> ''),
    description text,
    position int DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

ALTER TABLE products_categories ENABLE ROW LEVEL SECURITY;

-- productos
-- Registra los productos de el comercio.
CREATE TABLE products (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id uuid REFERENCES stores(id) ON DELETE CASCADE NOT NULL,
    category_id uuid REFERENCES products_categories(id) ON DELETE CASCADE NOT NULL,
    name text NOT NULL,
    description text,
    image_url text,
    regular_price numeric NOT NULL CHECK (regular_price >= 0),
    sale_price numeric CHECK (sale_price >= 0 AND sale_price < regular_price),
    sale_start date,
    sale_end date,
    currency text DEFAULT 'MXN',
    tags text[] DEFAULT '{}',
    active boolean DEFAULT true,
    days int[] DEFAULT '{}',                             -- "dias"; 1 = lunes, ... , 7 = domingo donde esta disponible
    position int DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- product_configurations
-- Registra las configuraciones disponibles para un producto.
CREATE TABLE product_configurations (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id uuid REFERENCES stores(id) ON DELETE CASCADE NOT NULL,
    product_id uuid REFERENCES products(id) ON DELETE CASCADE NOT NULL,
    name text NOT NULL,
    description text,
    range_min int,
    range_max int,
    position int DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    CHECK (range_min >= 0 AND range_max >= range_min)
);

ALTER TABLE product_configurations ENABLE ROW LEVEL SECURITY;

-- product_options
-- Registra las opciones disponibles para cada configuración, incluyendo costos extras.
CREATE TABLE product_options (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id uuid REFERENCES stores(id) ON DELETE CASCADE NOT NULL,
    product_id uuid REFERENCES products(id) ON DELETE CASCADE NOT NULL,
    product_configuration_id uuid REFERENCES product_configurations(id) ON DELETE CASCADE NOT NULL,
    name text NOT NULL,
    range_min int,
    range_max int,
    extra_price numeric DEFAULT 0,
    position int DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    CHECK (range_min >= 0 AND range_max >= range_min)
);

ALTER TABLE product_options ENABLE ROW LEVEL SECURITY;

-- 5.2: Politicas de seguridad

-- Table: product_categories
---------------------------------------------------------------------
--              | ALL | SELECT | INSERT | UPDATE | DELETE |
-- admin_global |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- store_admin  |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- public       |  X  |    ✓*   |    X   |    X   |    X   |
-- * Se permite el acceso público solo si la store tiene su subscripción activa.
-- store_admin  se refiere al registro de su propia comercio.
---------------------------------------------------------------------

CREATE POLICY admin_products_categories_access ON products_categories
FOR ALL
USING (
  public.is_store_admin(products_categories.store_id)
  OR public.is_global_admin()
);

CREATE POLICY public_products_categories_access ON products_categories
FOR SELECT
USING (
  public.is_store_subscription_active(products_categories.store_id)
);


-- Table: products
---------------------------------------------------------------------
--              | ALL | SELECT | INSERT | UPDATE | DELETE |
-- admin_global |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- store_admin  |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- public       |  X  |    ✓*   |    X   |    X   |    X   |
-- * Se permite el acceso público solo si la store tiene su subscripción activa.
-- store_admin  se refiere al registro de su propia comercio.
---------------------------------------------------------------------

CREATE POLICY admin_products_access ON products
FOR ALL
USING (
  public.is_store_admin(products.store_id)
  OR public.is_global_admin()
);

CREATE POLICY public_products_access ON products
FOR SELECT
USING (
  public.is_store_subscription_active(products.store_id)
);


-- Table: product_configurations
---------------------------------------------------------------------
--              | ALL | SELECT | INSERT | UPDATE | DELETE |
-- admin_global |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- store_admin  |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- public       |  X  |    ✓*   |    X   |    X   |    X   |
-- * Se permite el acceso público solo si la store tiene su subscripción activa.
-- store_admin  se refiere al registro de su propia comercio.
---------------------------------------------------------------------

CREATE POLICY admin_products_configurations_access ON product_configurations
FOR ALL
USING (
  public.is_store_admin(product_configurations.store_id)
  OR public.is_global_admin()
);

CREATE POLICY public_products_configurations_access ON product_configurations
FOR SELECT
USING (
  public.is_store_subscription_active(product_configurations.store_id)
);

-- Table: product_options
---------------------------------------------------------------------
--              | ALL | SELECT | INSERT | UPDATE | DELETE |
-- admin_global |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- store_admin  |  ✓  |    ✓   |    ✓   |    ✓   |    ✓   |
-- public       |  X  |    ✓*   |    X   |    X   |    X   |
-- * Se permite el acceso público solo si la store tiene su subscripción activa.
-- store_admin  se refiere al registro de su propia comercio.
---------------------------------------------------------------------

CREATE POLICY admin_products_options_access ON product_options
FOR ALL
USING (
  public.is_store_admin(product_options.store_id)
  OR public.is_global_admin()
);

CREATE POLICY public_products_options_access ON product_options
FOR SELECT
USING (
  public.is_store_subscription_active(product_options.store_id)
);


-- 5.3: Funciones auxiliares

-- Funciones de posicionamiento de categorías

-- Función: products_categories_move_up
-- Recibe el ID de la categoría y la mueve intercambiándola con la categoría inmediatamente superior.
-- Retorna TRUE si se realizó el cambio; de lo contrario FALSE.
CREATE OR REPLACE FUNCTION products_categories_move_up(
    p_category_id uuid
) RETURNS boolean AS $$
DECLARE
    v_store uuid;
    v_position int;
    v_prev_id uuid;
    v_prev_position int;
BEGIN
    -- Obtener el store y posición actual
    SELECT store_id, position INTO v_store, v_position
      FROM products_categories
     WHERE id = p_category_id;
    IF v_store IS NULL THEN
         RAISE EXCEPTION 'La categoría no existe';
    END IF;
    
    -- Buscar la categoría inmediatamente superior en el mismo store
    SELECT id, position INTO v_prev_id, v_prev_position
      FROM products_categories
     WHERE store_id = v_store AND position < v_position
     ORDER BY position DESC
     LIMIT 1;
     
    IF v_prev_id IS NULL THEN
        RETURN false;  -- Ya se encuentra en la primera posición
    END IF;
    
    -- Intercambiar posiciones
    UPDATE products_categories
       SET position = v_prev_position, updated_at = now()
     WHERE id = p_category_id;
     
    UPDATE products_categories
       SET position = v_position, updated_at = now()
     WHERE id = v_prev_id;
     
    RETURN true;
EXCEPTION
    WHEN OTHERS THEN
         RETURN false;
END;
$$ LANGUAGE plpgsql;


-- Función: products_categories_move_down
-- Recibe el ID de la categoría y la mueve intercambiándola con la categoría inmediatamente inferior.
-- Retorna TRUE si se realizó el cambio; de lo contrario FALSE.
CREATE OR REPLACE FUNCTION products_categories_move_down(
    p_category_id uuid
) RETURNS boolean AS $$
DECLARE
    v_store uuid;
    v_position int;
    v_next_id uuid;
    v_next_position int;
BEGIN
    -- Obtener el store y posición actual
    SELECT store_id, position INTO v_store, v_position
      FROM products_categories
     WHERE id = p_category_id;
    IF v_store IS NULL THEN
         RAISE EXCEPTION 'La categoría no existe';
    END IF;
    
    -- Buscar la categoría inmediatamente inferior en el mismo store
    SELECT id, position INTO v_next_id, v_next_position
      FROM products_categories
     WHERE store_id = v_store AND position > v_position
     ORDER BY position ASC
     LIMIT 1;
     
    IF v_next_id IS NULL THEN
        RETURN false;  -- Ya se encuentra en la última posición
    END IF;
    
    -- Intercambiar posiciones
    UPDATE products_categories
       SET position = v_next_position, updated_at = now()
     WHERE id = p_category_id;
     
    UPDATE products_categories
       SET position = v_position, updated_at = now()
     WHERE id = v_next_id;
     
    RETURN true;
EXCEPTION
    WHEN OTHERS THEN
         RETURN false;
END;
$$ LANGUAGE plpgsql;


-- Función: products_categories_last
-- Recibe el ID del store y retorna el número máximo de posición en ese store.
CREATE OR REPLACE FUNCTION products_categories_last(
    p_store_id uuid
) RETURNS integer AS $$
DECLARE
    v_last int;
BEGIN
    SELECT COALESCE(MAX(position), 0) INTO v_last
      FROM products_categories
     WHERE store_id = p_store_id;
    RETURN v_last;
EXCEPTION
    WHEN OTHERS THEN
         RETURN 0;
END;
$$ LANGUAGE plpgsql;

-- Función: products_last
-- Recibe el ID de la categoría y retorna el número máximo de posición en esa categoría.
CREATE OR REPLACE FUNCTION products_last(
    p_category_id uuid
) RETURNS integer AS $$
DECLARE
    v_last int;
BEGIN
    SELECT COALESCE(MAX(position), 0)
      INTO v_last
      FROM products
     WHERE category_id = p_category_id;
    RETURN v_last;
EXCEPTION
    WHEN OTHERS THEN
         RETURN 0;
END;
$$ LANGUAGE plpgsql;



-- FUNCIONES DE POSICIONAMIENTO DE PRODUCTOS

-- Función: products_move_up
-- Recibe el ID del producto y la mueve intercambiándolo con el producto inmediatamente superior dentro de la misma categoría y tienda.
CREATE OR REPLACE FUNCTION products_move_up(
    p_product_id uuid
) RETURNS boolean AS $$
DECLARE
    v_store uuid;
    v_category uuid;
    v_position int;
    v_prev_id uuid;
    v_prev_position int;
BEGIN
    -- Obtener store, category y posición del producto actual.
    SELECT store_id, category_id, position
      INTO v_store, v_category, v_position
      FROM products
     WHERE id = p_product_id;
    
    IF v_store IS NULL THEN
         RAISE EXCEPTION 'El producto no existe';
    END IF;
    
    -- Buscar el producto inmediatamente superior dentro de la misma categoría y tienda.
    SELECT id, position
      INTO v_prev_id, v_prev_position
      FROM products
     WHERE store_id = v_store
       AND category_id = v_category
       AND position < v_position
     ORDER BY position DESC
     LIMIT 1;
     
    IF v_prev_id IS NULL THEN
        RETURN false;  -- El producto ya se encuentra en la posición más alta.
    END IF;
    
    -- Intercambiar posiciones.
    UPDATE products
       SET position = v_prev_position, updated_at = now()
     WHERE id = p_product_id;
     
    UPDATE products
       SET position = v_position, updated_at = now()
     WHERE id = v_prev_id;
     
    RETURN true;
EXCEPTION
    WHEN OTHERS THEN
         RETURN false;
END;
$$ LANGUAGE plpgsql;


-- Función: products_move_down
-- Recibe el ID del producto y la mueve intercambiándolo con el producto inmediatamente inferior dentro de la misma categoría y tienda.
CREATE OR REPLACE FUNCTION products_move_down(
    p_product_id uuid
) RETURNS boolean AS $$
DECLARE
    v_store uuid;
    v_category uuid;
    v_position int;
    v_next_id uuid;
    v_next_position int;
BEGIN
    -- Obtener store, category y posición del producto actual.
    SELECT store_id, category_id, position
      INTO v_store, v_category, v_position
      FROM products
     WHERE id = p_product_id;
    
    IF v_store IS NULL THEN
         RAISE EXCEPTION 'El producto no existe';
    END IF;
    
    -- Buscar el producto inmediatamente inferior dentro de la misma categoría y tienda.
    SELECT id, position
      INTO v_next_id, v_next_position
      FROM products
     WHERE store_id = v_store
       AND category_id = v_category
       AND position > v_position
     ORDER BY position ASC
     LIMIT 1;
     
    IF v_next_id IS NULL THEN
        RETURN false;  -- El producto ya se encuentra en la posición más baja.
    END IF;
    
    -- Intercambiar posiciones.
    UPDATE products
       SET position = v_next_position, updated_at = now()
     WHERE id = p_product_id;
     
    UPDATE products
       SET position = v_position, updated_at = now()
     WHERE id = v_next_id;
     
    RETURN true;
EXCEPTION
    WHEN OTHERS THEN
         RETURN false;
END;
$$ LANGUAGE plpgsql;


-- Función auxiliar para obtener el precio del producto en función de la fecha actual y la oferta definida.
-- Si la fecha actual está dentro del rango de oferta, retorna el precio de oferta.
-- Si no, retorna el precio regular.
CREATE OR REPLACE FUNCTION product_price(p_product products)
RETURNS numeric
LANGUAGE plpgsql
AS $$
DECLARE
    store_tz text;
    current_date_store date;
BEGIN
    -- Obtiene el timezone de la tienda asociada al producto
    SELECT s.timezone
      INTO store_tz
      FROM stores s
     WHERE s.id = p_product.store_id;
    
    -- Convierte la fecha y hora actual al timezone de la tienda y obtiene la parte de la fecha
    current_date_store := (now() AT TIME ZONE store_tz)::date;
    
    -- Si el producto tiene precio de oferta y las fechas de vigencia definidas,
    -- y la fecha actual está en el rango de vigencia, retorna el precio de oferta.
    IF p_product.sale_price IS NOT NULL 
       AND p_product.sale_start IS NOT NULL 
       AND p_product.sale_end IS NOT NULL 
       AND current_date_store BETWEEN p_product.sale_start AND p_product.sale_end THEN
        RETURN p_product.sale_price;
    ELSE
        RETURN p_product.regular_price;
    END IF;
END;
$$;

-- Función auxiliar para verificar si un producto está disponible para el usuario
CREATE OR REPLACE FUNCTION product_available(p_product products)
RETURNS boolean
AS $$
DECLARE
    store_tz text;
    current_day int;
BEGIN
    -- Obtiene el timezone de la tienda asociada al producto
    SELECT s.timezone
      INTO store_tz
      FROM stores s
     WHERE s.id = p_product.store_id;
    
    -- Convertir la fecha/hora actual a la zona horaria del comercio y extraer el día ISO (1 = lunes, 7 = domingo)
    current_day := EXTRACT(ISODOW FROM (current_timestamp AT TIME ZONE store_tz))::int;
    
    -- Retornar true si el día actual se encuentra en la lista de días disponibles del producto
    RETURN current_day = ANY (p_product.days);
END;
$$ LANGUAGE plpgsql;



---------------------------------------------------------------------
-- 6: EXPLORAR PRODUCTOS
---------------------------------------------------------------------

-- Idices para optimizar consultas
CREATE INDEX idx_stores_country_code ON stores (country_code);
CREATE INDEX idx_stores_geom ON stores USING GIST (geom);
CREATE INDEX idx_stores_created_at ON stores (created_at);
CREATE INDEX idx_stores_geopoint ON stores USING GIST (((ST_SetSRID(ST_MakePoint(lng, lat),4326))::geography));

CREATE INDEX idx_products_active ON products (active);
CREATE INDEX idx_products_store_id ON products (store_id);
CREATE INDEX idx_products_tags ON products USING GIN (tags);
CREATE INDEX idx_products_created_at ON products (created_at);

-- 6.1. Funcion auxiliar para obtener la información de un producto segun la informacion de busqueda del usuario
CREATE OR REPLACE FUNCTION public.product_explore(
    country_code text,                          -- Código de país (ej. "MX", "US")    REQUERIDO
    user_lat numeric,                           -- Latitud geográfica del usuario     REQUERIDO
    user_lng numeric,                           -- Longitud geográfica del usuario    REQUERIDO
    max_distance numeric,                       -- Máximo distancia en metros         REQUERIDO (máximo 10 km)
    page int,                                   -- Página de la consulta              REQUERIDO
    random_seed text,                           -- Para generar un seed aleatorio para ordenar los productos  REQUERIDO   

    search_text text DEFAULT NULL,              -- Texto para buscar en los campos (products.name, products.description, products.tags, store.name)
    filter_tags text[] DEFAULT NULL,            -- Filtrar productos por tags (al menos uno debe estar presente en products.tags)
    price_min numeric DEFAULT NULL,             -- Filtro: product_price >= price_min
    price_max numeric DEFAULT NULL,             -- Filtro: product_price <= price_max

    page_size int DEFAULT 10,                   -- Tamaño de la página                OPCIONAL
    sort_product_price boolean DEFAULT false,   -- Ordenar por precio calculado (product_price) si es true 
    sort_created boolean DEFAULT false,         -- Ordenar por fecha de creación (products.created_at) si es true
    ascending boolean DEFAULT false,            -- Si sort_product_price o sort_created, se ordena ascendente si true

    filter_delivery boolean DEFAULT false,      -- Filtrar por delivery: el usuario debe estar dentro del área de delivery
    filter_pickup boolean DEFAULT false,        -- Solo se muestran tiendas con pickup activo
    filter_offers boolean DEFAULT false,        -- Filtrar productos en oferta (cuando product_price <> products.regular_price)
    filter_free_shipping boolean DEFAULT false  -- Filtrar tiendas con delivery activo y sin costo de delivery
)
RETURNS TABLE(
   product_id uuid,
   product_name text,
   product_description text,
   product_image_url text,
   product_regular_price numeric,
   product_sale_price numeric,
   product_sale_start date,
   product_sale_end date,
   product_currency text,
   product_tags text[],
   product_days int[],
   store_id uuid,
   store_name text,
   store_logo_url text,
   store_lat numeric,
   store_lng numeric,
   store_pickup boolean,
   store_delivery boolean,
   store_delivery_price numeric,
   store_is_open boolean,
   product_available boolean,
   product_price numeric,           -- Precio calculado por la función product_price
   distance double precision,       -- Distancia en metros a la tienda
   delivery_area boolean            -- TRUE si la posición del usuario está dentro del área de delivery de la tienda
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_max_distance numeric;
  offset_value int;
  order_clause text;
  sql_query text;
BEGIN
  ----------------------------------------------------------------------------
  -- Validación de parámetros requeridos
  ----------------------------------------------------------------------------
  IF country_code IS NULL OR TRIM(country_code) = '' THEN
    RAISE EXCEPTION 'El parámetro country_code es requerido';
  END IF;

  IF user_lat IS NULL THEN
    RAISE EXCEPTION 'El parámetro user_lat es requerido';
  END IF;
    
  IF user_lng IS NULL THEN
    RAISE EXCEPTION 'El parámetro user_lng es requerido';
  END IF;
    
  IF max_distance IS NULL THEN
    RAISE EXCEPTION 'El parámetro max_distance es requerido';
  END IF;
    
  IF page IS NULL OR page < 1 THEN
    RAISE EXCEPTION 'El parámetro page es requerido y debe ser mayor o igual a 1';
  END IF;

  IF random_seed IS NULL OR TRIM(random_seed) = '' THEN
    RAISE EXCEPTION 'El parámetro random_seed es requerido';
  END IF;

  ----------------------------------------------------------------------------
  -- Asegurar que max_distance no exceda 10 km (10,000 metros)
  ----------------------------------------------------------------------------
  v_max_distance := LEAST(max_distance, 10000);

  ----------------------------------------------------------------------------
  -- Calcular offset de paginación
  ----------------------------------------------------------------------------
  offset_value := (page - 1) * page_size;

  ----------------------------------------------------------------------------
  -- Construcción de la cláusula ORDER BY según los parámetros
  ----------------------------------------------------------------------------
  order_clause := 'ORDER BY store_is_open DESC, product_available DESC';

  IF sort_product_price AND sort_created THEN
      order_clause := order_clause || format(', product_price %s, created_at %s',
                            CASE WHEN ascending THEN 'ASC' ELSE 'DESC' END,
                            CASE WHEN ascending THEN 'ASC' ELSE 'DESC' END);
  ELSIF sort_product_price THEN
      order_clause := order_clause || format(', product_price %s',
                            CASE WHEN ascending THEN 'ASC' ELSE 'DESC' END);
  ELSIF sort_created THEN
      order_clause := order_clause || format(', created_at %s',
                            CASE WHEN ascending THEN 'ASC' ELSE 'DESC' END);
  END IF;

  -- Se aplica el random seed siempre, para garantizar variabilidad
  order_clause := order_clause || ', md5(''' || random_seed || ''' || st.id) ASC';

  ----------------------------------------------------------------------------
  -- Construcción de la consulta dinámica utilizando WITH para filtrar tiendas y productos
  ----------------------------------------------------------------------------
  sql_query := $sql$
  WITH 
    -- CTE para calcular el punto del usuario (tipo geography)
    user_point AS (
      SELECT ST_SetSRID(ST_MakePoint($1, $2),4326)::geography AS pt
    ),
    filtered_stores AS (
      SELECT 
        st.*,
        ST_Distance(up.pt, ST_SetSRID(ST_MakePoint(st.lng, st.lat),4326)::geography) AS distance,
        (st.delivery AND ST_Within(up.pt::geometry,st.geom)) AS delivery_area,
        public.store_is_open(st) AS store_is_open
      FROM stores st, user_point up
      WHERE st.country_code = $3
        AND st.lat IS NOT NULL AND st.lng IS NOT NULL
        AND ST_DWithin(ST_SetSRID(ST_MakePoint(st.lng, st.lat),4326)::geography, up.pt, $4)
        /* Filtros de servicios en tienda */
        %s
    ),
    filtered_products AS (
      SELECT 
        p.*,
        public.product_price(p) AS product_price,
        public.product_available(p) AS product_available
      FROM products p
      WHERE p.active = true
        %s
    )
  SELECT 
    p.id                      AS product_id,
    p.name                    AS product_name,
    p.description             AS product_description,
    p.image_url               AS product_image_url,
    p.regular_price           AS product_regular_price,
    p.sale_price              AS product_sale_price,
    p.sale_start              AS product_sale_start,
    p.sale_end                AS product_sale_end,
    p.currency                AS product_currency,
    p.tags                    AS product_tags,
    p.days                    AS product_days,
    st.id                     AS store_id,
    st.name                   AS store_name,
    st.logo_url               AS store_logo_url,
    st.lat                    AS store_lat,
    st.lng                    AS store_lng,
    st.pickup                 AS store_pickup,
    st.delivery               AS store_delivery,
    st.delivery_price         AS store_delivery_price,
    st.store_is_open,
    p.product_available,
    p.product_price,
    st.distance,
    st.delivery_area
  FROM filtered_stores st
  JOIN filtered_products p ON p.store_id = st.id
  WHERE
    ($5 IS NULL OR (
        p.name        ILIKE '%%' || $5 || '%%' OR 
        p.description ILIKE '%%' || $5 || '%%' OR 
        array_to_string(p.tags, ' ') ILIKE '%%' || $5 || '%%' OR 
        st.name       ILIKE '%%' || $5 || '%%'
    ))
    %s
    %s
  LIMIT $6 OFFSET $7
  $sql$;

  ----------------------------------------------------------------------------
  -- Inserción dinámica de filtros para las tiendas y productos
  ----------------------------------------------------------------------------
  sql_query := format(sql_query,
      /* Filtros en filtered_stores */
      (CASE 
          WHEN filter_pickup THEN ' AND st.pickup = true ' ELSE '' END) ||
      (CASE 
          WHEN filter_free_shipping THEN ' AND st.delivery = true AND st.delivery_price = 0 ' ELSE '' END) ||
      (CASE 
          WHEN filter_delivery THEN ' AND ST_Within((SELECT pt::geometry FROM user_point), st.geom) ' ELSE '' END),
      /* Filtros en filtered_products */
      (CASE 
          WHEN filter_tags IS NOT NULL THEN ' AND (p.tags && ' || quote_literal(filter_tags::text) || ') ' ELSE '' END) ||
      (CASE 
          WHEN filter_offers THEN ' AND public.product_price(p) <> p.regular_price ' ELSE '' END) ||
      (CASE 
          WHEN price_min IS NOT NULL THEN ' AND public.product_price(p) >= ' || price_min || ' ' ELSE '' END) ||
      (CASE 
          WHEN price_max IS NOT NULL THEN ' AND public.product_price(p) <= ' || price_max || ' ' ELSE '' END),
      /* Filtros adicionales en la cláusula WHERE final (vacío) */
      '',
      order_clause
  );

  ----------------------------------------------------------------------------
  -- Ejecución de la consulta dinámica
  ----------------------------------------------------------------------------
  RETURN QUERY EXECUTE sql_query
       USING user_lng,       -- $1: user_lng para la creación del punto
             user_lat,       -- $2: user_lat
             country_code,   -- $3: country_code
             v_max_distance, -- $4: max_distance ajustado (máximo 10km)
             search_text,    -- $5: search_text
             page_size,      -- $6: LIMIT
             offset_value;   -- $7: OFFSET

END;
$$;


CREATE OR REPLACE FUNCTION public.product_tags_explore(
  p_country_code   text,
  p_user_lat       numeric,
  p_user_lng       numeric,
  p_max_distance   numeric,
  p_tags_limit     int DEFAULT 10
)
RETURNS TABLE(tag text, count int)
LANGUAGE plpgsql
AS $$
DECLARE
  v_max_distance numeric;
BEGIN
  -- Validaciones…
  v_max_distance := LEAST(p_max_distance, 10000);

  RETURN QUERY
    WITH 
      user_point AS (
        SELECT ST_SetSRID(ST_MakePoint(p_user_lng, p_user_lat),4326)::geography AS pt
      ),
      filtered_stores AS (
        SELECT st.id
        FROM stores st
        JOIN user_point up ON TRUE
        WHERE st.country_code = p_country_code
          AND st.lat IS NOT NULL
          AND st.lng IS NOT NULL
          AND ST_DWithin(
                ST_SetSRID(ST_MakePoint(st.lng, st.lat),4326)::geography,
                up.pt,
                v_max_distance
              )
      ),
      filtered_products AS (
        SELECT p.*
        FROM products p
        WHERE p.active
          AND public.product_available(p)
          AND p.store_id IN (SELECT id FROM filtered_stores)
      ),
      product_tags AS (
        SELECT unnest(p.tags) AS tag
        FROM filtered_products p
        WHERE p.tags IS NOT NULL
      )
    SELECT
      pt.tag               AS tag,
      COUNT(*)::int        AS count   -- <- cast a integer
    FROM product_tags pt
    GROUP BY pt.tag
    ORDER BY COUNT(*) DESC
    LIMIT p_tags_limit;
END;
$$;



-- 6.3. Funcion auxiliar para obtener la información de un store segun la informacion de busqueda del usuario
-- 6.3. Función auxiliar para explorar tiendas con JSON de productos
CREATE OR REPLACE FUNCTION public.store_explore(
    country_code         text,    -- Código de país ("MX", "US")
    user_lat             numeric, -- Latitud del usuario
    user_lng             numeric, -- Longitud del usuario
    max_distance         numeric, -- Máxima distancia (máx. 10 km)
    page                 int,     -- Página (>=1)
    random_seed          text,    -- Semilla aleatoria para ordenar
    page_size            int      DEFAULT 10,
    sort_created         boolean  DEFAULT false,
    sort_distance        boolean  DEFAULT false,
    ascending            boolean  DEFAULT false,
    search_text          text     DEFAULT NULL,
    filter_delivery      boolean  DEFAULT false,
    filter_pickup        boolean  DEFAULT false,
    filter_free_shipping boolean  DEFAULT false,
    products_limit       int      DEFAULT 5
)
RETURNS TABLE(
   store_id           uuid,
   store_name         text,
   store_logo_url     text,
   store_lat          numeric,
   store_lng          numeric,
   store_pickup       boolean,
   store_delivery     boolean,
   store_delivery_price numeric,
   store_is_open      boolean,
   products_available numeric,
   distance           numeric,
   delivery_area      boolean,
   products_list      jsonb  -- Lista de productos
)
LANGUAGE plpgsql AS $$
DECLARE
  v_max_distance  numeric := LEAST(max_distance, 10000);
  v_offset        int     := (page - 1) * page_size;
  v_order         text    := 'ORDER BY store_is_open DESC';
  v_store_filters text    := '';
  v_sql           text;
BEGIN
  -- Validaciones
  IF country_code IS NULL OR trim(country_code) = '' THEN
    RAISE EXCEPTION 'country_code es requerido';
  ELSIF user_lat IS NULL OR user_lng IS NULL THEN
    RAISE EXCEPTION 'user_lat y user_lng son requeridos';
  ELSIF page < 1 THEN
    RAISE EXCEPTION 'page debe ser >= 1';
  ELSIF random_seed IS NULL OR trim(random_seed) = '' THEN
    RAISE EXCEPTION 'random_seed es requerido';
  END IF;

  -- Filtros de tienda
  IF filter_delivery THEN
    v_store_filters := v_store_filters || ' AND ST_Within(up.pt::geometry, st.geom)';
  END IF;
  IF filter_pickup THEN
    v_store_filters := v_store_filters || ' AND st.pickup = true';
  END IF;
  IF filter_free_shipping THEN
    v_store_filters := v_store_filters || ' AND st.delivery = true AND st.delivery_price = 0';
  END IF;

  -- ORDER dinámico
  IF sort_distance THEN
    v_order := v_order || format(', distance %s', CASE WHEN ascending THEN 'ASC' ELSE 'DESC' END);
  END IF;
  IF sort_created THEN
    v_order := v_order || format(', st.created_at %s', CASE WHEN ascending THEN 'ASC' ELSE 'DESC' END);
  END IF;
  v_order := v_order || format(', md5(%L || st.id) ASC', random_seed);

  -- Construir SQL
  v_sql := format($SQL$
    WITH user_point AS (
      SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography AS pt
    ),
    filtered_stores AS (
      SELECT
        st.*, 
        ST_Distance(
          up.pt,
          ST_SetSRID(ST_MakePoint(st.lng, st.lat), 4326)::geography
        )::numeric             AS distance,
        (st.delivery
         AND ST_Within(up.pt::geometry, st.geom)
        )                       AS delivery_area,
        public.store_is_open(st) AS store_is_open
      FROM stores st
      CROSS JOIN user_point up
      WHERE st.country_code = $3
        AND st.lat IS NOT NULL
        AND st.lng IS NOT NULL
        AND ST_DWithin(
              ST_SetSRID(ST_MakePoint(st.lng, st.lat), 4326)::geography,
              up.pt,
              $4
            )
        %s
    )
    SELECT
      st.id                   AS store_id,
      st.name                 AS store_name,
      st.logo_url             AS store_logo_url,
      st.lat                  AS store_lat,
      st.lng                  AS store_lng,
      st.pickup               AS store_pickup,
      st.delivery             AS store_delivery,
      st.delivery_price       AS store_delivery_price,
      st.store_is_open        AS store_is_open,
      (
        SELECT COUNT(*)::numeric
        FROM products p
        WHERE p.store_id = st.id
          AND p.active
          AND public.product_available(p)
      )                       AS products_available,
      st.distance             AS distance,
      st.delivery_area        AS delivery_area,
      (
        SELECT jsonb_agg(row_to_json(prod))
        FROM (
          SELECT
            p.id                   AS product_id,
            p.name                 AS product_name,
            p.image_url            AS product_image,
            public.product_price(p) AS product_price,
            p.regular_price
          FROM products p
          WHERE p.store_id = st.id
            AND p.active
            AND public.product_available(p)
          ORDER BY md5($6 || p.id)
          LIMIT $9
        ) prod
      )                       AS products_list
    FROM filtered_stores st
    WHERE ($5 IS NULL OR st.name ILIKE '%%' || $5 || '%%')
    %s
    LIMIT $7 OFFSET $8
  $SQL$,
    v_store_filters,
    v_order
  );

  -- Ejecutar
  RETURN QUERY EXECUTE v_sql
    USING
      user_lng,        -- $1
      user_lat,        -- $2
      country_code,    -- $3
      v_max_distance,  -- $4
      search_text,     -- $5
      random_seed,     -- $6
      page_size,       -- $7
      v_offset,        -- $8
      products_limit;  -- $9
END;
$$;
