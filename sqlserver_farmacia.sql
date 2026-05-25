CREATE TABLE categorias_med (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE laboratorios (
    id_laboratorio INT IDENTITY(1,1) PRIMARY KEY,
    razon_social VARCHAR(150) NOT NULL,
    telefono VARCHAR(20)
);

CREATE TABLE medicamentos (
    id_medicamento INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    id_categoria INT NOT NULL,
    id_laboratorio INT NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    precio DECIMAL(10, 2) NOT NULL,
    CONSTRAINT FK_medicamentos_categorias FOREIGN KEY (id_categoria)
        REFERENCES categorias_med(id_categoria),
    CONSTRAINT FK_medicamentos_laboratorios FOREIGN KEY (id_laboratorio)
        REFERENCES laboratorios(id_laboratorio)
);
CREATE TABLE recetas_surtidas (
    id_receta INT IDENTITY(1,1) PRIMARY KEY,
    nss_paciente VARCHAR(150) NOT NULL,
    id_medicamento INT NOT NULL,
    cantidad INT NOT NULL,
    fecha_surtido DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_recetas_medicamentos FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento)
);
CREATE TABLE equipamiento_medico (
    id_equipo INT PRIMARY KEY IDENTITY(1,1),
    nombre_equipo VARCHAR(100),
    area_asignada VARCHAR(100),
    fecha_ultimo_mantenimiento DATE
);
------------Coonsultas-----------------------------------
-- 41. 
SELECT * FROM medicamentos;

-- 42. 
SELECT nombre, precio FROM medicamentos 
WHERE precio > 500.00;

-- 43. 
SELECT * FROM laboratorios;

-- 44. 
SELECT id_categoria, COUNT(*) AS cantidad_medicamentos 
FROM medicamentos 
GROUP BY id_categoria;

-- 45. 
SELECT * FROM equipamiento_medico 
WHERE area_asignada = 'Quirófano';

-- 46.
SELECT AVG(precio) AS precio_promedio FROM medicamentos;

-- 47. 
SELECT TOP 1 * FROM medicamentos 
ORDER BY precio DESC;

-- 48. 
SELECT * FROM equipamiento_medico 
WHERE YEAR(fecha_ultimo_mantenimiento) <> 2026;

-- 49. 
SELECT COUNT(*) AS total_recetas_surtidas FROM recetas_surtidas;

-- 50. 
SELECT * FROM recetas_surtidas 
WHERE fecha_surtido >= DATEADD(day, -7, GETDATE());

-- 51. 
SELECT * FROM laboratorios 
WHERE razon_social LIKE 'A%';

-- 52. 
SELECT TOP 5 * FROM medicamentos 
ORDER BY stock DESC;

-- 53. 
SELECT * FROM medicamentos 
WHERE precio BETWEEN 100.00 AND 300.00;

-- 54. 
SELECT nombre_equipo, LEN(nombre_equipo) AS longitud_nombre 
FROM equipamiento_medico;

-- 55. 
SELECT id_medicamento, COUNT(*) AS veces_surtido 
FROM recetas_surtidas 
GROUP BY id_medicamento;

-- 56. 
SELECT * FROM recetas_surtidas 
WHERE cantidad > 2;

-- 57.
SELECT nss_paciente, SUM(cantidad) AS total_productos 
FROM recetas_surtidas 
GROUP BY nss_paciente 
HAVING SUM(cantidad) > 5;

-- 58. 
SELECT DISTINCT area_asignada FROM equipamiento_medico;

-- 59. 
SELECT * FROM medicamentos 
WHERE id_laboratorio IN (2, 4);

-- 60. 
SELECT * FROM equipamiento_medico 
ORDER BY area_asignada ASC, fecha_ultimo_mantenimiento ASC;

-- 61. 
SELECT UPPER(nombre) AS categoria_mayuscula 
FROM categorias_med;

-- 62. 
SELECT nombre, precio, (precio * 1.16) AS precio_con_iva 
FROM medicamentos;

-- 63. 
SELECT * FROM recetas_surtidas 
WHERE id_medicamento = 5;

-- 64. 
SELECT id_laboratorio, AVG(precio) AS promedio_precio 
FROM medicamentos 
GROUP BY id_laboratorio 
HAVING AVG(precio) > 400.00;

-- 65. 
SELECT area_asignada, COUNT(*) AS cantidad_equipos 
FROM equipamiento_medico 
GROUP BY area_asignada;

-- 66. 
SELECT CAST(fecha_surtido AS DATE) AS fecha, COUNT(*) AS recetas_por_dia 
FROM recetas_surtidas 
GROUP BY CAST(fecha_surtido AS DATE);

-- 67.
SELECT * FROM recetas_surtidas 
ORDER BY fecha_surtido DESC;

-- 68.
SELECT * FROM medicamentos 
WHERE id_medicamento IN (SELECT DISTINCT id_medicamento FROM recetas_surtidas);

-- 69. 
SELECT * FROM equipamiento_medico 
WHERE YEAR(fecha_ultimo_mantenimiento) < 2025;

-- 70.
SELECT * FROM laboratorios 
WHERE id_laboratorio IN (SELECT id_laboratorio FROM medicamentos WHERE nombre LIKE '%Amoxicilina%');

-- 71.
SELECT * FROM medicamentos 
WHERE stock < (SELECT AVG(CAST(stock AS FLOAT)) FROM medicamentos);

-- 72. 
SELECT id_receta, (cantidad * 2) AS cantidad_duplicada 
FROM recetas_surtidas;

-- 73. 
SELECT * FROM medicamentos 
WHERE stock = (SELECT MAX(stock) FROM medicamentos);

-- 74.
SELECT COUNT(DISTINCT nss_paciente) AS total_pacientes_unicos 
FROM recetas_surtidas;

-- 75. 
SELECT * FROM medicamentos 
WHERE stock = 0;

-- 76. 
SELECT TOP 1 id_medicamento, COUNT(*) AS veces_recetado 
FROM recetas_surtidas 
GROUP BY id_medicamento 
ORDER BY veces_recetado DESC;

-- 77. 
SELECT LEFT(nombre, 5) AS primeros_5_caracteres 
FROM categorias_med;

-- 78. 
SELECT nss_paciente, SUM(cantidad) AS total_surtido 
FROM recetas_surtidas 
GROUP BY nss_paciente;

-- 79.
SELECT * FROM medicamentos 
WHERE id_categoria = 1 AND stock > 50;

-- 80. 
SELECT nombre, precio 
FROM medicamentos 
ORDER BY nombre ASC;
------------------Joins-------------------------------------
-- 11. 
SELECT m.nombre AS medicamento, c.nombre AS categoria
FROM medicamentos m
INNER JOIN categorias_med c ON m.id_categoria = c.id_categoria;

-- 12. 
SELECT l.razon_social AS laboratorio, ISNULL(SUM(m.stock), 0) AS stock_total
FROM laboratorios l
LEFT JOIN medicamentos m ON l.id_laboratorio = m.id_laboratorio
GROUP BY l.id_laboratorio, l.razon_social;

-- 13.
SELECT r.id_receta, m.nombre AS medicamento, c.nombre AS categoria
FROM recetas_surtidas r
INNER JOIN medicamentos m ON r.id_medicamento = m.id_medicamento
INNER JOIN categorias_med c ON m.id_categoria = c.id_categoria;

-- 14. 
SELECT m.id_medicamento, m.nombre AS medicamento
FROM medicamentos m
LEFT JOIN recetas_surtidas r ON m.id_medicamento = r.id_medicamento
WHERE r.id_receta IS NULL;

-- 15. 
SELECT l.razon_social AS laboratorio, COUNT(r.id_receta) AS recetas_surtidas_total
FROM laboratorios l
INNER JOIN medicamentos m ON l.id_laboratorio = m.id_laboratorio
INNER JOIN recetas_surtidas r ON m.id_medicamento = r.id_medicamento
GROUP BY l.id_laboratorio, l.razon_social;

-- 16. 
SELECT m.nombre AS medicamento, l.razon_social AS laboratorio
FROM medicamentos m
INNER JOIN laboratorios l ON m.id_laboratorio = l.id_laboratorio;

-- 17. 
SELECT c.nombre AS categoria, COUNT(m.id_medicamento) AS total_medicamentos
FROM medicamentos m
RIGHT JOIN categorias_med c ON m.id_categoria = c.id_categoria
GROUP BY c.id_categoria, c.nombre;

-- 18.
SELECT r.fecha_surtido, r.cantidad, m.precio AS precio_unitario, (r.cantidad * m.precio) AS total_por_receta
FROM recetas_surtidas r
INNER JOIN medicamentos m ON r.id_medicamento = m.id_medicamento;

-- 19. 
SELECT l.razon_social AS laboratorio, COUNT(m.id_medicamento) AS medicamentos_distintos
FROM laboratorios l
INNER JOIN medicamentos m ON l.id_laboratorio = m.id_laboratorio
GROUP BY l.id_laboratorio, l.razon_social
HAVING COUNT(m.id_medicamento) > 5;

-- 20. 
SELECT c.nombre AS categoria
FROM categorias_med c
LEFT JOIN medicamentos m ON c.id_categoria = m.id_categoria
GROUP BY c.id_categoria, c.nombre
HAVING ISNULL(SUM(m.stock), 0) = 0;

USE farmacia_db;
GO

------- TABLA DE ALERTAS -------------------

IF NOT EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[alertas_desabasto]') 
    AND type in (N'U')
)
BEGIN
    CREATE TABLE alertas_desabasto (
        id_alerta INT IDENTITY(1,1) PRIMARY KEY,
        id_medicamento INT,
        fecha_alerta DATETIME DEFAULT GETDATE(),
        mensaje VARCHAR(255)
    );
END;
GO

-- 8.
CREATE OR ALTER TRIGGER trg_medicamento_precio_negativo
ON medicamentos
AFTER INSERT
AS
BEGIN
    UPDATE m
    SET m.precio = 10.00
    FROM medicamentos m
    INNER JOIN inserted i
        ON m.id_medicamento = i.id_medicamento
    WHERE i.precio < 0;
END;
GO

--9.
CREATE OR ALTER TRIGGER trg_descontar_stock_surtido
ON recetas_surtidas
AFTER INSERT
AS
BEGIN
    UPDATE m
    SET m.stock = m.stock - i.cantidad
    FROM medicamentos m
    INNER JOIN inserted i
        ON m.id_medicamento = i.id_medicamento;
END;
GO

--10.
CREATE OR ALTER TRIGGER trg_prevenir_stock_negativo_receta
ON medicamentos
AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE stock < 0
    )
    BEGIN
        RAISERROR ('Error: Cantidad insuficiente en stock.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- 11.
CREATE OR ALTER TRIGGER trg_mantenimiento_fecha_hoy
ON equipamiento_medico
AFTER INSERT
AS
BEGIN
    UPDATE em
    SET em.fecha_ultimo_mantenimiento = CAST(GETDATE() AS DATE)
    FROM equipamiento_medico em
    INNER JOIN inserted i
        ON em.id_equipo = i.id_equipo
    WHERE em.fecha_ultimo_mantenimiento IS NULL;
END;
GO

--12.
CREATE OR ALTER TRIGGER trg_bloquear_borrado_quirofano
ON equipamiento_medico
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM deleted
        WHERE area_asignada = 'Quirófano'
    )
    BEGIN
        RAISERROR ('Error: No se pueden eliminar equipos asignados a Quirófano.', 16, 1);
        RETURN;
    END

    DELETE FROM equipamiento_medico
    WHERE id_equipo IN (
        SELECT id_equipo
        FROM deleted
    );
END;
GO

-- 13.
CREATE OR ALTER TRIGGER trg_validar_cantidad_positiva
ON recetas_surtidas
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE cantidad <= 0
    )
    BEGIN
        RAISERROR ('Error: La cantidad debe ser mayor a 0.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- 14. 
CREATE OR ALTER TRIGGER trg_log_alertas_desabasto
ON medicamentos
AFTER UPDATE
AS
BEGIN
    INSERT INTO alertas_desabasto (
        id_medicamento,
        mensaje
    )
    SELECT 
        id_medicamento,
        'Alerta: Sin existencias (Stock 0).'
    FROM inserted
    WHERE stock = 0;
END;
GO