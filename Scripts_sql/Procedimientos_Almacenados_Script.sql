-- 5 Procedimientos almacenados

-- 1. Registrar un Préstamo (Inserción con Validación Cruzada)

create procedure sp_registrar_prestamo
    @id_libro int,
    @id_socio int,
    @id_usuario_sistema int
as
begin
    set nocount on; -- Evita que se devuelvan mensajes de "filas afectadas"

    declare @cantidad_disponible int;
    declare @estado_socio nvarchar(15);
    declare @mensaje_error nvarchar(255);

    -- Validación 1: Disponibilidad del libro
    select @cantidad_disponible = cantidad_disponible from libros where id = @id_libro;
    if @cantidad_disponible <= 0
    begin
        set @mensaje_error = 'Error: El libro no tiene copias disponibles para prestar.';
        throw 50001, @mensaje_error, 1;
        return;
    end

    -- Validación 2: Estado del socio
    select @estado_socio = estado_socio from socios where id = @id_socio;
    if @estado_socio <> 'ACTIVO'
    begin
        set @mensaje_error = 'Error: El socio no está activo. Estado actual: ' + @estado_socio;
        throw 50002, @mensaje_error, 1;
        return;
    end

    -- Inicia la transacción
    begin transaction;
    begin try
        -- Registrar el préstamo
        insert into prestamos (libro_id, socio_id, usuario_sistema_id, fecha_prestamo, fecha_devolucion_estimada, estado_prestamo)
        values (@id_libro, @id_socio, @id_usuario_sistema, getdate(), dateadd(day, 15, getdate()), 'EN_CURSO');

        -- Actualizar la cantidad de libros disponibles
        update libros
        set cantidad_disponible = cantidad_disponible - 1
        where id = @id_libro;

        commit transaction;
    end try
    begin catch
        rollback transaction;
        -- Relanza el error original para que la aplicación lo reciba
        throw;
    end catch
end;
go

-- 2. Vetar Socios por Exceso de Multas (Actualización Masiva)

create procedure sp_vetar_socios_por_multas
    @limite_multas int
as
begin
    set nocount on;

    update socios
    set estado_socio = 'VETADO'
    where id in (
        select socio_con_deuda.id
        from (
            select
                s.id
            from v_multas_pendientes as vmp
            join socios as s on vmp.cedula = s.cedula
            group by s.id
            having count(vmp.cedula) >= @limite_multas
        ) as socio_con_deuda
    );

    -- Devuelve el número de socios que fueron actualizados
    select @@rowcount as socios_vetados;
end;
go

-- 3. Eliminar una Editorial (Eliminación Segura)

create procedure sp_eliminar_editorial_seguro
    @id_editorial int
as
begin
    set nocount on;

    if exists (select 1 from libros where editorial_id = @id_editorial)
    begin
        -- Si existe al menos un libro, lanza un error personalizado.
        throw 50003, 'Error: No se puede eliminar la editorial porque tiene libros asociados.', 1;
    end
    else
    begin
        -- Si no hay libros, procede con la eliminación.
        delete from editoriales where id = @id_editorial;
        select 'Editorial eliminada correctamente.' as resultado;
    end
end;
go

-- 4. Reporte de Préstamos por Período

create procedure sp_reporte_prestamos_por_fecha
    @fecha_inicio date,
    @fecha_fin date
as
begin
    set nocount on;

    select
        p.id as id_prestamo,
        p.fecha_prestamo,
        l.titulo as libro,
        s.nombre + ' ' + s.apellido as socio,
        p.estado_prestamo
    from
        prestamos as p
    join
        libros as l on p.libro_id = l.id
    join
        socios as s on p.socio_id = s.id
    where
        p.fecha_prestamo between @fecha_inicio and @fecha_fin
    order by
        p.fecha_prestamo asc;
end;
go

-- 5. Generar Penalizaciones (Facturación Automática)

create procedure sp_generar_penalizaciones_automatico
    @monto_por_dia decimal(10, 2)
as
begin
    set nocount on;

    insert into penalizaciones (prestamo_id, socio_id, monto, fecha_generacion, observaciones)
    select
        p.id,
        p.socio_id,
        datediff(day, p.fecha_devolucion_estimada, getdate()) * @monto_por_dia as monto_calculado,
        getdate() as fecha_generacion,
        'Penalización generada automáticamente por ' + cast(datediff(day, p.fecha_devolucion_estimada, getdate()) as nvarchar(10)) + ' días de retraso.'
    from
        prestamos as p
    where
        p.estado_prestamo = 'VENCIDO'
        and not exists (
            select 1
            from penalizaciones as pen
            where pen.prestamo_id = p.id
        );

    select @@rowcount as nuevas_penalizaciones_generadas;
end;
go

-- 6. Registrar un Libro y su Autor (Transacciones Controladas)

create procedure sp_registrar_libro_completo
    @isbn nvarchar(20),
    @titulo nvarchar(255),
    @anio int,
    @cantidad int,
    @id_editorial int,
    @id_categoria int,
    @id_autor int
as
begin
    set nocount on;
    
    begin transaction;
    
    begin try
        declare @id_nuevo_libro int;

        -- Insertar en la tabla principal de libros
        insert into libros (isbn, titulo, anio_publicacion, cantidad_total, cantidad_disponible, editorial_id, categoria_id)
        values (@isbn, @titulo, @anio, @cantidad, @cantidad, @id_editorial, @id_categoria);
        
        -- Obtener el ID del libro recién insertado
        set @id_nuevo_libro = scope_identity();

        -- Crear un punto de guardado después de la primera inserción
        save transaction punto_insercion_libro;

        -- Insertar la relación libro-autor
        insert into libros_autores (libro_id, autor_id)
        values (@id_nuevo_libro, @id_autor);

        -- Si todo fue exitoso, confirmar la transacción
        commit transaction;
        select 'Libro y autor asociados correctamente con ID: ' + cast(@id_nuevo_libro as nvarchar(10)) as resultado;

    end try
    begin catch
        -- Si ocurre un error, revertir toda la transacción
        if @@trancount > 0
        begin
            rollback transaction;
        end; -- Se puede añadir ; aquí por consistencia
        
        -- Y luego mostrar el error.
        ;throw;

    end catch
end;
go