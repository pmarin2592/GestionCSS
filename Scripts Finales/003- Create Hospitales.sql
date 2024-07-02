USE GestionCitasExpedientes;
GO

-- Tabla de Hospitales
CREATE TABLE Hospitales (
    HospitalID INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100) NOT NULL,
    Direccion VARCHAR(200) NOT NULL,
    Telefono VARCHAR(15) NOT NULL,
	Activo BIT NOT NULL DEFAULT 1
);
go
-- Triggers

CREATE TRIGGER trg_Bitacora_Hospitales 
ON Hospitales
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Descripcion NVARCHAR(MAX);
	--Variables datos nuevos
	DECLARE @HospitalID int = (SELECT HospitalID from inserted)
	DECLARE @Nombre VARCHAR(100) = (SELECT Nombre from inserted)
	DECLARE @Direccion VARCHAR(200) = (SELECT Direccion from inserted)
	DECLARE @Telefono VARCHAR(15) = (SELECT Telefono from inserted)

	--Variables datos Viejos
	DECLARE @HospitalIDOld int = (SELECT HospitalID from deleted)
	DECLARE @NombreOld VARCHAR(100) = (SELECT Nombre from deleted)
	DECLARE @DireccionOld VARCHAR(200) = (SELECT Direccion from deleted)
	DECLARE @TelefonoOld VARCHAR(15) = (SELECT Telefono from deleted)

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @Descripcion = 'UPDATE en la tabla Hospitales Datos nuevos: ID: '+CAST(@HospitalID as varchar)
		+' Nombre: '+@Nombre + ' Direccion: '+@Direccion + ' Telefono: '+@Telefono + 'Datos viejos ID: '+CAST(@HospitalIDOld as varchar)
		+' Nombre: '+@NombreOld + ' Direccion: '+@DireccionOld + ' Telefono: '+@TelefonoOld ;
    END
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
        SET @Descripcion = 'INSERT en la tabla Hospitales  Datos nuevos: ID: '+CAST(@HospitalID as varchar)
		+' Nombre: '+@Nombre + ' Direccion: '+@Direccion + ' Telefono: '+@Telefono;
    END
    ELSE
    BEGIN
        SET @Descripcion = 'DELETE en la tabla Hospitales Datos viejos ID: '+CAST(@HospitalIDOld as varchar)
		+' Nombre: '+@NombreOld + ' Direccion: '+@DireccionOld + ' Telefono: '+@TelefonoOld;
    END

    Exec sp_crear_bitacora @Descripcion;
END;
go
-- Procedimientos

CREATE PROCEDURE sp_regsitro_hospital
    @Nombre NVARCHAR(100),
    @Direccion NVARCHAR(200),
    @Telefono NVARCHAR(15)
AS
BEGIN
	
	BEGIN TRANSACTION

		INSERT INTO Hospitales (Nombre, Direccion, Telefono)
		VALUES (@Nombre, @Direccion, @Telefono);
    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
  END;
GO

CREATE PROCEDURE sp_actualizar_hospital
    @HospitalID INT,
    @Nombre NVARCHAR(100),
    @Direccion NVARCHAR(200),
    @Telefono NVARCHAR(15)
AS
BEGIN
	BEGIN TRANSACTION
		UPDATE Hospitales
		SET Nombre = @Nombre, Direccion = @Direccion, Telefono = @Telefono
		WHERE HospitalID = @HospitalID;
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;    
END;
GO

CREATE PROCEDURE sp_eliminar_hospital
    @HospitalID INT
AS
BEGIN
	BEGIN TRANSACTION
		UPDATE Hospitales
		SET Activo = 0
		WHERE HospitalID = @HospitalID;
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END
	COMMIT;   
END;
GO