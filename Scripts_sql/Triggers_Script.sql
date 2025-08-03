-- triggers

-- creación de las tablas de auditoría (2 tablas adicionales)

-- tabla: auditoría para la tabla de libros
create table auditoria_libros (
    id_auditoria int identity(1,1) primary key,
    operacion nvarchar(10) not null,
    usuario_modificador nvarchar(50) not null,
    fecha_modificacion datetime2 not null default getdate(),
    libro_id_afectado int,
    datos_antiguos nvarchar(max),
    datos_nuevos nvarchar(max),
    constraint ck_auditoria_libros_operacion check (operacion in ('INSERT', 'UPDATE', 'DELETE'))
);
go

-- tabla: auditoría para la tabla de préstamos
create table auditoria_prestamos (
    id_auditoria int identity(1,1) primary key,
    operacion nvarchar(10) not null,
    usuario_modificador nvarchar(50) not null,
    fecha_modificacion datetime2 not null default getdate(),
    prestamo_id_afectado int,
    datos_antiguos nvarchar(max),
    datos_nuevos nvarchar(max),
    constraint ck_auditoria_prestamos_operacion check (operacion in ('INSERT', 'UPDATE', 'DELETE'))
);
go




-- creación de los triggers de auditoría

-- 1. trigger para la tabla de libros
create trigger trigger_auditoria_libros
on libros
after insert, update, delete
as
begin
    set nocount on;

    declare @operacion nvarchar(10);
    set @operacion = case
        when exists (select * from inserted) and exists (select * from deleted) then 'UPDATE'
        when exists (select * from inserted) then 'INSERT'
        else 'DELETE'
    end;

    if @operacion = 'DELETE'
        insert into auditoria_libros (operacion, usuario_modificador, libro_id_afectado, datos_antiguos)
        select
            @operacion,
            system_user,
            d.id,
            (select * from deleted where id = d.id for json path, without_array_wrapper)
        from deleted d;
    else
        insert into auditoria_libros (operacion, usuario_modificador, libro_id_afectado, datos_antiguos, datos_nuevos)
        select
            @operacion,
            system_user,
            i.id,
            (select * from deleted where id = i.id for json path, without_array_wrapper),
            (select * from inserted where id = i.id for json path, without_array_wrapper)
        from inserted i;
end;
go

-- 2. trigger para la tabla de préstamos
create trigger trigger_auditoria_prestamos
on prestamos
after insert, update, delete
as
begin
    set nocount on;

    declare @operacion nvarchar(10);
    set @operacion = case
        when exists (select * from inserted) and exists (select * from deleted) then 'UPDATE'
        when exists (select * from inserted) then 'INSERT'
        else 'DELETE'
    end;

    if @operacion = 'DELETE'
        insert into auditoria_prestamos (operacion, usuario_modificador, prestamo_id_afectado, datos_antiguos)
        select
            @operacion,
            system_user,
            d.id,
            (select * from deleted where id = d.id for json path, without_array_wrapper)
        from deleted d;
    else
        insert into auditoria_prestamos (operacion, usuario_modificador, prestamo_id_afectado, datos_antiguos, datos_nuevos)
        select
            @operacion,
            system_user,
            i.id,
            (select * from deleted where id = i.id for json path, without_array_wrapper),
            (select * from inserted where id = i.id for json path, without_array_wrapper)
        from inserted i;
end;
go

-- 3. trigger para actualizar el stock automáticamente

create trigger trg_actualizar_stock_prestamo
on prestamos
after insert, update
as
begin
    set nocount on;

    -- escenario 1: se inserta un nuevo préstamo (reduce stock)
    if exists (select * from inserted) and not exists (select * from deleted)
    begin
        update l
        set l.cantidad_disponible = l.cantidad_disponible - 1
        from libros as l
        join inserted as i on l.id = i.libro_id;
    end

    -- escenario 2: un préstamo se actualiza a 'devuelto' (aumenta stock)
    if exists (select * from inserted) and exists (select * from deleted)
    begin
        update l
        set l.cantidad_disponible = l.cantidad_disponible + 1
        from libros as l
        join inserted as i on l.id = i.libro_id
        join deleted as d on i.id = d.id
        -- solo aumenta si el estado nuevo es 'DEVUELTO' y el anterior no lo era.
        where i.estado_prestamo = 'DEVUELTO' and d.estado_prestamo <> 'DEVUELTO';
    end
end;
go