-- Monitoreo y rendimiento

-- 1. Consulta de Tamaño y Uso de Disco

exec sp_spaceused 'dbo.libros';

-- Método Completo (para todas las tablas)

select 
    t.name as tabla,
    p.rows as numero_de_filas,
    cast(sum(a.total_pages) * 8.0 / 1024 as decimal(10, 2)) as tamaño_total_mb,
    cast(sum(a.used_pages) * 8.0 / 1024 as decimal(10, 2)) as tamaño_usado_mb,
    cast((sum(a.total_pages) - sum(a.used_pages)) * 8.0 / 1024 as decimal(10, 2)) as espacio_sin_usar_mb
from 
    sys.tables t
inner join 
    sys.indexes i on t.object_id = i.object_id
inner join 
    sys.partitions p on i.object_id = p.object_id and i.index_id = p.index_id
inner join 
    sys.allocation_units a on p.partition_id = a.container_id
where 
    t.is_ms_shipped = 0
group by 
    t.name, p.rows
order by 
    tamaño_total_mb desc;

-- 2. Control de Crecimiento de Registros

select
    datename(year, fecha_hora) as anio,
    datepart(week, fecha_hora) as semana_del_anio,
    tabla_afectada,
    count(*) as registros_nuevos_creados
from
    bitacora_acciones
where
    accion = 'INSERT'
group by
    datename(year, fecha_hora),
    datepart(week, fecha_hora),
    tabla_afectada
order by
    anio, semana_del_anio, tabla_afectada;

-- 3. Evaluación de Consultas Más Lentas

 select top 10
    (qs.total_worker_time / 1000) as cpu_total_ms,
    (qs.total_elapsed_time / 1000) as duracion_total_ms,
    qs.execution_count as ejecuciones,
    (qs.total_elapsed_time / qs.execution_count / 1000) as duracion_promedio_ms,
    st.text as consulta_sql
from 
    sys.dm_exec_query_stats as qs
cross apply 
    sys.dm_exec_sql_text(qs.sql_handle) as st
order by 
    qs.total_worker_time desc;

-- 4. Registro del Uso de Funciones y Procedimientos

select
    object_name(ps.object_id, ps.database_id) as procedimiento,
    ps.execution_count as numero_de_ejecuciones,
    (ps.total_worker_time / 1000) as cpu_total_ms,
    (ps.total_elapsed_time / 1000) as duracion_total_ms
from
    sys.dm_exec_procedure_stats as ps
where
    db_name(ps.database_id) = 'SiBibli' -- Filtra por tu base de datos
order by
    ps.execution_count desc; -- Ordenado por los más usados