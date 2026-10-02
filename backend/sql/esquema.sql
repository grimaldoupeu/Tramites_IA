-- Esquema completo de la base de datos de TramitesIA (Supabase + pgvector).
--
-- Para una instalación NUEVA: ejecutar una vez en Supabase > SQL Editor.
-- Una base existente se actualiza con las migraciones numeradas (001_..., 002_...).

-- Habilitar pgvector
create extension if not exists vector;

-- Fragmentos de los documentos oficiales con su embedding
create table if not exists fragmentos (
    id               bigserial primary key,
    entidad          text not null,
    tramite          text not null,
    contenido        text not null,         -- empieza con "Trámite: ..." y "Sección: ..."
    url_fuente       text not null,
    fecha_extraccion date,                  -- día en que se copió el texto de la página oficial
    embedding        vector(384) not null   -- intfloat/multilingual-e5-small
);

-- La ingesta borra por url_fuente antes de insertar (para no duplicar)
create index if not exists fragmentos_url_fuente_idx on fragmentos (url_fuente);

-- Seguridad: solo el backend (clave service_role) accede a la tabla
alter table fragmentos enable row level security;

-- Búsqueda por similitud coseno (<=> es la distancia coseno de pgvector)
create or replace function buscar_fragmentos(
    query_embedding vector(384),
    cantidad int default 5
)
returns table (
    entidad          text,
    tramite          text,
    contenido        text,
    url_fuente       text,
    fecha_extraccion date,
    similitud        float
)
language sql stable
as $$
    select
        f.entidad,
        f.tramite,
        f.contenido,
        f.url_fuente,
        f.fecha_extraccion,
        1 - (f.embedding <=> query_embedding) as similitud
    from fragmentos f
    order by f.embedding <=> query_embedding
    limit cantidad;
$$;
