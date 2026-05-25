from faker import Faker
import random
from datetime import datetime, timedelta

import mysql.connector
import pyodbc
import psycopg2
from psycopg2.extras import Json

fake = Faker('es_MX')


mysql_conn = mysql.connector.connect(
    host="localhost",
    port=3306,
    user="root",
    password="root_password",
    database="urgencias_db"
)

mysql_cursor = mysql_conn.cursor()


sqlserver_conn = pyodbc.connect(
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER=localhost,1433;"
    "DATABASE=farmacia_db;"
    "UID=sa;"
    "PWD=Your_Password123;"
    "TrustServerCertificate=yes;"
)

sqlserver_cursor = sqlserver_conn.cursor()


postgres_conn = psycopg2.connect(
    host="localhost",
    port=5432,
    user="postgres",
    password="postgres_password",
    database="finanzas_auditoria_db"
)

postgres_cursor = postgres_conn.cursor()

print("✅ Conectado a las 3 bases de datos")



def fecha_random(inicio=2022, fin=2026):
    fecha_inicio = datetime(inicio, 1, 1)
    fecha_fin = datetime(fin, 12, 31)

    return fecha_inicio + timedelta(
        seconds=random.randint(
            0,
            int((fecha_fin - fecha_inicio).total_seconds())
        )
    )

print("\nInsertando datos en MySQL...")



especialidades = [
    ("Cardiología", 2),
    ("Pediatría", 3),
    ("Neurología", 4),
    ("Traumatología", 5),
    ("Urgencias", 1),
    ("Dermatología", 6),
    ("Oncología", 7),
    ("Psiquiatría", 8)
]

for nombre, piso in especialidades:
    mysql_cursor.execute("""
        INSERT INTO especialidades(nombre, piso)
        VALUES(%s, %s)
    """, (nombre, piso))

mysql_conn.commit()

mysql_cursor.execute("SELECT id_especialidad FROM especialidades")
ids_especialidades = [x[0] for x in mysql_cursor.fetchall()]

tipos_sangre = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]

nss_pacientes = []

for _ in range(80):

    nss = str(random.randint(1000000000, 9999999999))

    nss_pacientes.append(nss)

    mysql_cursor.execute("""
        INSERT INTO pacientes(
            nss,
            nombre,
            fecha_nacimiento,
            tipo_sangre
        )
        VALUES(%s, %s, %s, %s)
    """, (
        nss,
        fake.name(),
        fake.date_of_birth(minimum_age=1, maximum_age=90),
        random.choice(tipos_sangre)
    ))

mysql_conn.commit()

cedulas_medicos = []

turnos = ["Matutino", "Vespertino", "Nocturno"]

for _ in range(20):

    cedula = str(random.randint(1000000, 9999999))

    cedulas_medicos.append(cedula)

    mysql_cursor.execute("""
        INSERT INTO medicos(
            cedula,
            nombre,
            id_especialidad,
            turno
        )
        VALUES(%s, %s, %s, %s)
    """, (
        cedula,
        fake.name(),
        random.choice(ids_especialidades),
        random.choice(turnos)
    ))

mysql_conn.commit()

estados_cita = [
    "Pendiente",
    "Completada",
    "Cancelada"
]

for _ in range(50):

    mysql_cursor.execute("""
        INSERT INTO citas(
            nss_paciente,
            cedula_medico,
            fecha_hora,
            estado
        )
        VALUES(%s, %s, %s, %s)
    """, (
        random.choice(nss_pacientes),
        random.choice(cedulas_medicos),
        fecha_random(),
        random.choice(estados_cita)
    ))

mysql_conn.commit()

niveles = ["Leve", "Moderado", "Grave", "Crítico"]

sintomas_lista = [
    "Dolor de cabeza",
    "Fiebre",
    "Fractura",
    "Dolor abdominal",
    "Tos",
    "Dificultad respiratoria",
    "Mareo",
    "Convulsiones"
]

for _ in range(42):

    mysql_cursor.execute("""
        INSERT INTO triaje_urgencias(
            nss_paciente,
            nivel_gravedad,
            sintomas,
            fecha_ingreso
        )
        VALUES(%s, %s, %s, %s)
    """, (
        random.choice(nss_pacientes),
        random.choice(niveles),
        random.choice(sintomas_lista),
        fecha_random()
    ))

mysql_conn.commit()

print("✅ MySQL poblado")

print("\nInsertando datos en SQL Server...")

categorias = [
    "Analgésicos",
    "Antibióticos",
    "Antiinflamatorios",
    "Antidepresivos",
    "Vitaminas",
    "Antihistamínicos"
]

for categoria in categorias:

    sqlserver_cursor.execute("""
        INSERT INTO categorias_med(nombre)
        VALUES(?)
    """, categoria)

sqlserver_conn.commit()

sqlserver_cursor.execute("SELECT id_categoria FROM categorias_med")
ids_categoria = [x[0] for x in sqlserver_cursor.fetchall()]

for _ in range(14):

    sqlserver_cursor.execute("""
        INSERT INTO laboratorios(
            razon_social,
            telefono
        )
        VALUES(?, ?)
    """, (
        fake.company(),
        fake.phone_number()
    ))

sqlserver_conn.commit()

sqlserver_cursor.execute("SELECT id_laboratorio FROM laboratorios")
ids_laboratorios = [x[0] for x in sqlserver_cursor.fetchall()]

medicamentos = [
    "Paracetamol",
    "Ibuprofeno",
    "Amoxicilina",
    "Loratadina",
    "Omeprazol",
    "Diclofenaco",
    "Aspirina",
    "Metformina"
]

for _ in range(50):

    sqlserver_cursor.execute("""
        INSERT INTO medicamentos(
            nombre,
            id_categoria,
            id_laboratorio,
            stock,
            precio
        )
        VALUES(?, ?, ?, ?, ?)
    """, (
        random.choice(medicamentos),
        random.choice(ids_categoria),
        random.choice(ids_laboratorios),
        random.randint(10, 500),
        round(random.uniform(50, 3000), 2)
    ))

sqlserver_conn.commit()

sqlserver_cursor.execute("SELECT id_medicamento FROM medicamentos")
ids_medicamentos = [x[0] for x in sqlserver_cursor.fetchall()]

for _ in range(50):

    sqlserver_cursor.execute("""
        INSERT INTO recetas_surtidas(
            nss_paciente,
            id_medicamento,
            cantidad,
            fecha_surtido
        )
        VALUES(?, ?, ?, ?)
    """, (
        random.choice(nss_pacientes),
        random.choice(ids_medicamentos),
        random.randint(1, 5),
        fecha_random()
    ))

sqlserver_conn.commit()


equipos = [
    "Rayos X",
    "Resonancia Magnética",
    "Ultrasonido",
    "Ventilador",
    "Electrocardiograma",
    "Desfibrilador"
]

areas = [
    "Urgencias",
    "Radiología",
    "Quirófano",
    "UCI",
    "Pediatría"
]

for _ in range(30):

    sqlserver_cursor.execute("""
        INSERT INTO equipamiento_medico(
            nombre_equipo,
            area_asignada,
            fecha_ultimo_mantenimiento
        )
        VALUES(?, ?, ?)
    """, (
        random.choice(equipos),
        random.choice(areas),
        fake.date_between(start_date='-2y', end_date='today')
    ))

sqlserver_conn.commit()

print("✅ SQL Server poblado")


print("\nInsertando datos en PostgreSQL...")

aseguradoras = [
    "GNP",
    "AXA",
    "MetLife",
    "Qualitas",
    "Mapfre",
    "BBVA Seguros"
]

for aseguradora in aseguradoras:

    postgres_cursor.execute("""
        INSERT INTO seguros(
            aseguradora,
            cobertura_maxima
        )
        VALUES(%s, %s)
    """, (
        aseguradora,
        round(random.uniform(50000, 1000000), 2)
    ))

postgres_conn.commit()

postgres_cursor.execute("SELECT id_seguro FROM seguros")
ids_seguros = [x[0] for x in postgres_cursor.fetchall()]

for _ in range(70):

    postgres_cursor.execute("""
        INSERT INTO facturacion(
            nss_paciente,
            monto_total,
            id_seguro,
            fecha_emision
        )
        VALUES(%s, %s, %s, %s)
    """, (
        random.choice(nss_pacientes),
        round(random.uniform(1000, 50000), 2),
        random.choice(ids_seguros),
        fecha_random()
    ))

postgres_conn.commit()


diagnosticos = [
    "Gripe",
    "Fractura",
    "Diabetes",
    "Hipertensión",
    "Migraña",
    "Ansiedad"
]

estados = [
    "Estable",
    "En tratamiento",
    "Crítico",
    "Recuperado"
]

for _ in range(60):

    postgres_cursor.execute("""
        INSERT INTO historial_clinico(
            nss_paciente,
            diagnostico,
            estado_paciente,
            fecha_registro
        )
        VALUES(%s, %s, %s, %s)
    """, (
        random.choice(nss_pacientes),
        random.choice(diagnosticos),
        random.choice(estados),
        fecha_random()
    ))

postgres_conn.commit()

for _ in range(40):

    postgres_cursor.execute("""
    INSERT INTO pagos_nomina(
        cedula_medico,
        monto_paid,
        mes_anio,
        fecha_transferencia
    )
    VALUES(%s, %s, %s, %s)
""", (
    random.choice(cedulas_medicos),
    round(random.uniform(15000, 80000), 2),
    datetime.now().strftime("%Y-%m"),
    fecha_random()
))
postgres_conn.commit()


modulos = [
    "Pacientes",
    "Farmacia",
    "Facturación",
    "Usuarios",
    "Inventario"
]

acciones = [
    "INSERT",
    "UPDATE",
    "DELETE",
    "LOGIN"
]

for _ in range(74):

    detalles = {
        "usuario": fake.user_name(),
        "ip": fake.ipv4(),
        "descripcion": fake.sentence()
    }

    postgres_cursor.execute("""
        INSERT INTO log_auditoria(
            modulo,
            accion,
            fecha,
            detalles
        )
        VALUES(%s, %s, %s, %s)
    """, (
        random.choice(modulos),
        random.choice(acciones),
        fecha_random(),
        Json(detalles)
    ))

postgres_conn.commit()

print("✅ PostgreSQL poblado")

mysql_cursor.close()
mysql_conn.close()

sqlserver_cursor.close()
sqlserver_conn.close()

postgres_cursor.close()
postgres_conn.close()

print("\n======================================")
print("✅ DATOS INSERTADOS CORRECTAMENTE")
print("======================================")