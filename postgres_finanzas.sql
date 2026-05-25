---------Tablas----------------
CREATE TABLE seguros (
    id_seguro SERIAL PRIMARY KEY,
    aseguradora VARCHAR(150) NOT NULL,
    cobertura_maxima DECIMAL(12, 2) NOT NULL
);

CREATE TABLE facturacion (
    id_factura SERIAL PRIMARY KEY,
    nss_paciente VARCHAR(15) NOT NULL,
    monto_total DECIMAL(12, 2) NOT NULL,
    id_seguro INT,
    fecha_emision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_facturacion_seguros FOREIGN KEY (id_seguro) REFERENCES seguros(id_seguro) ON DELETE SET NULL
);

CREATE TABLE historial_clinico (
    id_historial SERIAL PRIMARY KEY,
    nss_paciente VARCHAR(15) NOT NULL,
    diagnostico TEXT NOT NULL,       --
    estado_paciente VARCHAR(50) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE pagos_nomina (
    id_nomina SERIAL PRIMARY KEY,
    cedula_medico VARCHAR(20) NOT NULL, 
    monto_paid DECIMAL(12, 2) NOT NULL,
    mes_anio VARCHAR(7) NOT NULL,        
    fecha_transferencia TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE log_auditoria (
    id_log SERIAL PRIMARY KEY,
    modulo VARCHAR(100),
    accion VARCHAR(50),
    fecha TIMESTAMP,
    detalles JSON
);

--------------Consultas----------------------------------
-- 81. 
SELECT * FROM historial_clinico;

-- 82.
SELECT * FROM facturacion WHERE monto_total > 15000;

-- 83. 
SELECT aseguradora, cobertura_maxima FROM seguros;

-- 84.
SELECT SUM(monto_total) AS total_facturado FROM facturacion;

-- 85.
SELECT * FROM pagos_nomina;

-- 86.
SELECT MAX(monto_total) AS monto_maximo_facturado FROM facturacion;

-- 87.
SELECT MAX(monto_paid) AS pago_nomina_maximo FROM pagos_nomina;

-- 88. 
SELECT COUNT(*) AS total_logs FROM log_auditoria;

-- 89. 
SELECT id_seguro, COUNT(*) AS cantidad_facturas 
FROM facturacion 
GROUP BY id_seguro;

-- 90.
SELECT nss_paciente, SUM(monto_total) AS total_por_paciente 
FROM facturacion 
GROUP BY nss_paciente;

-- 91.
SELECT *
FROM log_auditoria
WHERE modulo = 'Urgencias';

-- 92. 
SELECT detalles->>'ip' AS ip_origen FROM log_auditoria;

-- 93. 
SELECT * FROM facturacion WHERE fecha_emision = CURRENT_DATE;

-- 94. 
SELECT *
FROM historial_clinico
WHERE estado_paciente = 'Grave';

-- 95.
SELECT 
    SUM(monto_paid) AS total_nomina
FROM pagos_nomina
WHERE mes_anio = TO_CHAR(CURRENT_DATE, 'YYYY-MM');

-- 96. 
SELECT DISTINCT accion FROM log_auditoria;

-- 97. 
SELECT * FROM seguros 
ORDER BY cobertura_maxima DESC 
LIMIT 3;

-- 98.
SELECT TO_CHAR(fecha_emision, 'YYYY-MM') AS mes, COUNT(*) AS total_facturas 
FROM facturacion 
GROUP BY TO_CHAR(fecha_emision, 'YYYY-MM')
ORDER BY mes;

-- 99. 
SELECT * FROM facturacion WHERE monto_total BETWEEN 5000 AND 10000;

-- 100.
SELECT *
FROM pagos_nomina
WHERE cedula_medico = '54321';

-- 101.
SELECT * FROM log_auditoria WHERE accion LIKE '%UPDATE%';

-- 102. 
SELECT id_seguro, AVG(monto_total) AS promedio_facturado 
FROM facturacion 
GROUP BY id_seguro;

-- 103. 
SELECT UPPER(aseguradora) AS aseguradora_mayusculas FROM seguros;

-- 104. 
SELECT * FROM historial_clinico ORDER BY fecha_registro DESC;

-- 105. 
SELECT id_factura, monto_total, ROUND(monto_total * 0.10, 2) AS descuento_10, ROUND(monto_total * 0.90, 2) AS monto_con_descuento 
FROM facturacion;

-- 106. 
SELECT *
FROM facturacion
WHERE id_seguro IS NULL;

-- 107.
SELECT * FROM facturacion WHERE id_seguro IS NOT NULL;

-- 108. 
SELECT modulo, COUNT(*) AS total_logs 
FROM log_auditoria 
GROUP BY modulo;

-- 109. 
SELECT * FROM facturacion 
WHERE nss_paciente IN (
    SELECT nss_paciente 
    FROM historial_clinico 
    WHERE estado_paciente = 'Estable'
);

-- 110. 
SELECT *
FROM seguros
WHERE id_seguro NOT IN (
    SELECT id_seguro
    FROM facturacion
    WHERE id_seguro IS NOT NULL
);
-- 111.
SELECT LENGTH(detalles::text) AS longitud_json FROM log_auditoria;

-- 112. 
SELECT MAX(cobertura_maxima) AS maxima_cobertura FROM seguros;

-- 113. 
SELECT cedula_medico, monto_paid
FROM pagos_nomina
WHERE monto_paid > (
    SELECT AVG(monto_paid)
    FROM pagos_nomina
);

-- 114. 
SELECT * FROM log_auditoria ORDER BY fecha DESC LIMIT 10;

-- 115.
SELECT fecha_emision, SUM(monto_total) AS total_facturado_dia 
FROM facturacion 
GROUP BY fecha_emision
ORDER BY fecha_emision;

-- 116. 
SELECT nss_paciente FROM facturacion ORDER BY monto_total DESC LIMIT 1;

-- 117. 
SELECT COUNT(DISTINCT nss_paciente) AS pacientes_con_historial FROM historial_clinico;

-- 118. 
SELECT cedula_medico, SUM(monto_paid) AS total_nomina_medico 
FROM pagos_nomina 
GROUP BY cedula_medico;

-- 119. 
SELECT id_seguro, SUM(monto_total) AS total_asegurado 
FROM facturacion 
GROUP BY id_seguro 
HAVING SUM(monto_total) > 100000;

-- 120. 
SELECT *
FROM log_auditoria
WHERE detalles->>'error' = 'critico';

--TRIGGERS------------------



---8. 
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

CREATE OR ALTER TRIGGER trg_prevenir_stock_negativo
ON recetas_surtidas
AFTER INSERT
AS
BEGIN
    IF EXISTS
    (
        SELECT 1
        FROM medicamentos m
        INNER JOIN inserted i
            ON m.id_medicamento = i.id_medicamento
        WHERE m.stock < i.cantidad
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, 'Stock insuficiente para surtir la receta.', 1;
    END
END;
GO

--11. 
CREATE OR ALTER TRIGGER trg_mantenimiento_fecha_hoy
ON equipamiento_medico
AFTER INSERT
AS
BEGIN
    UPDATE em
    SET fecha_ultimo_mantenimiento = CAST(GETDATE() AS DATE)
    FROM equipamiento_medico em
    INNER JOIN inserted i
        ON em.id_equipo = i.id_equipo;
END;
GO



--12. 

CREATE OR ALTER TRIGGER trg_bloquear_borrado_quirofano
ON equipamiento_medico
INSTEAD OF DELETE
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM deleted
        WHERE area_asignada = 'Quirófano'
    )
    BEGIN
        THROW 50002,
        'No se pueden eliminar equipos asignados a Quirófano.',
        1;
    END

    DELETE FROM equipamiento_medico
    WHERE id_equipo IN
    (
        SELECT id_equipo
        FROM deleted
    );

END;
GO

--13. 

CREATE OR ALTER TRIGGER trg_validar_cantidad_positiva
ON recetas_surtidas
AFTER INSERT
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM inserted
        WHERE cantidad <= 0
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50003, 'La cantidad debe ser mayor a 0.', 1;
    END

END;
GO


--14.

IF OBJECT_ID('alertas_desabasto', 'U') IS NULL
BEGIN
    CREATE TABLE alertas_desabasto
    (
        id_alerta INT IDENTITY(1,1) PRIMARY KEY,
        id_medicamento INT,
        fecha_alerta DATETIME DEFAULT GETDATE(),
        mensaje VARCHAR(255)
    );
END;
GO

CREATE OR ALTER TRIGGER trg_log_alertas_desabasto
ON medicamentos
AFTER UPDATE
AS
BEGIN

    INSERT INTO alertas_desabasto
    (
        id_medicamento,
        mensaje
    )
    SELECT
        i.id_medicamento,
        'Alerta: medicamento sin existencias'
    FROM inserted i
    WHERE i.stock = 0;

END;
GO