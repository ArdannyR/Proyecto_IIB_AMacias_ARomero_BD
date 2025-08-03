-- Seguridad ante SQL Injection

-- Procedimiento Almacenado Seguro para el inicio de sesi�n

create procedure sp_seguridad_validar_usuario
    @p_username nvarchar(50),
    @p_password nvarchar(255)
as
begin
    set nocount on;

    -- Asumimos que la contrase�a tambi�n se verifica aqu�.
    -- En un sistema real, comparar�amos el HASH de la contrase�a.
    select id, username, rol, estado
    from usuarios_sistema
    where
        username = @p_username
        and password = @p_password;
end;
go