-- Seguridad ante SQL Injection

-- Procedimiento Almacenado Seguro para el inicio de sesión

create procedure sp_seguridad_validar_usuario
    @p_username nvarchar(50),
    @p_password nvarchar(255)
as
begin
    set nocount on;

    -- Asumimos que la contraseña también se verifica aquí.
    -- En un sistema real, compararíamos el HASH de la contraseña.
    select id, username, rol, estado
    from usuarios_sistema
    where
        username = @p_username
        and password = @p_password;
end;
go