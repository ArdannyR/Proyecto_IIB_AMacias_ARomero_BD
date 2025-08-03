-- 5 Vistas

-- 1. Vista de Libros con Detalles Completos 

create view v_libros_detalle as
select
    l.titulo as titulo_del_libro,
    a.nombre + ' ' + a.apellido as autor,
    c.nombre as categoria,
    e.nombre as editorial,
    l.anio_publicacion,
    l.isbn
from
    libros as l
join
    libros_autores as la on l.id = la.libro_id
join
    autores as a on la.autor_id = a.id
join
    categorias as c on l.categoria_id = c.id
join
    editoriales as e on l.editorial_id = e.id;
go

-- 2. Vista de Préstamos Actualmente Activos

create view v_prestamos_activos as
select
    s.nombre + ' ' + s.apellido as socio,
    s.email as email_socio,
    l.titulo as libro_prestado,
    p.fecha_prestamo,
    p.fecha_devolucion_estimada
from
    prestamos as p
join
    socios as s on p.socio_id = s.id
join
    libros as l on p.libro_id = l.id
where
    p.estado_prestamo = 'EN_CURSO';
go

-- 3. Vista de Multas Pendientes de Pago

create view v_multas_pendientes as
select
    s.cedula,
    s.nombre + ' ' + s.apellido as socio_con_deuda,
    pen.monto as monto_pendiente,
    l.titulo as libro_del_prestamo,
    pen.fecha_generacion
from
    penalizaciones as pen
join
    socios as s on pen.socio_id = s.id
join
    prestamos as p on pen.prestamo_id = p.id
join
    libros as l on p.libro_id = l.id
where
    pen.estado_penalizacion = 'PENDIENTE';
go

-- 4. Vista General de Direcciones de Socios

create view v_direcciones_socios as
select
    s.cedula,
    s.nombre + ' ' + s.apellido as socio,
    d.tipo_direccion as tipo,
    d.calle_principal,
    d.ciudad,
    d.codigo_postal
from
    direcciones as d
join
    socios as s on d.socio_id = s.id;
go

-- 5. Vista de Socios y su Estado Actual

create view v_estado_socios as
select
    cedula,
    nombre,
    apellido,
    email,
    estado_socio
from
    socios;
go