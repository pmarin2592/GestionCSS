USE GestionCitasExpedientes
GO

-- Tabla de Pacientes
CREATE TABLE Pacientes (
    PacienteID INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100) NOT NULL,
    Apellidos VARCHAR(100) NOT NULL,
    Edad INT NOT NULL,
    Altura DECIMAL(5,2) NOT NULL,
    Peso DECIMAL(5,2) NOT NULL,
    Telefono VARCHAR(15) NOT NULL,
    Correo VARCHAR(100) NOT NULL unique,
	Clave Varchar(10) not null,
	Activo bit not null default(1),
	Conectado bit not null default(0)
);
GO

--
-- Triggers

CREATE TRIGGER trg_Bitacora_Pacientes
ON Pacientes
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Descripcion NVARCHAR(MAX);
	--Variables datos nuevos
	DECLARE @PacienteID INT = (SELECT PacienteID from inserted)
	DECLARE @Nombre VARCHAR(100) = (SELECT Nombre from inserted)
	DECLARE @Apellidos VARCHAR(1) = (SELECT Apellidos from inserted)
	DECLARE @Edad INT = (SELECT Edad from inserted)
	DECLARE @Altura DECIMAL(5,2) = (SELECT Altura from inserted)
	DECLARE @Peso DECIMAL(5,2)= (SELECT Peso from inserted)
    DECLARE @Telefono VARCHAR(15)= (SELECT Telefono from inserted)
    DECLARE @Correo VARCHAR(100) = (SELECT Correo from inserted)
	DECLARE @Clave Varchar(10)= (SELECT Clave from inserted)
	--Variables datos Viejos
	DECLARE @PacienteID_Old INT = (SELECT PacienteID from deleted)
	DECLARE @Nombre_Old VARCHAR(100) = (SELECT Nombre from deleted)
	DECLARE @Apellidos_Old VARCHAR(1) = (SELECT Apellidos from deleted)
	DECLARE @Edad_Old INT = (SELECT Edad from deleted)
	DECLARE @Altura_Old DECIMAL(5,2) = (SELECT Altura from deleted)
	DECLARE @Peso_Old DECIMAL(5,2)= (SELECT Peso from deleted)
    DECLARE @Telefono_Old VARCHAR(15)= (SELECT Telefono from deleted)
    DECLARE @Correo_Old VARCHAR(100) = (SELECT Correo from deleted)
	DECLARE @Clave_Old Varchar(10)= (SELECT Clave from deleted)

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @Descripcion = 'UPDATE en la tabla Pacientes Datos nuevos: ID paciente: '+CAST(@PacienteID as varchar)
		+' Nombre: '+CAST(@Nombre as varchar) + ' Apellidos : '+@Apellidos + ' Edad: '+@Edad +' Altura: '+@Altura+ ' Peso: '+ @Peso+ ' Telefono: '+@Telefono+' Correo: '+@Correo+' Clave: ' +@Clave 
		+' Datos viejos ID paciente: '+CAST(@PacienteID_Old as varchar)
		+' Nombre: '+CAST(@Nombre_Old as varchar) + ' Apellidos : '+@Apellidos_Old + ' Edad: '+@Edad_Old +' Altura: '+@Altura_Old+ ' Peso: '+ @Peso_Old+ ' Telefono: '+@Telefono_Old+' Correo: '+@Correo_Old+' Clave: ' +@Clave_Old;
    END
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
        SET @Descripcion = 'INSERT en la tabla Pacientes Datos nuevos: ID paciente: '+CAST(@PacienteID as varchar)
		+' Nombre: '+CAST(@Nombre as varchar) + ' Apellidos : '+@Apellidos + ' Edad: '+@Edad +' Altura: '+@Altura+ ' Peso: '+ @Peso+ ' Telefono: '+@Telefono+' Correo: '+@Correo+' Clave: ' +@Clave 
    END
    ELSE
    BEGIN
        SET @Descripcion = 'DELETE en la tabla Pacientes Datos nuevos:ID paciente: '+CAST(@PacienteID as varchar)
		+' Nombre: '+CAST(@Nombre as varchar) + ' Apellidos : '+@Apellidos + ' Edad: '+@Edad +' Altura: '+@Altura+ ' Peso: '+ @Peso+ ' Telefono: '+@Telefono+' Correo: '+@Correo+' Clave: ' +@Clave 
		+' Datos viejos ID paciente: '+CAST(@PacienteID_Old as varchar)
		+' Nombre: '+CAST(@Nombre_Old as varchar) + ' Apellidos : '+@Apellidos_Old + ' Edad: '+@Edad_Old +' Altura: '+@Altura_Old+ ' Peso: '+ @Peso_Old+ ' Telefono: '+@Telefono_Old+' Correo: '+@Correo_Old+' Clave: ' +@Clave_Old;
    END

    Exec sp_crear_bitacora @Descripcion;
END;
go

-- Procedimientos

-- Procedimientos para la tabla Pacientes
CREATE PROCEDURE sp_insertar_Paciente
    @Nombre VARCHAR(100),
    @Apellidos VARCHAR(100),
    @Edad INT,
    @Altura DECIMAL(5,2),
    @Peso DECIMAL(5,2),
    @Telefono VARCHAR(15),
    @Correo VARCHAR(100)
AS
BEGIN
   
    BEGIN TRANSACTION

	  INSERT INTO Pacientes (Nombre, Apellidos, Edad, Altura, Peso, Telefono, Correo)
      VALUES (@Nombre, @Apellidos, @Edad, @Altura, @Peso, @Telefono, @Correo);
    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
END;
GO

CREATE PROCEDURE sp_Actualizar_Paciente
    @PacienteID INT,
    @Nombre NVARCHAR(100),
    @Apellidos NVARCHAR(100),
    @Edad INT,
    @Altura DECIMAL(5,2),
    @Peso DECIMAL(5,2),
    @Telefono NVARCHAR(15),
    @Correo NVARCHAR(100),
	@Activo int
AS
BEGIN
    
	 BEGIN TRANSACTION

	 UPDATE Pacientes
     SET Nombre = @Nombre, Apellidos = @Apellidos, Edad = @Edad, Altura = @Altura, Peso = @Peso, Telefono = @Telefono, Correo = @Correo, Activo=@Activo
     WHERE PacienteID = @PacienteID;
    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
   
END;
GO

CREATE PROCEDURE sp_Eliminar_Paciente
    @PacienteID INT
AS
BEGIN
   
     BEGIN TRANSACTION

	    UPDATE Pacientes
		SET Activo=0
		WHERE PacienteID = @PacienteID;
    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
   
    
END;
GO

CREATE PROCEDURE sp_Conectar_Paciente
    @Correo VARCHAR(100),
	@Clave VARCHAR(10),
	@Error VARCHAR(MAX) OUT
AS
BEGIN

 --Valida si existe paciente 
		IF NOT EXISTS (
            SELECT 1
            FROM Pacientes
            WHERE Correo = @Correo
        )
        BEGIN
			SET @Error = 'El paciente no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END
	
   --Valida si existe paciente 
		IF NOT EXISTS (
            SELECT 1
            FROM Pacientes
            WHERE Correo = @Correo AND  Activo = 1
        )
        BEGIN
			SET @Error = 'El paciente no esta activo';
            ROLLBACK TRANSACTION;
            RETURN;
        END

	--Valida si existe paciente 
		IF NOT EXISTS (
            SELECT 1
            FROM Pacientes
            WHERE Correo = @Correo AND Clave = @Clave AND Activo = 1
        )
        BEGIN
			SET @Error = 'Correo o clave incorrecta';
            ROLLBACK TRANSACTION;
            RETURN;
        END
     BEGIN TRANSACTION

	    UPDATE Pacientes
		SET Conectado = 1
		WHERE Correo = @Correo;
    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
   
    
END;
GO

CREATE PROCEDURE sp_Desconectar_Paciente
    @Correo VARCHAR(100)
AS
BEGIN
     BEGIN TRANSACTION

	    UPDATE Pacientes
		SET Conectado = 0
		WHERE Correo = @Correo;
    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
   
    
END;
GO