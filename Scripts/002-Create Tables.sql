USE GestionCitasExpedientes;
GO

-- Tabla de Hospitales
CREATE TABLE Hospitales (
    HospitalID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    Direccion NVARCHAR(200) NOT NULL,
    Telefono NVARCHAR(15) NOT NULL
);

-- Tabla de Médicos
CREATE TABLE Medicos (
    MedicoID INT PRIMARY KEY IDENTITY(1,1),
    HospitalID INT FOREIGN KEY REFERENCES Hospitales(HospitalID),
    Nombre NVARCHAR(100) NOT NULL,
    Especialidad NVARCHAR(100) NOT NULL
);

CREATE TABLE HorariosMedicos(
HorarioID INT PRIMARY KEY IDENTITY(1,1),
MedicoID INT FOREIGN KEY REFERENCES Medicos(MedicoID),
DiaSemana VARCHAR(1) NOT NULL CHECK(DiaSemana in('L','K','M','J','V','S','D')),
Hora_Inicio TIME NOT NULL
)
-- Tabla de Pacientes
CREATE TABLE Pacientes (
    PacienteID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    Apellidos NVARCHAR(100) NOT NULL,
    Edad INT NOT NULL,
    Altura DECIMAL(5,2) NOT NULL,
    Peso DECIMAL(5,2) NOT NULL,
    Telefono NVARCHAR(15) NOT NULL,
    Correo NVARCHAR(100) NOT NULL unique,
	Clave Varchar(10) not null
);

-- Tabla de Citas
CREATE TABLE Citas (
    CitaID INT PRIMARY KEY IDENTITY(1,1),
    PacienteID INT FOREIGN KEY REFERENCES Pacientes(PacienteID),
    MedicoID INT FOREIGN KEY REFERENCES Medicos(MedicoID),
    FechaHora DATETIME NOT NULL,
    Estado NVARCHAR(20) NOT NULL
);

-- Tabla de Expedientes
CREATE TABLE Expedientes (
    ExpedienteID INT PRIMARY KEY IDENTITY(1,1),
    PacienteID INT FOREIGN KEY REFERENCES Pacientes(PacienteID),
    Diagnostico NVARCHAR(MAX) NOT NULL,
    FechaDiagnostico DATE NOT NULL,
    Medicamentos NVARCHAR(MAX)
);

-- Tabla de Recetas
CREATE TABLE Recetas (
    RecetaID INT PRIMARY KEY IDENTITY(1,1),
    CitaID INT FOREIGN KEY REFERENCES Citas(CitaID),
    Medicamentos NVARCHAR(MAX) NOT NULL,
    Estado NVARCHAR(20) NOT NULL,
    FechaRegistro DATETIME NOT NULL
);

-- Bitácora
CREATE TABLE Bitacora (
    BitacoraID INT PRIMARY KEY IDENTITY(1,1),
    Descripcion NVARCHAR(MAX) NOT NULL,
    Fecha DATETIME NOT NULL DEFAULT GETDATE()
);

-- Tabla de Notificaciones
CREATE TABLE Notificaciones (
    NotificacionID INT PRIMARY KEY IDENTITY(1,1),
    PacienteID INT FOREIGN KEY REFERENCES Pacientes(PacienteID),
    MedicoID INT FOREIGN KEY REFERENCES Medicos(MedicoID),
    Mensaje NVARCHAR(MAX) NOT NULL,
    Fecha DATETIME NOT NULL DEFAULT GETDATE()
);