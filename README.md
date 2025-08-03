SIBIBLI es una base de datos robusta construida en Microsoft SQL Server, diseñada para administrar de manera integral y eficiente las operaciones de una biblioteca. Permite gestionar el catálogo de libros, los socios, los préstamos, las devoluciones y las penalizaciones. Además, implementa un sistema avanzado de seguridad, auditoría y optimización para garantizar la integridad y el rendimiento de los datos.

✨ Características Principales
El sistema se compone de una arquitectura de base de datos completa que facilita la administración integral de la biblioteca:

📚 Gestión de la Biblioteca

    Catálogo de Libros: Administración completa de libros, incluyendo detalles como título, autor, editorial, categoría, ISBN y cantidad disponible.
    Gestión de Socios: Registro y actualización de los datos de los socios, con control sobre su estado (Activo, Con Multas, Vetado).
    
🔄 Préstamos y Devoluciones:
    
    sp_registrar_prestamo: Procedimiento para registrar préstamos, validando la disponibilidad del libro y el estado del socio.
    Actualización automática del stock de libros tras un préstamo o devolución.
    Generación automática de penalizaciones para los préstamos vencidos a través de sp_generar_penalizaciones_automatico.
    Reservas: Módulo para que los socios puedan reservar libros, con un control de estado (ACTIVA, CANCELADA, COMPLETADA) y fecha de expiración.
    Penalizaciones: Sistema para gestionar las multas por retrasos, registrando montos, fechas y estados de pago (Pendiente, Pagada).

🛡️ Administración y Seguridad

 * Control de Acceso por Roles:


       rol_operador: Rol con permisos limitados para gestionar préstamos y reservas, sin acceso a la modificación de datos maestros.

       Usuarios como bibliotecariouser son asignados a estos roles para limitar sus acciones en la base de datos.

 * Seguridad Avanzada:

       Cifrado de Datos: Uso de HASHBYTES('sha2_256', ...) para cifrar las contraseñas de los usuarios del sistema.
       Creación de una llave simétrica (llavecifradosocios) para cifrar y descifrar datos sensibles de los socios como el email y el teléfono.
       Prevención de Inyección SQL: sp_buscarsocio_seguro: Procedimiento almacenado que utiliza parámetros para evitar la construcción de consultas dinámicas vulnerables.

 * Auditoría Completa:

        bitacora_acciones: Tabla central que registra todas las operaciones (INSERT, UPDATE, DELETE), almacenando el usuario, la terminal, la IP, la acción y los datos antiguos/nuevos en formato JSON.

 * Triggers de Auditoría:

       trg_auditoria_socios: Captura cualquier cambio en la tabla de socios.
       trg_auditoria_libros: Registra modificaciones en el catálogo de libros.
       trg_auditoria_prestamos: Monitorea la creación o alteración de préstamos.

 * Optimización y Mantenimiento

    - Índices y Optimización:

          Índices simples: Como ix_libros_titulo para búsquedas rápidas por título o ix_socios_apellido para agilizar la búsqueda de socios.
          Índices compuestos: Como ix_prestamos_socio_estado para optimizar consultas de préstamos de un socio filtrados por estado.

 * Funciones:

       fn_calcular_edad_autor: Calcula la edad de un autor a partir de su fecha de nacimiento.
       fn_obtener_deuda_total_socio: Devuelve el monto total de multas pendientes de un socio.
       fn_verificar_disponibilidad_libro: Retorna el estado de disponibilidad de un libro (Agotado, Pocas Unidades, Disponible).

 * Backup y Respaldo:

        Backup_Caliente_Script.sql: Script para realizar un respaldo completo (FULL BACKUP) de la base de datos SIBIBLI en caliente y con compresión.

 * Vistas:

        v_libros_detalle: Unifica la información de libros, autores, categorías y editoriales en una sola vista.
        v_prestamos_activos: Muestra un listado de todos los préstamos que se encuentran EN_CURSO.
        v_multas_pendientes: Facilita la consulta de todas las penalizaciones que aún no han sido pagadas.

🛠️ Tecnologías Utilizadas

    Base de Datos: Microsoft SQL Server

✒️ Autores

    Macias Ariel.
    Romero Ardanny.

* Documentación del proyecto

      https://epnecuador-my.sharepoint.com/personal/ariel_macias_epn_edu_ec/_layouts/15/onedrive.aspx?id=%2Fpersonal%2Fariel_macias_epn_edu_ec%2FDocuments%2FProyecto_IIB_AMacias_ARomero_BdD&ga=1
