-- Auditoría completa


-- 1. Bitácora Central de Acciones

create table bitacora_acciones (
    id_bitacora int identity(1,1) primary key,
    fecha_hora datetime not null,
    -- Información del usuario y la sesión
    usuario_db nvarchar(100) not null,         -- Quién ejecutó la acción
    rol_activo nvarchar(100),                  -- Qué rol estaba usando
    terminal_cliente nvarchar(128),            -- Desde qué computadora (hostname)
    ip_cliente nvarchar(48),                   -- Desde qué dirección IP
    -- Información de la acción
    accion nvarchar(10) not null,              -- INSERT, UPDATE, o DELETE
    tabla_afectada nvarchar(128) not null,     -- Qué tabla se modificó
    id_afectado nvarchar(100),                 -- El ID del registro modificado
    -- Control de versiones y trazabilidad
    datos_antiguos nvarchar(max),              -- El registro completo antes del cambio (en formato JSON)
    datos_nuevos nvarchar(max)                 -- El registro completo después del cambio (en formato JSON)
);
go

-- 2. Triggers de auditoria para todas las tablas


-- Tabla socios
create trigger trg_auditoria_socios
on socios
after insert, update, delete
as
begin
    set nocount on;

    -- No hacer nada si no hay filas afectadas
    if not exists (select * from inserted) and not exists (select * from deleted)
        return;

    declare @accion nvarchar(10);
    set @accion = case
        when exists (select * from inserted) and exists (select * from deleted) then 'UPDATE'
        when exists (select * from inserted) then 'INSERT'
        else 'DELETE'
    end;
    
    -- Insertar en la bitácora
    insert into bitacora_acciones (
        fecha_hora,
        usuario_db,
        rol_activo,
        terminal_cliente,
        ip_cliente,
        accion,
        tabla_afectada,
        id_afectado,
        datos_antiguos,
        datos_nuevos
    )
    select
        getdate(),
        suser_sname(),
        -- Verificamos a qué rol principal pertenece el usuario
        case 
            when is_member('rol_operador') = 1 then 'rol_operador'
            when is_member('rol_auditor') = 1 then 'rol_auditor'
            when is_member('db_owner') = 1 then 'db_owner'
            else 'desconocido'
        end,
        host_name(),
        (select client_net_address from sys.dm_exec_connections where session_id = @@spid),
        @accion,
        'socios',
        coalesce(i.id, d.id), -- Tomamos el ID del registro insertado o borrado
        -- Convertimos la fila antigua a JSON
        (select * from deleted where id = coalesce(i.id, d.id) for json path, without_array_wrapper),
        -- Convertimos la fila nueva a JSON
        (select * from inserted where id = coalesce(i.id, d.id) for json path, without_array_wrapper)
    from
        inserted as i
    full outer join
        deleted as d on i.id = d.id;
end;
go

-- Tabla autores

create trigger trg_auditoria_autores
on autores
after insert, update, delete
as
begin
    set nocount on;

    -- No hacer nada si no hay filas afectadas
    if not exists (select * from inserted) and not exists (select * from deleted)
        return;

    declare @accion nvarchar(10);
    set @accion = case
        when exists (select * from inserted) and exists (select * from deleted) then 'UPDATE'
        when exists (select * from inserted) then 'INSERT'
        else 'DELETE'
    end;
    
    -- Insertar en la bitácora
    insert into bitacora_acciones (
        fecha_hora,
        usuario_db,
        rol_activo,
        terminal_cliente,
        ip_cliente,
        accion,
        tabla_afectada,
        id_afectado,
        datos_antiguos,
        datos_nuevos
    )
    select
        getdate(),
        suser_sname(),
        -- Verificamos a qué rol principal pertenece el usuario
        case 
            when is_member('rol_operador') = 1 then 'rol_operador'
            when is_member('rol_auditor') = 1 then 'rol_auditor'
            when is_member('db_owner') = 1 then 'db_owner'
            else 'desconocido'
        end,
        host_name(),
        (select client_net_address from sys.dm_exec_connections where session_id = @@spid),
        @accion,
        'socios',
        coalesce(i.id, d.id), -- Tomamos el ID del registro insertado o borrado
        -- Convertimos la fila antigua a JSON
        (select * from deleted where id = coalesce(i.id, d.id) for json path, without_array_wrapper),
        -- Convertimos la fila nueva a JSON
        (select * from inserted where id = coalesce(i.id, d.id) for json path, without_array_wrapper)
    from
        inserted as i
    full outer join
        deleted as d on i.id = d.id;
end;
go

-- Tabla categorias

create trigger trg_auditoria_categorias
on categorias
after insert, update, delete
as
begin
    set nocount on;

    -- No hacer nada si no hay filas afectadas
    if not exists (select * from inserted) and not exists (select * from deleted)
        return;

    declare @accion nvarchar(10);
    set @accion = case
        when exists (select * from inserted) and exists (select * from deleted) then 'UPDATE'
        when exists (select * from inserted) then 'INSERT'
        else 'DELETE'
    end;
    
    -- Insertar en la bitácora
    insert into bitacora_acciones (
        fecha_hora,
        usuario_db,
        rol_activo,
        terminal_cliente,
        ip_cliente,
        accion,
        tabla_afectada,
        id_afectado,
        datos_antiguos,
        datos_nuevos
    )
    select
        getdate(),
        suser_sname(),
        -- Verificamos a qué rol principal pertenece el usuario
        case 
            when is_member('rol_operador') = 1 then 'rol_operador'
            when is_member('rol_auditor') = 1 then 'rol_auditor'
            when is_member('db_owner') = 1 then 'db_owner'
            else 'desconocido'
        end,
        host_name(),
        (select client_net_address from sys.dm_exec_connections where session_id = @@spid),
        @accion,
        'socios',
        coalesce(i.id, d.id), -- Tomamos el ID del registro insertado o borrado
        -- Convertimos la fila antigua a JSON
        (select * from deleted where id = coalesce(i.id, d.id) for json path, without_array_wrapper),
        -- Convertimos la fila nueva a JSON
        (select * from inserted where id = coalesce(i.id, d.id) for json path, without_array_wrapper)
    from
        inserted as i
    full outer join
        deleted as d on i.id = d.id;
end;
go

-- Tabla direcciones

create trigger trg_auditoria_direcciones
on direcciones
after insert, update, delete
as
begin
    set nocount on;

    -- No hacer nada si no hay filas afectadas
    if not exists (select * from inserted) and not exists (select * from deleted)
        return;

    declare @accion nvarchar(10);
    set @accion = case
        when exists (select * from inserted) and exists (select * from deleted) then 'UPDATE'
        when exists (select * from inserted) then 'INSERT'
        else 'DELETE'
    end;
    
    -- Insertar en la bitácora
    insert into bitacora_acciones (
        fecha_hora,
        usuario_db,
        rol_activo,
        terminal_cliente,
        ip_cliente,
        accion,
        tabla_afectada,
        id_afectado,
        datos_antiguos,
        datos_nuevos
    )
    select
        getdate(),
        suser_sname(),
        -- Verificamos a qué rol principal pertenece el usuario
        case 
            when is_member('rol_operador') = 1 then 'rol_operador'
            when is_member('rol_auditor') = 1 then 'rol_auditor'
            when is_member('db_owner') = 1 then 'db_owner'
            else 'desconocido'
        end,
        host_name(),
        (select client_net_address from sys.dm_exec_connections where session_id = @@spid),
        @accion,
        'socios',
        coalesce(i.id, d.id), -- Tomamos el ID del registro insertado o borrado
        -- Convertimos la fila antigua a JSON
        (select * from deleted where id = coalesce(i.id, d.id) for json path, without_array_wrapper),
        -- Convertimos la fila nueva a JSON
        (select * from inserted where id = coalesce(i.id, d.id) for json path, without_array_wrapper)
    from
        inserted as i
    full outer join
        deleted as d on i.id = d.id;
end;
go

-- Tabla editoriales

create trigger trg_auditoria_editoriales
on editoriales
after insert, update, delete
as
begin
    set nocount on;

    -- No hacer nada si no hay filas afectadas
    if not exists (select * from inserted) and not exists (select * from deleted)
        return;

    declare @accion nvarchar(10);
    set @accion = case
        when exists (select * from inserted) and exists (select * from deleted) then 'UPDATE'
        when exists (select * from inserted) then 'INSERT'
        else 'DELETE'
    end;
    
    -- Insertar en la bitácora
    insert into bitacora_acciones (
        fecha_hora,
        usuario_db,
        rol_activo,
        terminal_cliente,
        ip_cliente,
        accion,
        tabla_afectada,
        id_afectado,
        datos_antiguos,
        datos_nuevos
    )
    select
        getdate(),
        suser_sname(),
        -- Verificamos a qué rol principal pertenece el usuario
        case 
            when is_member('rol_operador') = 1 then 'rol_operador'
            when is_member('rol_auditor') = 1 then 'rol_auditor'
            when is_member('db_owner') = 1 then 'db_owner'
            else 'desconocido'
        end,
        host_name(),
        (select client_net_address from sys.dm_exec_connections where session_id = @@spid),
        @accion,
        'socios',
        coalesce(i.id, d.id), -- Tomamos el ID del registro insertado o borrado
        -- Convertimos la fila antigua a JSON
        (select * from deleted where id = coalesce(i.id, d.id) for json path, without_array_wrapper),
        -- Convertimos la fila nueva a JSON
        (select * from inserted where id = coalesce(i.id, d.id) for json path, without_array_wrapper)
    from
        inserted as i
    full outer join
        deleted as d on i.id = d.id;
end;
go

-- Tabla libros

create trigger trg_auditoria_libros
on socios
after insert, update, delete
as
begin
    set nocount on;

    -- No hacer nada si no hay filas afectadas
    if not exists (select * from inserted) and not exists (select * from deleted)
        return;

    declare @accion nvarchar(10);
    set @accion = case
        when exists (select * from inserted) and exists (select * from deleted) then 'UPDATE'
        when exists (select * from inserted) then 'INSERT'
        else 'DELETE'
    end;
    
    -- Insertar en la bitácora
    insert into bitacora_acciones (
        fecha_hora,
        usuario_db,
        rol_activo,
        terminal_cliente,
        ip_cliente,
        accion,
        tabla_afectada,
        id_afectado,
        datos_antiguos,
        datos_nuevos
    )
    select
        getdate(),
        suser_sname(),
        -- Verificamos a qué rol principal pertenece el usuario
        case 
            when is_member('rol_operador') = 1 then 'rol_operador'
            when is_member('rol_auditor') = 1 then 'rol_auditor'
            when is_member('db_owner') = 1 then 'db_owner'
            else 'desconocido'
        end,
        host_name(),
        (select client_net_address from sys.dm_exec_connections where session_id = @@spid),
        @accion,
        'socios',
        coalesce(i.id, d.id), -- Tomamos el ID del registro insertado o borrado
        -- Convertimos la fila antigua a JSON
        (select * from deleted where id = coalesce(i.id, d.id) for json path, without_array_wrapper),
        -- Convertimos la fila nueva a JSON
        (select * from inserted where id = coalesce(i.id, d.id) for json path, without_array_wrapper)
    from
        inserted as i
    full outer join
        deleted as d on i.id = d.id;
end;
go

-- Tabla libros_autores

create trigger trg_auditoria_libros_autores
on libros_autores
after insert, update, delete
as
begin
    set nocount on;

    -- No hacer nada si no hay filas afectadas
    if not exists (select * from inserted) and not exists (select * from deleted)
        return;

    declare @accion nvarchar(10);
    set @accion = case
        when exists (select * from inserted) and exists (select * from deleted) then 'UPDATE'
        when exists (select * from inserted) then 'INSERT'
        else 'DELETE'
    end;
    
    -- Insertar en la bitácora
    insert into bitacora_acciones (
        fecha_hora,
        usuario_db,
        rol_activo,
        terminal_cliente,
        ip_cliente,
        accion,
        tabla_afectada,
        id_afectado,
        datos_antiguos,
        datos_nuevos
    )
    select
        getdate(),
        suser_sname(),
        -- Verificamos a qué rol principal pertenece el usuario
        case 
            when is_member('rol_operador') = 1 then 'rol_operador'
            when is_member('rol_auditor') = 1 then 'rol_auditor'
            when is_member('db_owner') = 1 then 'db_owner'
            else 'desconocido'
        end,
        host_name(),
        (select client_net_address from sys.dm_exec_connections where session_id = @@spid),
        @accion,
        'socios',
        coalesce(i.id, d.id), -- Tomamos el ID del registro insertado o borrado
        -- Convertimos la fila antigua a JSON
        (select * from deleted where id = coalesce(i.id, d.id) for json path, without_array_wrapper),
        -- Convertimos la fila nueva a JSON
        (select * from inserted where id = coalesce(i.id, d.id) for json path, without_array_wrapper)
    from
        inserted as i
    full outer join
        deleted as d on i.id = d.id;
end;
go

-- Tabla penalizaciones

create trigger trg_auditoria_penalizaciones
on penalizaciones
after insert, update, delete
as
begin
    set nocount on;

    -- No hacer nada si no hay filas afectadas
    if not exists (select * from inserted) and not exists (select * from deleted)
        return;

    declare @accion nvarchar(10);
    set @accion = case
        when exists (select * from inserted) and exists (select * from deleted) then 'UPDATE'
        when exists (select * from inserted) then 'INSERT'
        else 'DELETE'
    end;
    
    -- Insertar en la bitácora
    insert into bitacora_acciones (
        fecha_hora,
        usuario_db,
        rol_activo,
        terminal_cliente,
        ip_cliente,
        accion,
        tabla_afectada,
        id_afectado,
        datos_antiguos,
        datos_nuevos
    )
    select
        getdate(),
        suser_sname(),
        -- Verificamos a qué rol principal pertenece el usuario
        case 
            when is_member('rol_operador') = 1 then 'rol_operador'
            when is_member('rol_auditor') = 1 then 'rol_auditor'
            when is_member('db_owner') = 1 then 'db_owner'
            else 'desconocido'
        end,
        host_name(),
        (select client_net_address from sys.dm_exec_connections where session_id = @@spid),
        @accion,
        'socios',
        coalesce(i.id, d.id), -- Tomamos el ID del registro insertado o borrado
        -- Convertimos la fila antigua a JSON
        (select * from deleted where id = coalesce(i.id, d.id) for json path, without_array_wrapper),
        -- Convertimos la fila nueva a JSON
        (select * from inserted where id = coalesce(i.id, d.id) for json path, without_array_wrapper)
    from
        inserted as i
    full outer join
        deleted as d on i.id = d.id;
end;
go

-- Tabla prestamos

create trigger trg_auditoria_prestamos
on prestamos
after insert, update, delete
as
begin
    set nocount on;

    -- No hacer nada si no hay filas afectadas
    if not exists (select * from inserted) and not exists (select * from deleted)
        return;

    declare @accion nvarchar(10);
    set @accion = case
        when exists (select * from inserted) and exists (select * from deleted) then 'UPDATE'
        when exists (select * from inserted) then 'INSERT'
        else 'DELETE'
    end;
    
    -- Insertar en la bitácora
    insert into bitacora_acciones (
        fecha_hora,
        usuario_db,
        rol_activo,
        terminal_cliente,
        ip_cliente,
        accion,
        tabla_afectada,
        id_afectado,
        datos_antiguos,
        datos_nuevos
    )
    select
        getdate(),
        suser_sname(),
        -- Verificamos a qué rol principal pertenece el usuario
        case 
            when is_member('rol_operador') = 1 then 'rol_operador'
            when is_member('rol_auditor') = 1 then 'rol_auditor'
            when is_member('db_owner') = 1 then 'db_owner'
            else 'desconocido'
        end,
        host_name(),
        (select client_net_address from sys.dm_exec_connections where session_id = @@spid),
        @accion,
        'socios',
        coalesce(i.id, d.id), -- Tomamos el ID del registro insertado o borrado
        -- Convertimos la fila antigua a JSON
        (select * from deleted where id = coalesce(i.id, d.id) for json path, without_array_wrapper),
        -- Convertimos la fila nueva a JSON
        (select * from inserted where id = coalesce(i.id, d.id) for json path, without_array_wrapper)
    from
        inserted as i
    full outer join
        deleted as d on i.id = d.id;
end;
go

-- Tabla reservas

create trigger trg_auditoria_reservas
on reservas
after insert, update, delete
as
begin
    set nocount on;

    -- No hacer nada si no hay filas afectadas
    if not exists (select * from inserted) and not exists (select * from deleted)
        return;

    declare @accion nvarchar(10);
    set @accion = case
        when exists (select * from inserted) and exists (select * from deleted) then 'UPDATE'
        when exists (select * from inserted) then 'INSERT'
        else 'DELETE'
    end;
    
    -- Insertar en la bitácora
    insert into bitacora_acciones (
        fecha_hora,
        usuario_db,
        rol_activo,
        terminal_cliente,
        ip_cliente,
        accion,
        tabla_afectada,
        id_afectado,
        datos_antiguos,
        datos_nuevos
    )
    select
        getdate(),
        suser_sname(),
        -- Verificamos a qué rol principal pertenece el usuario
        case 
            when is_member('rol_operador') = 1 then 'rol_operador'
            when is_member('rol_auditor') = 1 then 'rol_auditor'
            when is_member('db_owner') = 1 then 'db_owner'
            else 'desconocido'
        end,
        host_name(),
        (select client_net_address from sys.dm_exec_connections where session_id = @@spid),
        @accion,
        'socios',
        coalesce(i.id, d.id), -- Tomamos el ID del registro insertado o borrado
        -- Convertimos la fila antigua a JSON
        (select * from deleted where id = coalesce(i.id, d.id) for json path, without_array_wrapper),
        -- Convertimos la fila nueva a JSON
        (select * from inserted where id = coalesce(i.id, d.id) for json path, without_array_wrapper)
    from
        inserted as i
    full outer join
        deleted as d on i.id = d.id;
end;
go

-- Tabla usuarios_sistema

create trigger trg_auditoria_usuarios_sistema
on socios
after insert, update, delete
as
begin
    set nocount on;

    -- No hacer nada si no hay filas afectadas
    if not exists (select * from inserted) and not exists (select * from deleted)
        return;

    declare @accion nvarchar(10);
    set @accion = case
        when exists (select * from inserted) and exists (select * from deleted) then 'UPDATE'
        when exists (select * from inserted) then 'INSERT'
        else 'DELETE'
    end;
    
    -- Insertar en la bitácora
    insert into bitacora_acciones (
        fecha_hora,
        usuario_db,
        rol_activo,
        terminal_cliente,
        ip_cliente,
        accion,
        tabla_afectada,
        id_afectado,
        datos_antiguos,
        datos_nuevos
    )
    select
        getdate(),
        suser_sname(),
        -- Verificamos a qué rol principal pertenece el usuario
        case 
            when is_member('rol_operador') = 1 then 'rol_operador'
            when is_member('rol_auditor') = 1 then 'rol_auditor'
            when is_member('db_owner') = 1 then 'db_owner'
            else 'desconocido'
        end,
        host_name(),
        (select client_net_address from sys.dm_exec_connections where session_id = @@spid),
        @accion,
        'socios',
        coalesce(i.id, d.id), -- Tomamos el ID del registro insertado o borrado
        -- Convertimos la fila antigua a JSON
        (select * from deleted where id = coalesce(i.id, d.id) for json path, without_array_wrapper),
        -- Convertimos la fila nueva a JSON
        (select * from inserted where id = coalesce(i.id, d.id) for json path, without_array_wrapper)
    from
        inserted as i
    full outer join
        deleted as d on i.id = d.id;
end;
go

-- 3. Reportes de Auditoría

-- Por fecha

create procedure sp_reporte_auditoria_por_fecha
    @fecha_inicio datetime,
    @fecha_fin datetime
as
begin
    set nocount on;
    select * from bitacora_acciones
    where fecha_hora between @fecha_inicio and @fecha_fin
    order by fecha_hora desc;
end;
go

-- Por socios

create procedure sp_reporte_auditoria_por_tabla
    @nombre_tabla nvarchar(128)
as
begin
    set nocount on;
    select * from bitacora_acciones
    where tabla_afectada = @nombre_tabla
    order by fecha_hora desc;
end;
go

-- Ejemplo de uso
exec sp_reporte_auditoria_por_tabla 'socios';