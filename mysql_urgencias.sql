CREATE DATABASE IF NOT EXISTS urgencias_db;
USE urgencias_db;

CREATE TABLE pacientes (
    nss VARCHAR(15) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    tipo_sangre VARCHAR(5) NOT NULL
);

CREATE TABLE especialidades (
    id_especialidad INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    piso INT NOT NULL
);

CREATE TABLE medicos (
    cedula VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_especialidad INT NOT NULL,
    turno VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_especialidad)
        REFERENCES especialidades(id_especialidad)
);

CREATE TABLE citas (
    id_cita INT AUTO_INCREMENT PRIMARY KEY,
    nss_paciente VARCHAR(15) NOT NULL,
    cedula_medico VARCHAR(20) NOT NULL,
    fecha_hora DATETIME NOT NULL,
    estado VARCHAR(20) NOT NULL,
    FOREIGN KEY (nss_paciente)
        REFERENCES pacientes(nss),
    FOREIGN KEY (cedula_medico)
        REFERENCES medicos(cedula)
);

CREATE TABLE triaje_urgencias (
    id_triaje INT AUTO_INCREMENT PRIMARY KEY,
    nss_paciente VARCHAR(15) NOT NULL,
    nivel_gravedad VARCHAR(20) NOT NULL,
    sintomas TEXT NOT NULL,
    fecha_ingreso DATETIME NOT NULL,
    FOREIGN KEY (nss_paciente)
        REFERENCES pacientes(nss)
);



--- Consultas------
-- 1. 
SELECT * FROM pacientes;

-- 2. 
SELECT * FROM especialidades;

-- 3. 
SELECT nss, nombre FROM pacientes 
WHERE tipo_sangre = 'O-';

-- 4. 
SELECT * FROM citas 
WHERE estado = 'Pendiente';

-- 5. 
SELECT COUNT(*) AS total_medicos FROM medicos;

-- 6. 
SELECT * FROM triaje_urgencias 
WHERE nivel_gravedad IN ('Rojo', 'Crítico');

-- 7. 
SELECT MAX(fecha_nacimiento) AS fecha_nacimiento_mas_joven FROM pacientes;

-- 8. 
SELECT COUNT(*) AS total_citas FROM citas;

-- 9. 
SELECT id_especialidad, COUNT(*) AS cantidad_medicos 
FROM medicos 
GROUP BY id_especialidad;

-- 10. 
SELECT * FROM medicos 
WHERE turno = 'Nocturno';

-- 11. 
SELECT *
FROM pacientes
WHERE nombre LIKE 'A%';

-- 12. 
SELECT sintomas FROM triaje_urgencias 
WHERE sintomas LIKE '%dolor%';

-- 13. 
SELECT * FROM pacientes 
ORDER BY fecha_nacimiento ASC;

-- 14. 
SELECT nss_paciente FROM citas 
WHERE cedula_medico = '12345';

-- 15. 
SELECT DISTINCT cedula_medico FROM citas;

-- 16. 
SELECT * FROM pacientes 
LIMIT 15;

-- 17. 
SELECT tipo_sangre, COUNT(*) AS cantidad_pacientes 
FROM pacientes 
GROUP BY tipo_sangre;

-- 18.
SELECT *
FROM citas
WHERE DATE(fecha_hora) = CURDATE();
-- 19. 
SELECT *
FROM triaje_urgencias
WHERE DATE(fecha_ingreso) = CURDATE();
-- 20. 
SELECT * FROM medicos 
WHERE id_especialidad IN (1, 3, 5);

-- 21. 
SELECT cedula_medico, COUNT(*) AS cantidad_citas 
FROM citas 
GROUP BY cedula_medico;

-- 22. 
SELECT *
FROM medicos
WHERE turno = 'Matutino'
AND id_especialidad = 2;

-- 23.
SELECT 
    e.nombre,
    COUNT(m.cedula) AS total_medicos
FROM especialidades e
JOIN medicos m 
    ON e.id_especialidad = m.id_especialidad
GROUP BY e.id_especialidad, e.nombre
HAVING COUNT(m.cedula) > 5;

-- 24. 
SELECT nombre, LENGTH(nombre) AS longitud_nombre 
FROM pacientes;

-- 25. 
SELECT UPPER(nombre) AS especialidad_mayuscula 
FROM especialidades;

-- 26. 
SELECT LOWER(sintomas) AS sintomas_minuscula 
FROM triaje_urgencias;

-- 27. 
SELECT * FROM triaje_urgencias 
ORDER BY fecha_ingreso DESC 
LIMIT 5;

-- 28. 
SELECT nss_paciente, COUNT(*) AS total_citas 
FROM citas 
GROUP BY nss_paciente 
HAVING COUNT(*) > 2;

-- 29. 
SELECT * FROM medicos 
WHERE turno <> 'Vespertino';

-- 30.
SELECT * FROM medicos 
ORDER BY id_especialidad ASC, nombre ASC;

-- 31. 
SELECT * FROM pacientes 
WHERE nss IN (SELECT nss_paciente FROM citas);

-- 32. 
SELECT * FROM pacientes 
WHERE nss NOT IN (SELECT nss_paciente FROM triaje_urgencias);

-- 33. 
SELECT * FROM medicos 
WHERE id_especialidad IN (SELECT id_especialidad FROM especialidades WHERE nombre = 'Neurología');

-- 34.
SELECT nivel_gravedad, COUNT(*) AS total_urgencias 
FROM triaje_urgencias 
GROUP BY nivel_gravedad;

-- 35. 
SELECT cedula_medico, COUNT(*) AS total_citas 
FROM citas 
GROUP BY cedula_medico 
HAVING COUNT(*) > (
    SELECT AVG(conteo.total) 
    FROM (SELECT COUNT(*) AS total FROM citas GROUP BY cedula_medico) AS conteo
);

-- 36. 
SELECT nombre, YEAR(fecha_nacimiento) AS anio_nacimiento 
FROM pacientes;

-- 37. 
SELECT CONCAT(nss, ' - ', nombre) AS nss_y_nombre 
FROM pacientes;

-- 38. 
SELECT MONTH(fecha_hora) AS mes, COUNT(*) AS total_citas 
FROM citas 
GROUP BY MONTH(fecha_hora);

-- 39. 
SELECT MONTH(fecha_ingreso) AS mes, COUNT(*) AS total_pacientes 
FROM triaje_urgencias 
GROUP BY MONTH(fecha_ingreso);

-- 40. 
SELECT cedula_medico, COUNT(*) AS total_citas 
FROM citas 
GROUP BY cedula_medico 
ORDER BY total_citas DESC 
LIMIT 1;


---------------Joins--------------


-- 1. 
SELECT m.nombre AS medico, e.nombre AS especialidad
FROM medicos m
INNER JOIN especialidades e ON m.id_especialidad = e.id_especialidad;

-- 2. 
SELECT e.nombre AS especialidad, COUNT(m.cedula) AS total_medicos
FROM especialidades e
LEFT JOIN medicos m ON e.id_especialidad = m.id_especialidad
GROUP BY e.id_especialidad, e.nombre;

-- 3. 
SELECT p.nombre AS paciente, t.nivel_gravedad, t.fecha_ingreso
FROM pacientes p
INNER JOIN triaje_urgencias t ON p.nss = t.nss_paciente;

-- 4. 
SELECT p.nombre AS paciente, m.nombre AS medico, c.fecha_hora AS fecha_cita
FROM citas c
INNER JOIN pacientes p ON c.nss_paciente = p.nss
INNER JOIN medicos m ON c.cedula_medico = m.cedula;

-- 5. 
SELECT p.nss, p.nombre AS paciente
FROM pacientes p
LEFT JOIN triaje_urgencias t ON p.nss = t.nss_paciente
WHERE t.nss_paciente IS NULL;

-- 6. 
SELECT e.nombre AS especialidad, COUNT(c.id_cita) AS total_citas
FROM especialidades e
INNER JOIN medicos m ON e.id_especialidad = m.id_especialidad
INNER JOIN citas c ON m.cedula = c.cedula_medico
GROUP BY e.id_especialidad, e.nombre;

-- 7. 
SELECT m.cedula, m.nombre AS medico
FROM medicos m
LEFT JOIN citas c ON m.cedula = c.cedula_medico
WHERE c.id_cita IS NULL;

-- 8. 
SELECT DISTINCT p.nombre AS paciente, p.tipo_sangre, c.estado
FROM pacientes p
INNER JOIN citas c ON p.nss = c.nss_paciente
WHERE c.estado = 'Cancelada';

-- 9.
SELECT e.nombre AS especialidad, m.nombre AS medico
FROM medicos m
RIGHT JOIN especialidades e ON m.id_especialidad = e.id_especialidad
WHERE m.cedula IS NULL;

-- 10. 
SELECT t.id_triaje, t.sintomas, t.fecha_ingreso, p.nss, p.nombre AS paciente, p.tipo_sangre
FROM triaje_urgencias t
INNER JOIN pacientes p ON t.nss_paciente = p.nss
WHERE t.nivel_gravedad = 'Crítico';

USE urgencias_db;


-- --------------------------- TRIGGERS --------------------------


-- TABLA DE AUDITORÍA PARA CITAS


CREATE TABLE IF NOT EXISTS auditoria_citas (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_cita INT,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    accion VARCHAR(100)
);


-- 1.


DELIMITER $$

CREATE TRIGGER trg_validar_fecha_nacimiento
BEFORE INSERT ON pacientes
FOR EACH ROW
BEGIN
    IF NEW.fecha_nacimiento > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La fecha de nacimiento no puede ser futura.';
    END IF;
END$$

DELIMITER ;

-- 2. 


DELIMITER $$

CREATE TRIGGER trg_mayusculas_critico
BEFORE INSERT ON triaje_urgencias
FOR EACH ROW
BEGIN
    IF NEW.nivel_gravedad = 'Crítico' THEN
        SET NEW.sintomas = UPPER(NEW.sintomas);
    END IF;
END$$

DELIMITER ;


-- 3.

DELIMITER $$

CREATE TRIGGER trg_no_borrar_especialidad
BEFORE DELETE ON especialidades
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM medicos
        WHERE id_especialidad = OLD.id_especialidad
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: No se puede eliminar una especialidad con médicos asignados.';
    END IF;
END$$

DELIMITER ;

-- 4. 

DELIMITER $$

CREATE TRIGGER trg_validar_empalme_citas
BEFORE INSERT ON citas
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM citas
        WHERE cedula_medico = NEW.cedula_medico
        AND fecha_hora = NEW.fecha_hora
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El médico ya tiene una cita en esa fecha y hora.';
    END IF;
END$$

DELIMITER ;


-- 5. 

DELIMITER $$

CREATE TRIGGER trg_auditoria_citas
AFTER INSERT ON citas
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_citas (
        id_cita,
        accion
    )
    VALUES (
        NEW.id_cita,
        'Nueva cita registrada'
    );
END$$

DELIMITER ;


-- 6. 


DELIMITER $$

CREATE TRIGGER trg_validar_cita_atendida
BEFORE UPDATE ON citas
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Atendida'
    AND NEW.fecha_hora > NOW() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: No se puede marcar como atendida una cita futura.';
    END IF;
END$$

DELIMITER ;

-
-- 7. 

DELIMITER $$

CREATE TRIGGER trg_no_borrar_triaje
BEFORE DELETE ON triaje_urgencias
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Error: Los registros de urgencias no pueden eliminarse.';
END$$

DELIMITER ;