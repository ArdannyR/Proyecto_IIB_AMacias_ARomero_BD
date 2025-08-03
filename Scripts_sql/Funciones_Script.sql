-- Funciones

-- 1. Función para Calcular la Edad de un Autor

create function fn_calcular_edad_autor (
    @fecha_nacimiento date
)
returns int
as
begin
    -- Si la fecha es nula, devuelve nulo.
    if @fecha_nacimiento is null
        return null;

    -- Calcula la diferencia en años entre la fecha de nacimiento y la fecha actual.
    declare @edad int;
    set @edad = datediff(year, @fecha_nacimiento, getdate());

    return @edad;
end;
go

-- 2. Función para Obtener la Deuda Total de un Socio

create function fn_obtener_deuda_total_socio (
    @id_socio int
)
returns decimal(10, 2)
as
begin
    declare @deuda_total decimal(10, 2);

    -- Suma los montos de las penalizaciones pendientes para el socio especificado.
    select @deuda_total = sum(monto)
    from penalizaciones
    where
        socio_id = @id_socio
        and estado_penalizacion = 'PENDIENTE';

    -- Si no hay deudas (el resultado es NULL), devuelve 0.
    return isnull(@deuda_total, 0.00);
end;
go

-- 3. Función para Verificar la Disponibilidad de un Libro

create function fn_verificar_disponibilidad_libro (
    @id_libro int
)
returns nvarchar(20)
as
begin
    declare @cantidad_disponible int;
    declare @estado_disponibilidad nvarchar(20);

    -- Obtiene la cantidad de copias disponibles para el libro.
    select @cantidad_disponible = cantidad_disponible from libros where id = @id_libro;

    -- Usa una estructura CASE para determinar el estado.
    set @estado_disponibilidad =
        case
            when @cantidad_disponible = 0 then 'Agotado'
            when @cantidad_disponible between 1 and 3 then 'Pocas Unidades'
            when @cantidad_disponible > 3 then 'Disponible'
            else 'Desconocido'
        end;

    return @estado_disponibilidad;
end;
go