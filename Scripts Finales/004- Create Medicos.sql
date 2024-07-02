USE GestionCitasExpedientes;
GO

-- Tabla de Médicos
CREATE TABLE Medicos (
    MedicoID INT PRIMARY KEY IDENTITY(1,1),
    HospitalID INT FOREIGN KEY REFERENCES Hospitales(HospitalID),
    Nombre VARCHAR(100) NOT NULL,
    Especialidad VARCHAR(100) NOT NULL,
	Correo VARCHAR(100) NOT NULL,
	Activo bit not null default 1
);
go

-- Triggers

CREATE TRIGGER trg_Bitacora_Medicos 
ON Medicos
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Descripcion NVARCHAR(MAX);
	--Variables datos nuevos
	DECLARE @MedicoID INT = (SELECT MedicoID from inserted)
	DECLARE @HospitalID INT = (SELECT HospitalID from inserted)
	DECLARE @Nombre VARCHAR(100) = (SELECT Nombre from inserted)
	DECLARE @Especialidad VARCHAR(100) = (SELECT Especialidad from inserted)
	DECLARE @Correo VARCHAR(100) = (SELECT Correo from inserted)

	--Variables datos Viejos
	DECLARE @MedicoIDOld INT = (SELECT MedicoID from deleted)
	DECLARE @HospitalIDOld INT = (SELECT HospitalID from deleted)
	DECLARE @NombreOld VARCHAR(100) = (SELECT Nombre from deleted)
	DECLARE @EspecialidadOld VARCHAR(100) = (SELECT Especialidad from deleted)
	DECLARE @CorreoOld VARCHAR(100) = (SELECT Correo from deleted)

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @Descripcion = 'UPDATE en la tabla Medicos Datos nuevos: ID Medico: '+CAST(@HospitalID as varchar)
		+' ID Hospital: '+CAST(@HospitalID as varchar) + ' Nombre: '+@Nombre + ' Especialidad: '+@Especialidad +' Correo: '+@Correo+ 'Datos viejos ID Medico: '+CAST(@HospitalIDOld as varchar)
		+' ID Hospital: '+CAST(@HospitalIDOld as varchar) + ' Nombre: '+@NombreOld + ' Especialidad: '+@EspecialidadOld +' Correo: '+@CorreoOld ;
    END
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
        SET @Descripcion = 'INSERT en la tabla Medicos Datos nuevos: ID Medico: '+CAST(@HospitalID as varchar)
		+' ID Hospital: '+CAST(@HospitalID as varchar) + ' Nombre: '+@Nombre + ' Especialidad: '+@Especialidad +' Correo: '+@Correo;
    END
    ELSE
    BEGIN
        SET @Descripcion = 'DELETE en la tabla Medicos Datos nuevos: ID Medico: '+CAST(@HospitalID as varchar)
		+' ID Hospital: '+CAST(@HospitalID as varchar) + ' Nombre: '+@Nombre + ' Especialidad: '+@Especialidad +' Correo: '+@Correo+ 'Datos viejos ID Medico: '+CAST(@HospitalIDOld as varchar)
		+' ID Hospital: '+CAST(@HospitalIDOld as varchar) + ' Nombre: '+@NombreOld + ' Especialidad: '+@EspecialidadOld +' Correo: '+@CorreoOld ;
    END

    Exec  sp_crear_bitacora @Descripcion;
END;
go

-- Procedimientos

CREATE PROCEDURE sp_regsitro_medicos
    @HospitalID INT,
    @Nombre VARCHAR(100),
    @Especialidad VARCHAR(100)
AS
BEGIN
	
	BEGIN TRANSACTION

	 INSERT INTO Medicos (HospitalID, Nombre, Especialidad)
     VALUES (@HospitalID, @Nombre, @Especialidad);

    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
  END;
GO

CREATE PROCEDURE sp_actualizar_medicos
    @MedicoID INT,
    @HospitalID INT,
    @Nombre VARCHAR(100),
    @Especialidad VARCHAR(100),
    @HorarioAtencion VARCHAR(50)
AS
BEGIN
	BEGIN TRANSACTION
		UPDATE Medicos
    SET HospitalID = @HospitalID, Nombre = @Nombre, Especialidad = @Especialidad
    WHERE MedicoID = @MedicoID;

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;    
END;
GO

CREATE PROCEDURE sp_eliminar_medico
    @MedicoID INT
AS
BEGIN
	BEGIN TRANSACTION
		 UPDATE Medicos
		SET Activo = 0
		WHERE MedicoID = @MedicoID;
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END
	COMMIT;   
END;
go