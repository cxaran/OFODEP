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


-- 1.4 Politicas "users". 
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

---------------------------------------------------------------------
-- 2: TIENDAS (COMERCIOS) 
---------------------------------------------------------------------

-- 2.1. Tablas
-- stores
CREATE TABLE stores (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text NOT NULL CHECK (TRIM(name) <> ''),
    logo_url text,                                              -- URL o ruta del logo de la tienda
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
    delivery_minimum_order numeric, 
    pickup boolean DEFAULT false,
    delivery boolean DEFAULT false,
    delivery_price numeric,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

ALTER TABLE stores ENABLE ROW LEVEL SECURITY;

-- store_admins
CREATE TABLE store_admins (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id uuid REFERENCES stores(id) ON DELETE CASCADE,
    user_id uuid REFERENCES users(auth_id) ON DELETE CASCADE,

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

-- Funcion para generar una store, una suscripción y un admin global, recibe como parámetros el nombre de la tienda.
-- Se hace admin de la tienda al usuario autenticado.
-- 2.2. Función para registrar una tienda junto con su suscripción y admin
CREATE OR REPLACE FUNCTION public.create_store(
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
BEGIN
    -- Validaciones mínimas
    IF store_name IS NULL OR TRIM(store_name) = '' THEN
        RAISE EXCEPTION 'El nombre de la tienda no puede estar vacío.';
    ELSIF contact_name IS NULL OR TRIM(contact_name) = '' THEN
        RAISE EXCEPTION 'El nombre del contacto no puede estar vacío.';
    ELSIF contact_email IS NULL OR contact_email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'El correo electrónico del contacto no es válido.';
    ELSIF contact_phone IS NULL OR contact_phone !~ '^\+?[0-9]{7,15}$' THEN
        RAISE EXCEPTION 'El teléfono del contacto no es válido.';
    END IF;

    -- Verifica que el usuario no sea admin en otra tienda
    SELECT COUNT(*) INTO existing_store_count
    FROM store_admins
    WHERE user_id = auth.uid();

    IF existing_store_count > 0 THEN
        RAISE EXCEPTION 'El usuario ya es administrador de otra tienda.';
    END IF;

    -- Crear tienda
    INSERT INTO stores (
        name, country_code, timezone
    )
    VALUES (
        TRIM(store_name), country_code, timezone
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
        new_store_id, auth.uid(), contact_name, contact_email, contact_phone, true
    );

    RETURN new_store_id;
END;
$$;

-- Función auxiliar para verificar si un usuario es administrador de una tienda
CREATE OR REPLACE FUNCTION public.is_store_admin(target_store_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1 FROM store_admins
    WHERE store_id = target_store_id
      AND user_id = auth.uid()
  );
$$;

-- Función auxiliar para verificar una tienda tiene su subscripcion activa 
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
-- store_admin  se refiere al registro de su propia tienda.
---------------------------------------------------------------------
-- Permitir acceso completo a admin_global
-- Permitir acceso completo a store_admin de su propia tienda
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
-- store_admin  se refiere al registro de su propia tienda.
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
-- store_admin  se refiere al registro de su propia tienda.
---------------------------------------------------------------------

-- Permitir acceso completo a admin_global
CREATE POLICY admin_global_store_subscriptions_access ON store_subscriptions
FOR ALL
USING (
  public.is_global_admin()
);

-- Permitir lectura a store_admin de su tienda
CREATE POLICY store_admin_store_subscriptions_access ON store_subscriptions
FOR SELECT
USING (
  public.is_store_admin(store_subscriptions.store_id)
);

---------------------------------------------------------------------
-- 3: HORARIOS DE COMERCIOS
---------------------------------------------------------------------

-- 3.1: Tablas 
-- Registra los horarios regulares de apertura y cierre para cada tienda.
CREATE TABLE store_schedules (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id uuid REFERENCES stores(id) ON DELETE CASCADE,  
    days int[],                                             -- "dias"; 1 = lunes, ... , 7 = domingo
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
-- store_admin  se refiere al registro de su propia tienda.
---------------------------------------------------------------------

-- Permitir acceso completo a admin_global y store_admin de su propia tienda
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
-- store_admin  se refiere al registro de su propia tienda.
---------------------------------------------------------------------

-- Permitir acceso completo a admin_global y store_admin de su propia tienda
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
-- store_admin  se refiere al registro de su propia tienda.
---------------------------------------------------------------------

-- Permitir acceso completo a admin_global y store_admin de su propia tienda
CREATE POLICY admin_store_images_access ON store_images
FOR ALL
USING (
  public.is_store_admin(store_images.store_id)
  OR public.is_global_admin()
);