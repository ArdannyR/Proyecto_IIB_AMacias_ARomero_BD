-- =================================================================
-- NOTA DE MIGRACIÓN:
-- Los tipos ENUM de PostgreSQL no existen en SQL Server.
-- Se han reemplazado con restricciones CHECK en cada tabla.
-- =================================================================

-- PARTE 1: CREACIÓN DE LAS TABLAS PRINCIPALES (11 Tablas)

-- Tabla 1: Editoriales de los libros
CREATE TABLE editoriales (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL UNIQUE,
    pais_origen NVARCHAR(50)
);
GO

-- Tabla 2: Categorías o géneros de los libros
CREATE TABLE categorias (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL UNIQUE,
    descripcion NVARCHAR(MAX)
);
GO

-- Tabla 3: Autores de los libros
CREATE TABLE autores (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    apellido NVARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    nacionalidad NVARCHAR(50)
);
GO

-- Tabla 4: Libros (El catálogo principal)
CREATE TABLE libros (
    id INT IDENTITY(1,1) PRIMARY KEY,
    isbn NVARCHAR(20) NOT NULL UNIQUE,
    titulo NVARCHAR(255) NOT NULL,
    anio_publicacion INT,
    portada_url NVARCHAR(255),
    cantidad_total INT NOT NULL,
    cantidad_disponible INT NOT NULL,
    editorial_id INT,
    categoria_id INT,
    CONSTRAINT FK_libros_editoriales FOREIGN KEY (editorial_id) REFERENCES editoriales(id),
    CONSTRAINT FK_libros_categorias FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);
GO

-- Tabla 5: Tabla de Unión para Libros y Autores (Relación Muchos a Muchos)
CREATE TABLE libros_autores (
    libro_id INT NOT NULL,
    autor_id INT NOT NULL,
    PRIMARY KEY (libro_id, autor_id),
    CONSTRAINT FK_libros_autores_libro FOREIGN KEY (libro_id) REFERENCES libros(id) ON DELETE CASCADE,
    CONSTRAINT FK_libros_autores_autor FOREIGN KEY (autor_id) REFERENCES autores(id) ON DELETE CASCADE
);
GO

-- Tabla 6: Usuarios del Sistema (Empleados)
CREATE TABLE usuarios_sistema (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) NOT NULL UNIQUE,
    password NVARCHAR(255) NOT NULL,
    rol NVARCHAR(15) NOT NULL,
    estado NVARCHAR(10) NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT CK_usuarios_rol CHECK (rol IN ('ADMINISTRADOR', 'BIBLIOTECARIO')),
    CONSTRAINT CK_usuarios_estado CHECK (estado IN ('ACTIVO', 'INACTIVO'))
);
GO

-- Tabla 7: Socios de la Biblioteca (Clientes)
CREATE TABLE socios (
    id INT IDENTITY(1,1) PRIMARY KEY,
    cedula NVARCHAR(15) NOT NULL UNIQUE,
    nombre NVARCHAR(100) NOT NULL,
    apellido NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    telefono NVARCHAR(20),
    fecha_registro DATE NOT NULL,
    estado_socio NVARCHAR(15) NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT CK_socios_estado CHECK (estado_socio IN ('ACTIVO', 'CON_MULTAS', 'VETADO'))
);
GO

-- Tabla 8: Direcciones (Reutilizable para Socios y Usuarios del Sistema)
CREATE TABLE direcciones (
    id INT IDENTITY(1,1) PRIMARY KEY,
    calle_principal NVARCHAR(255) NOT NULL,
    ciudad NVARCHAR(100) NOT NULL,
    codigo_postal NVARCHAR(10),
    tipo_direccion NVARCHAR(15) NOT NULL DEFAULT 'PRINCIPAL',
    socio_id INT,
    usuario_sistema_id INT,
    CONSTRAINT CK_direcciones_tipo CHECK (tipo_direccion IN ('PRINCIPAL', 'SECUNDARIA', 'TRABAJO')),
    CONSTRAINT FK_direcciones_socios FOREIGN KEY (socio_id) REFERENCES socios(id) ON DELETE CASCADE,
    CONSTRAINT FK_direcciones_usuarios FOREIGN KEY (usuario_sistema_id) REFERENCES usuarios_sistema(id) ON DELETE SET NULL
);
GO

-- Tabla 9: Préstamos de libros
CREATE TABLE prestamos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    libro_id INT NOT NULL,
    socio_id INT NOT NULL,
    usuario_sistema_id INT NOT NULL,
    fecha_prestamo DATE NOT NULL,
    fecha_devolucion_estimada DATE NOT NULL,
    fecha_devolucion_real DATE,
    estado_prestamo NVARCHAR(15) NOT NULL DEFAULT 'EN_CURSO',
    CONSTRAINT CK_prestamos_estado CHECK (estado_prestamo IN ('EN_CURSO', 'DEVUELTO', 'VENCIDO')),
    CONSTRAINT FK_prestamos_libros FOREIGN KEY (libro_id) REFERENCES libros(id),
    CONSTRAINT FK_prestamos_socios FOREIGN KEY (socio_id) REFERENCES socios(id),
    CONSTRAINT FK_prestamos_usuarios FOREIGN KEY (usuario_sistema_id) REFERENCES usuarios_sistema(id)
);
GO

-- Tabla 10: Reservas de libros
CREATE TABLE reservas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    libro_id INT NOT NULL,
    socio_id INT NOT NULL,
    fecha_reserva DATETIME2 NOT NULL DEFAULT GETDATE(),
    fecha_expiracion DATE NOT NULL,
    estado_reserva NVARCHAR(15) NOT NULL DEFAULT 'ACTIVA',
    CONSTRAINT CK_reservas_estado CHECK (estado_reserva IN ('ACTIVA', 'CANCELADA', 'COMPLETADA')),
    CONSTRAINT FK_reservas_libros FOREIGN KEY (libro_id) REFERENCES libros(id),
    CONSTRAINT FK_reservas_socios FOREIGN KEY (socio_id) REFERENCES socios(id)
);
GO

-- Tabla 11: Penalizaciones o multas por préstamos vencidos
CREATE TABLE penalizaciones (
    id INT IDENTITY(1,1) PRIMARY KEY,
    prestamo_id INT NOT NULL UNIQUE,
    socio_id INT NOT NULL,
    monto DECIMAL(10, 2) NOT NULL,
    fecha_generacion DATE NOT NULL DEFAULT GETDATE(),
    fecha_pago DATE,
    estado_penalizacion NVARCHAR(15) NOT NULL DEFAULT 'PENDIENTE',
    observaciones NVARCHAR(MAX),
    CONSTRAINT CK_penalizaciones_estado CHECK (estado_penalizacion IN ('PENDIENTE', 'PAGADA')),
    CONSTRAINT FK_penalizaciones_prestamos FOREIGN KEY (prestamo_id) REFERENCES prestamos(id),
    CONSTRAINT FK_penalizaciones_socios FOREIGN KEY (socio_id) REFERENCES socios(id)
);
GO


-- =================================================================
-- PASO 4: INSERCIÓN DE DATOS DE PRUEBA
-- =================================================================

-- === CATEGORÍAS ===
SET IDENTITY_INSERT categorias ON;
INSERT INTO categorias (id, nombre, descripcion) VALUES
(1, 'Realismo Mágico', 'Género que combina elementos realistas con sucesos fantásticos.'),
(2, 'Ciencia Ficción', 'Basado en especulaciones sobre ciencia y tecnología del futuro.'),
(3, 'Fantasía', 'Incluye elementos mágicos y sobrenaturales que no existen en el mundo real.'),
(4, 'Novela Distópica', 'Describe una sociedad ficticia indeseable en sí misma.'),
(5, 'Clásico', 'Obras consideradas de alta calidad artística y universalidad.'),
(6, 'Aventura', 'Narrativa que enfatiza el viaje, el riesgo y la acción.'),
(7, 'Misterio', 'Género centrado en la resolución de un crimen o un enigma.');
SET IDENTITY_INSERT categorias OFF;
GO

-- === EDITORIALES ===
SET IDENTITY_INSERT editoriales ON;
INSERT INTO editoriales (id, nombre, pais_origen) VALUES
(1, 'Sudamericana', 'Argentina'),
(2, 'Seix Barral', 'España'),
(3, 'Minotauro', 'España'),
(4, 'Debolsillo', 'España'),
(5, 'Salamandra', 'España'),
(6, 'Anagrama', 'España'),
(7, 'Alfaguara', 'España');
SET IDENTITY_INSERT editoriales OFF;
GO

-- === AUTORES ===
SET IDENTITY_INSERT autores ON;
INSERT INTO autores (id, nombre, apellido, fecha_nacimiento, nacionalidad) VALUES
(1, 'Gabriel', 'García Márquez', '1927-03-06', 'Colombiano'),
(2, 'George', 'Orwell', '1903-06-25', 'Británico'),
(3, 'J.R.R.', 'Tolkien', '1892-01-03', 'Británico'),
(4, 'J.K.', 'Rowling', '1965-07-31', 'Británica'),
(5, 'Antoine', 'de Saint-Exupéry', '1900-06-29', 'Francés'),
(6, 'Miguel', 'de Cervantes', '1547-09-29', 'Español'),
(7, 'Mario', 'Vargas Llosa', '1936-03-28', 'Peruano'),
(8, 'Isabel', 'Allende', '1942-08-02', 'Chilena'),
(9, 'Julio', 'Cortázar', '1914-08-26', 'Argentino'),
(10, 'Arthur', 'Conan Doyle', '1859-05-22', 'Británico'),
(11, 'Mary', 'Shelley', '1797-08-30', 'Británica'),
(12, 'Frank', 'Herbert', '1920-10-08', 'Estadounidense'),
(13, 'Jorge Luis', 'Borges', '1899-08-24', 'Argentino');
SET IDENTITY_INSERT autores OFF;
GO

-- === LIBROS ===
SET IDENTITY_INSERT libros ON;
INSERT INTO libros (id, isbn, titulo, anio_publicacion, portada_url, cantidad_total, cantidad_disponible, editorial_id, categoria_id) VALUES
(1, '978-0307350444', 'Cien años de soledad', 1967, 'https://www.rae.es/sites/default/files/portada_cien_anos_de_soledad_0.jpg', 5, 3, 1, 1),
(2, '978-0451524935', '1984', 1949, 'https://images.penguinrandomhouse.com/cover/9780451524935', 6, 6, 2, 4),
(3, '978-0618640157', 'El Señor de los Anillos: La Comunidad del Anillo', 1954, 'https://images.cdn3.buscalibre.com/fit-in/360x360/28/f8/28f81dedb1a4cffe29b3ba0b9f8955cb.jpg', 4, 2, 3, 3),
(4, '978-8478884452', 'Harry Potter y la piedra filosofal', 1997, 'https://images.cdn3.buscalibre.com/fit-in/360x360/13/3f/133f3ee8195593a47eee5d46795ddc36.jpg', 8, 5, 5, 3),
(5, '978-0156012195', 'El Principito', 1943, 'https://image.cdn1.buscalibre.com/5b57fc1690f0b5295a8b4567.__RS360x360__.jpg', 10, 10, 4, 5),
(6, '978-8424110330', 'Don Quijote de la Mancha', 1605, 'https://images.cdn3.buscalibre.com/fit-in/360x360/4b/8b/4b8b83cc9076f7cd9397ff9c75288f70.jpg', 3, 3, 7, 5),
(7, '978-8420418887', 'La ciudad y los perros', 1963, 'https://images.cdn1.buscalibre.com/fit-in/360x360/46/0c/460cf768bec27103e3d93791c2770ba5.jpg', 4, 4, 7, 5),
(8, '978-0307475378', 'La casa de los espíritus', 1982, 'https://images.cdn2.buscalibre.com/fit-in/360x360/f4/36/f436345c6e5e5c4403f5a40ffd373aac.jpg', 5, 2, 1, 1),
(9, '978-8466336544', 'Rayuela', 1963, 'https://upload.wikimedia.org/wikipedia/commons/c/ca/Rayuela_JC.png', 3, 1, 7, 5),
(10, '978-8491052329', 'Estudio en escarlata', 1887, 'https://oceano.mx/img/obra/media/21832.jpg', 6, 6, 6, 7),
(11, '978-8497940848', 'Crónica de una muerte anunciada', 1981, 'https://www.crisol.com.pe/media/catalog/product/cache/cf84e6047db2ba7f2d5c381080c69ffe/9/7/9789871138012_editedprfi9clznq.jpg', 7, 7, 1, 1),
(12, '978-0486282114', 'Frankenstein', 1818, 'https://images.cdn3.buscalibre.com/fit-in/360x360/d3/f5/d3f5ef3f83139ee92343756b2fe82d12.jpg', 4, 0, 4, 5),
(13, '978-0441013593', 'Dune', 1965, 'https://images.penguinrandomhouse.com/cover/9780441013593', 5, 5, 3, 2),
(14, '978-8420633119', 'Ficciones', 1944, 'https://images.cdn2.buscalibre.com/fit-in/360x360/45/d0/45d01f060175c9747acb589c384b1ab0.jpg', 6, 5, 7, 5);
SET IDENTITY_INSERT libros OFF;
GO

-- === LIBROS Y AUTORES (TABLA RELACIONAL) ===
INSERT INTO libros_autores (libro_id, autor_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7), (8, 8), (9, 9),
(10, 10), (11, 1), (12, 11), (13, 12), (14, 13);
GO

-- === USUARIOS DEL SISTEMA ===
SET IDENTITY_INSERT usuarios_sistema ON;
INSERT INTO usuarios_sistema (id, username, password, rol, estado) VALUES
(1, 'admin', 'hash_pass_admin', 'ADMINISTRADOR', 'ACTIVO'), -- En una app real, la contraseña estaría hasheada
(2, 'biblio1', 'hash_pass_biblio1', 'BIBLIOTECARIO', 'ACTIVO'),
(3, 'biblio2', 'hash_pass_biblio2', 'BIBLIOTECARIO', 'INACTIVO');
SET IDENTITY_INSERT usuarios_sistema OFF;
GO

-- === SOCIOS ===
SET IDENTITY_INSERT socios ON;
INSERT INTO socios (id, cedula, nombre, apellido, email, telefono, fecha_registro, estado_socio) VALUES
(1, '1712345678', 'Juan', 'Pérez', 'juan.perez@email.com', '0987654321', '2023-01-15', 'ACTIVO'),
(2, '1787654321', 'Ana', 'Gómez', 'ana.gomez@email.com', '0991234567', '2023-02-20', 'ACTIVO'),
(3, '1723456789', 'Carlos', 'Rodríguez', 'carlos.r@email.com', '0988887777', '2023-03-10', 'CON_MULTAS'),
(4, '1798765432', 'Sofía', 'Martínez', 'sofia.m@email.com', '0976543210', '2023-05-01', 'ACTIVO'),
(5, '1756789012', 'Luis', 'Hernández', 'luis.h@email.com', '0965432109', '2023-06-12', 'VETADO'),
(6, '1711223344', 'Lucía', 'García', 'lucia.g@email.com', '0954321098', '2023-07-22', 'ACTIVO'),
(7, '1755667788', 'Miguel', 'López', 'miguel.l@email.com', '0943210987', '2023-08-30', 'ACTIVO'),
(8, '1799887766', 'Elena', 'Díaz', 'elena.d@email.com', '0932109876', '2023-09-05', 'ACTIVO'),
(9, '1744332211', 'Javier', 'Sánchez', 'javier.s@email.com', '0921098765', '2023-10-18', 'ACTIVO'),
(10, '1766554433', 'Valeria', 'Ramírez', 'valeria.r@email.com', '0910987654', '2023-11-25', 'CON_MULTAS'),
(11, '1700112233', 'David', 'Flores', 'david.f@email.com', '0909876543', '2024-01-09', 'ACTIVO'),
(12, '1722334455', 'Paula', 'Acosta', 'paula.a@email.com', '0987654321', '2024-02-14', 'ACTIVO');
SET IDENTITY_INSERT socios OFF;
GO

-- === DIRECCIONES ===
SET IDENTITY_INSERT direcciones ON;
INSERT INTO direcciones (id, calle_principal, ciudad, codigo_postal, tipo_direccion, socio_id, usuario_sistema_id) VALUES
(1, 'Av. 6 de Diciembre N34-123', 'Quito', '170502', 'TRABAJO', NULL, 1),
(2, 'Av. Orellana E4-56', 'Quito', '170515', 'TRABAJO', NULL, 2),
(3, 'Av. República E7-89', 'Quito', '170501', 'TRABAJO', NULL, 3),
(4, 'Av. Amazonas y Patria', 'Quito', '170517', 'PRINCIPAL', 1, NULL),
(5, 'Calle La Pradera y Av. Diego de Almagro', 'Quito', '170515', 'SECUNDARIA', 1, NULL),
(6, 'Av. Shyris y Naciones Unidas', 'Quito', '170501', 'PRINCIPAL', 2, NULL),
(7, 'Av. González Suárez 890', 'Quito', '170508', 'PRINCIPAL', 3, NULL),
(8, 'Calle Whymper y Coruña', 'Quito', '170517', 'PRINCIPAL', 4, NULL),
(9, 'Av. Eloy Alfaro y Alemania', 'Quito', '170501', 'PRINCIPAL', 5, NULL),
(10, 'Av. de los Granados y 6 de Diciembre', 'Quito', '170503', 'PRINCIPAL', 6, NULL),
(11, 'Calle Portugal y Av. República de El Salvador', 'Guayaquil', '090505', 'PRINCIPAL', 7, NULL),
(12, 'Av. 9 de Octubre y Boyacá', 'Guayaquil', '090306', 'TRABAJO', 7, NULL),
(13, 'Calle Larga y Av. Huayna Cápac', 'Cuenca', '010101', 'PRINCIPAL', 8, NULL),
(14, 'Av. Solano y 12 de Abril', 'Cuenca', '010104', 'PRINCIPAL', 9, NULL),
(15, 'Calle Bolívar y Montalvo', 'Ambato', '180101', 'PRINCIPAL', 10, NULL),
(16, 'Av. Miraflores y Las Palmeras', 'Manta', '130203', 'PRINCIPAL', 11, NULL),
(17, 'Av. Atahualpa y Rumiñahui', 'Riobamba', '060101', 'PRINCIPAL', 12, NULL);
SET IDENTITY_INSERT direcciones OFF;
GO

-- === PRÉSTAMOS ===
SET IDENTITY_INSERT prestamos ON;
INSERT INTO prestamos (id, libro_id, socio_id, usuario_sistema_id, fecha_prestamo, fecha_devolucion_estimada, fecha_devolucion_real, estado_prestamo) VALUES
-- Prestamos DEVUELTOS
(1, 5, 1, 2, '2024-05-10', '2024-05-25', '2024-05-24', 'DEVUELTO'),
(2, 6, 2, 2, '2024-06-01', '2024-06-16', '2024-06-15', 'DEVUELTO'),
-- Prestamos EN CURSO (no vencidos)
(3, 4, 4, 2, DATEADD(day, -10, GETDATE()), DATEADD(day, 5, GETDATE()), null, 'EN_CURSO'),
(4, 7, 6, 2, DATEADD(day, -5, GETDATE()), DATEADD(day, 10, GETDATE()), null, 'EN_CURSO'),
-- Prestamos VENCIDOS (base para las multas)
(5, 8, 3, 2, DATEADD(day, -30, GETDATE()), DATEADD(day, -15, GETDATE()), null, 'VENCIDO'),
(6, 9, 10, 2, DATEADD(day, -25, GETDATE()), DATEADD(day, -10, GETDATE()), null, 'VENCIDO'),
-- Préstamo que deja un libro sin stock
(7, 12, 8, 2, DATEADD(day, -1, GETDATE()), DATEADD(day, 14, GETDATE()), null, 'EN_CURSO');
SET IDENTITY_INSERT prestamos OFF;
GO
-- Actualizamos la cantidad disponible para el libro Frankenstein (id=12)
UPDATE libros SET cantidad_disponible = 0 WHERE id = 12;
GO

-- === PENALIZACIONES (basadas en los préstamos VENCIDOS) ===
SET IDENTITY_INSERT penalizaciones ON;
INSERT INTO penalizaciones (id, prestamo_id, socio_id, monto, fecha_generacion, fecha_pago, estado_penalizacion, observaciones) VALUES
(1, 5, 3, 7.50, DATEADD(day, -14, GETDATE()), null, 'PENDIENTE', 'Retraso de 15 días.'),
(2, 6, 10, 5.00, DATEADD(day, -9, GETDATE()), DATEADD(day, -2, GETDATE()), 'PAGADA', 'Retraso de 10 días. Pagado en efectivo.');
SET IDENTITY_INSERT penalizaciones OFF;
GO

-- === RESERVAS ===
SET IDENTITY_INSERT reservas ON;
INSERT INTO reservas (id, libro_id, socio_id, fecha_reserva, fecha_expiracion, estado_reserva) VALUES
-- Reserva para un libro sin stock (Frankenstein id=12)
(1, 12, 1, GETDATE(), DATEADD(day, 5, GETDATE()), 'ACTIVA'),
-- Reserva para un libro con stock bajo
(2, 1, 2, GETDATE(), DATEADD(day, 5, GETDATE()), 'ACTIVA'),
-- Reserva que ya fue completada
(3, 10, 9, '2024-04-01 10:00:00', '2024-04-06', 'COMPLETADA'),
-- Reserva cancelada
(4, 3, 11, '2024-05-15 15:30:00', '2024-05-20', 'CANCELADA');
SET IDENTITY_INSERT reservas OFF;
GO

-- =================================================================
-- PASO 5: AJUSTAR LOS VALORES IDENTITY PARA FUTURAS INSERCIONES
-- =================================================================
DBCC CHECKIDENT ('dbo.categorias', RESEED, 7);
DBCC CHECKIDENT ('dbo.editoriales', RESEED, 7);
DBCC CHECKIDENT ('dbo.autores', RESEED, 13);
DBCC CHECKIDENT ('dbo.libros', RESEED, 14);
DBCC CHECKIDENT ('dbo.usuarios_sistema', RESEED, 3);
DBCC CHECKIDENT ('dbo.socios', RESEED, 12);
DBCC CHECKIDENT ('dbo.direcciones', RESEED, 17);
DBCC CHECKIDENT ('dbo.prestamos', RESEED, 7);
DBCC CHECKIDENT ('dbo.penalizaciones', RESEED, 2);
DBCC CHECKIDENT ('dbo.reservas', RESEED, 4);
GO