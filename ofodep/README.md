# 📄 README del Proyecto OFODEP

---

## 🚀 **Proyecto OFODEP (Open Food Delivery Platform)**

**Versión:** 0.1.0  
**Fecha de creación:** 2025-01-01  
**Autor:** Jordan Aran  

---

## 📌 **Tabla de Contenidos**

- [Objetivo del Proyecto](#objetivo-del-proyecto)
- [Alcance del Proyecto](#alcance-del-proyecto)
- [Enfoque Open Source](#enfoque-open-source)
- [Flujo de Negocio](#flujo-de-negocio)
- [Esquema y Funcionamiento de la Base de Datos](#esquema-y-funcionamiento-de-la-base-de-datos)
  - [Fases del Esquema](#fases-del-esquema)
  - [Funciones Específicas del Sistema](#funciones-específicas-del-sistema)
  - [Seguridad y Privacidad](#seguridad-y-privacidad)
  - [Row Level Security (RLS)](#row-level-security-rls)
- [Contacto del Autor](#contacto-del-autor)

---

## 🎯 **Objetivo del Proyecto**

**OFODEP (Open Food Delivery Platform)** es una plataforma web abierta diseñada para ayudar a comercios locales a gestionar de manera sencilla y efectiva sus ventas, pedidos, entregas y comunicación con clientes, promoviendo así la economía local mediante herramientas digitales accesibles para todos.

---

## 📌 **Alcance del Proyecto**

El sistema busca cubrir todas las necesidades digitales esenciales para cualquier comercio local, proporcionando herramientas claras para:

- Manejo eficiente de productos con personalizaciones.
- Control avanzado de horarios de apertura regulares y excepcionales.
- Gestión automatizada de pedidos con soporte para delivery y pickup.
- Comunicación efectiva con clientes mediante WhatsApp.
- Geolocalización y manejo areas de entrega por codigos postales.
- Valoraciones y reseñas públicas para generar confianza.
- Suscripciones flexibles para comercios según funcionalidades deseadas.

---

## 🌐 **Enfoque Open Source**

OFODEP es una iniciativa **Open Source**, diseñada específicamente para facilitar la implementación por parte de comercios, municipios o comunidades interesadas en desplegar rápidamente su propia plataforma local.  

- **Despliegue fácil:** Al utilizar Supabase, no requiere configuración de servidores propios, reduciendo costes y complejidad técnica.
- **Adaptabilidad:** El código abierto permite que cada implementación adapte la plataforma fácilmente según su contexto local.
- **Colaboración:** Fomenta la colaboración entre desarrolladores, comunidades y pequeños comercios.

---

## 🔄 **Flujo de Negocio**

El flujo básico del sistema comprende:

1. **Registro y Autenticación:**  
   Usuarios y administradores acceden con autenticación segura a través de Supabase Auth.

2. **Exploración de Comercios y Productos:**  
   Clientes visualizan comercios cercanos, productos disponibles y horarios actualizados.

3. **Pedidos Personalizados:**  
   Los clientes crean pedidos personalizando opciones según sus preferencias.

4. **Gestión y Seguimiento de Pedidos:**  
   Cada pedido tiene seguimiento claro desde la creación hasta la entrega.

5. **Comunicación directa (WhatsApp):**  
   Comercios tienen la opción de recibir y manejar pedidos directamente por WhatsApp, sin depender exclusivamente de la plataforma.

6. **Entregas Eficientes (Delivery/Pickup):**  
   Mediante enlaces únicos generados para repartidores, facilitando asignación rápida y seguimiento preciso.

7. **Retroalimentación y Mejoras:**  
   Comentarios y valoraciones de usuarios mejoran la reputación y visibilidad de los comercios.

---

## 📚 **Esquema y Funcionamiento de la Base de Datos**

### 📂 **Fases del Esquema**

| **Fase** | **Descripción**                                                  | **Tablas principales** |
|----------|------------------------------------------------------------------|------------------------|
| 1        | Usuarios y Autenticación                                         | usuarios               |
| 2        | Comercios y Gestión de Horarios                                  | comercios, comercio_horarios, comercio_horarios_excepciones, comercio_administradores, comercio_suscripciones |
| 3        | Productos y Configuraciones                                      | productos, producto_configuraciones, producto_opciones |
| 4        | Pedidos, Comentarios y Detalles                                  | pedidos, pedido_reviews, pedido_productos, pedido_configuraciones, pedido_opciones |
| 5        | Información del Delivery                                         | delivery_info          |

---

### ⚙️ **Funciones Específicas del Sistema**

#### 📌 **Uso de Tags y Categorías:**
- Facilita la búsqueda y filtrado de productos por parte del cliente final.

#### 📌 **Generación y Manejo de Links para Repartidores:**
- Permite asignar rápidamente pedidos mediante enlaces únicos enviados al repartidor por WhatsApp o SMS.
- Seguimiento en tiempo real del repartidor asignado por parte del cliente y del comercio.

#### 📌 **Manejo Alternativo de Pedidos por WhatsApp:**
- Comercios tienen la opción de recibir pedidos vía WhatsApp, permitiendo un flujo sencillo y accesible sin requerir uso permanente de la aplicación web.

#### 📌 **Gestión Avanzada y Detallada de Horarios:**
- Control minucioso de horarios regulares por días específicos y excepciones para días festivos, eventos especiales o situaciones particulares.

#### 📌 **Sistema Flexible de Suscripciones:**
- Los comercios acceden a funcionalidades diferenciadas según tipo de suscripción (general, especial, premium), permitiendo monetización del servicio según necesidades específicas.

#### 📌 **Comentarios y Valoraciones:**
- Transparencia total mediante la retroalimentación directa del cliente, impulsando calidad constante y generando confianza en la comunidad.

---

### 🔒 **Seguridad y Privacidad**

Implementa mecanismos de seguridad sólidos con Supabase y PostgreSQL:

- Uso extensivo de UUID.
- Row Level Security (RLS) para restringir operaciones según rol específico.
- Funciones especializadas para validar integridad de información en operaciones críticas (pedidos, usuarios, etc.).

---

### 🛡️ **Row Level Security (RLS)**

Políticas de seguridad definidas para cada rol de usuario dentro de la plataforma, asegurando privacidad y cumplimiento normativo. Los detalles completos están definidos dentro del archivo SQL proporcionado (`schema.sql`).

---

## 📝 **Licencia**

Este proyecto es Open Source bajo licencia MIT. Puedes usar, modificar y redistribuir el código libremente bajo sus condiciones.

---

## 📧 **Contacto del Autor**

- **Jordan Aran**  
  _Desarrollador principal del proyecto OFODEP._

---

✨ **¡Gracias por apoyar el comercio local y el software abierto! ¡Juntos construimos comunidad!** ✨