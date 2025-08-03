-- �ndices y Optimizaci�n

-- �ndices simples

-- �ndice en la tabla 'libros' para buscar r�pidamente por t�tulo.
create index ix_libros_titulo on libros(titulo);
go

-- �ndice en la tabla 'socios' para agilizar la b�squeda por apellido.
-- 'cedula' y 'email' ya tienen �ndices porque son 'UNIQUE'.
create index ix_socios_apellido on socios(apellido);
go

-- �ndices en 'prestamos' para acelerar los joins con 'socios' y 'libros'.
create index ix_prestamos_socio_id on prestamos(socio_id);
go
create index ix_prestamos_libro_id on prestamos(libro_id);
go

-- �ndice en la tabla de uni�n para encontrar todos los libros de un autor r�pidamente.
create index ix_libros_autores_autor_id on libros_autores(autor_id);
go

-- �ndices compuestos

-- Para consultas que buscan pr�stamos de un socio y que adem�s filtran por el estado.
-- Por ejemplo: "dame todos los pr�stamos 'EN_CURSO' del socio X".
create index ix_prestamos_socio_estado on prestamos(socio_id, estado_prestamo);
go

-- Para agilizar la b�squeda de socios por su apellido y luego por su nombre.
create index ix_socios_apellido_nombre on socios(apellido, nombre);
go