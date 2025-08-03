
-- ejecutado en la base de datos 'master'
create login bibliotecariologin with password = 'Biblio1234@';
go

-- ejecutado en la base de datos del proyecto "sbibli"

-- 1. crear el usuario y vincularlo al login
create user bibliotecariouser for login bibliotecariologin;
go

-- 2. crear un rol personalizado
create role roloperador;
go

-- 3. dar permisos específicos y limitados al rol
grant select, insert, update on dbo.prestamos to roloperador;
grant select, insert, update on dbo.reservas to roloperador;
grant select on dbo.libros to roloperador;
grant select on dbo.socios to roloperador;
go

-- 4. asignar el usuario al rol
alter role roloperador add member bibliotecariouser;
go

