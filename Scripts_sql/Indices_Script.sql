-- Índices y Optimización

-- Índices simples

-- Índice en la tabla 'libros' para buscar rápidamente por título.
create index ix_libros_titulo on libros(titulo);
go

-- Índice en la tabla 'socios' para agilizar la búsqueda por apellido.
-- 'cedula' y 'email' ya tienen índices porque son 'UNIQUE'.
create index ix_socios_apellido on socios(apellido);
go

-- Índices en 'prestamos' para acelerar los joins con 'socios' y 'libros'.
create index ix_prestamos_socio_id on prestamos(socio_id);
go
create index ix_prestamos_libro_id on prestamos(libro_id);
go

-- Índice en la tabla de unión para encontrar todos los libros de un autor rápidamente.
create index ix_libros_autores_autor_id on libros_autores(autor_id);
go

-- Índices compuestos

-- Para consultas que buscan préstamos de un socio y que además filtran por el estado.
-- Por ejemplo: "dame todos los préstamos 'EN_CURSO' del socio X".
create index ix_prestamos_socio_estado on prestamos(socio_id, estado_prestamo);
go

-- Para agilizar la búsqueda de socios por su apellido y luego por su nombre.
create index ix_socios_apellido_nombre on socios(apellido, nombre);
go