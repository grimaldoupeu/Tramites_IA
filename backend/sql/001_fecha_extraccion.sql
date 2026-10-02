-- Migración 001: agrega la fecha de extracción de cada documento.
--
-- Para una base que YA existe. Ejecutar una vez en Supabase > SQL Editor y
-- luego volver a ingestar (python -m ingest.ingestar) para llenar la columna.
-- Una instalación nueva no la necesita: esquema.sql ya incluye la columna.

-- 1. Nueva columna: día en que se copió el texto de la página oficial.
alter table fragmentos add column if not exists fecha_extraccion date;

-- 2. La función de búsqueda debe devolverla. Como cambia el tipo de retorno,
--    Postgres no permite "create or replace": hay que borrarla y crearla de nuevo.
drop function if exists buscar_fragmentos(vector, int);

create function buscar_fragmentos(
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
