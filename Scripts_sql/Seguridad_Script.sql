-- Cifrado de datos

-- Cifrado de Contraseñas de Usuarios del Sistema

-- cambiar el tipo de dato de la columna de texto a binario
alter table usuarios_sistema alter column password varbinary(64) not null;
go

-- actualizar las contraseñas a su versión hasheada
update usuarios_sistema set password = hashbytes('sha2_256', 'P4ssw0rd.Admin.2025') where username = 'admin';
update usuarios_sistema set password = hashbytes('sha2_256', 'P4ssw0rd.Biblio.2025') where username = 'biblio1';
go

-- 1. crear una llave maestra para la base de datos
create master key encryption by password = 'MiContraseñaMaestraSuperSecreta!';
go

-- 2. crear un certificado protegido por la llave maestra
create certificate certificadodecifrado with subject = 'Certificado para Datos Sensibles';
go

-- 3. crear una llave simétrica protegida por el certificado
create symmetric key llavecifradosocios with algorithm = aes_256 encryption by certificate certificadodecifrado;
go

-- Cifrado de Datos Sensibles de Socios

-- 1. crear una llave maestra para la base de datos
create master key encryption by password = 'MiContraseñaMaestraSuperSecreta!';
go

-- 2. crear un certificado protegido por la llave maestra
create certificate certificadodecifrado with subject = 'Certificado para Datos Sensibles';
go

-- 3. crear una llave simétrica protegida por el certificado
create symmetric key llavecifradosocios with algorithm = aes_256 encryption by certificate certificadodecifrado;
go

-- Cifrado de datos

-- añadir columnas para los datos cifrados
alter table socios add email_cifrado varbinary(256);
alter table socios add telefono_cifrado varbinary(256);
go

-- abrir la llave para poder usarla
open symmetric key llavecifradosocios decryption by certificate certificadodecifrado;

-- cifrar los datos y guardarlos en las nuevas columnas
update socios set
    email_cifrado = encryptbykey(key_guid('llavecifradosocios'), email),
    telefono_cifrado = encryptbykey(key_guid('llavecifradosocios'), telefono);

-- cerrar la llave cuando se termina de usar
close symmetric key llavecifradosocios;
go

-- Lectura de Datos Descifrados:

open symmetric key llavecifradosocios decryption by certificate certificadodecifrado;

select
    nombre,
    apellido,
    convert(nvarchar(100), decryptbykey(email_cifrado)) as email_descifrado,
    convert(nvarchar(20), decryptbykey(telefono_cifrado)) as telefono_descifrado
from socios where id = 1;

close symmetric key llavecifradosocios;
go



-- Prevención de Inyección SQL

-- Procedimiento Vulnerable

create procedure sp_buscarsocio_vulnerable
    @apellido nvarchar(100)
as
begin
    declare @sql nvarchar(max);
    set @sql = 'select id, nombre, apellido, email from socios where apellido = ''' + @apellido + '''';
    exec sp_executesql @sql;
end;
go

-- Ejecución del Ataque

-- el atacante introduce código sql en lugar de un apellido
exec sp_buscarsocio_vulnerable ''' or 1=1 --';
go

-- Procedimiento Seguro

create procedure sp_buscarsocio_seguro
    @apellido nvarchar(100)
as
begin
    select id, nombre, apellido, email from socios where apellido = @apellido;
end;
go

-- intento de ataque: la consulta ahora busca un socio con el apellido literal "' or '1'='1'"
exec sp_buscarsocio_seguro ''' or 1=1 --';
go