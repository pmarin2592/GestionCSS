USE	GestionCitasExpedientes
go

-- Tabla de Expedientes
CREATE TABLE Expedientes (
    ExpedienteID INT PRIMARY KEY IDENTITY(1,1),
    PacienteID INT FOREIGN KEY REFERENCES Pacientes(PacienteID),
    Diagnostico VARCHAR(MAX) NOT NULL,
	Padecimientos VARCHAR(MAX) NOT NULL,
    FechaDiagnostico DATE NOT NULL,
    Medicamentos VARCHAR(MAX)
);
go
-- Triggers

CREATE TRIGGER trg_Bitacora_Expedientes
ON Expedientes
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Descripcion NVARCHAR(MAX);
	--Variables datos nuevos
	DECLARE @ExpedienteID INT = (SELECT ExpedienteID from inserted)
	DECLARE @PacienteID INT = (SELECT PacienteID from inserted)
	DECLARE @Diagnostico VARCHAR(MAX) = (SELECT Diagnostico from inserted)
	DECLARE @Padecimientos VARCHAR(MAX) = (SELECT Padecimientos from inserted)
    DECLARE @FechaDiagnostico DATETIME= (SELECT FechaDiagnostico from inserted)
    DECLARE @Medicamentos VARCHAR(MAX)= (SELECT Medicamentos from inserted)

	--Variables datos Viejos
	DECLARE @ExpedienteIDOld INT = (SELECT ExpedienteID from deleted)
	DECLARE @PacienteIDOld INT = (SELECT PacienteID from deleted)
	DECLARE @DiagnosticoOld VARCHAR(MAX) = (SELECT Diagnostico from deleted)
	DECLARE @PadecimientosOld VARCHAR(MAX) = (SELECT Padecimientos from deleted)
    DECLARE @FechaDiagnosticoOld DATETIME= (SELECT FechaDiagnostico from deleted)
    DECLARE @MedicamentosOld VARCHAR(MAX)= (SELECT Medicamentos from deleted)

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @Descripcion = 'UPDATE en la tabla Expedientes Datos nuevos: ID Expediente: '+CAST(@ExpedienteID as varchar)+' ID Paciente: '+CAST(@PacienteID as varchar) + ' Diagnostico : '+ @Diagnostico 
		+ ' Padecimientos: '+@Padecimientos +' FechaDiagnostico: '+@FechaDiagnostico+ 'Medicamentos : ' +@Medicamentos 
		+' Datos viejos ID Expediente: '+CAST(@ExpedienteIDOld as varchar)+' ID Paciente: '+CAST(@PacienteIDOld as varchar) + ' Diagnostico : '+ @DiagnosticoOld 
		+ ' Padecimientos: '+@PadecimientosOld +' FechaDiagnostico: '+@FechaDiagnosticoOld + 'Medicamentos : ' +@MedicamentosOld;
    END
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
        SET @Descripcion = 'INSERT en la tabla Expedientes Datos nuevos: ID Expediente: '+CAST(@ExpedienteID as varchar)+' ID Paciente: '+CAST(@PacienteID as varchar) + ' Diagnostico : '+ @Diagnostico 
		+ ' Padecimientos: '+@Padecimientos +' FechaDiagnostico: '+@FechaDiagnostico+ 'Medicamentos : ' +@Medicamentos 
    END
    ELSE
    BEGIN
        SET @Descripcion = 'DELETE en la tabla Expedientes Datos nuevos: ID Expediente: '+CAST(@ExpedienteID as varchar)+' ID Paciente: '+CAST(@PacienteID as varchar) + ' Diagnostico : '+ @Diagnostico 
		+ ' Padecimientos: '+@Padecimientos +' FechaDiagnostico: '+@FechaDiagnostico+ 'Medicamentos : ' +@Medicamentos 
		+' Datos viejos ID Expediente: '+CAST(@ExpedienteIDOld as varchar)+' ID Paciente: '+CAST(@PacienteIDOld as varchar) + ' Diagnostico : '+ @DiagnosticoOld 
		+ ' Padecimientos: '+@PadecimientosOld +' FechaDiagnostico: '+@FechaDiagnosticoOld + 'Medicamentos : ' +@MedicamentosOld;
    END

    Exec sp_crear_bitacora @Descripcion;
END;
go

-- Procedimientos para la tabla Expedientes
CREATE PROCEDURE sp_Insertar_Expediente
    @PacienteID INT,
    @Diagnostico VARCHAR(MAX),
    @FechaDiagnostico DATE,
	@Padecimientos VARCHAR(MAX),
    @Medicamentos VARCHAR(MAX),
	@Error VARCHAR(MAX)
AS
BEGIN

 BEGIN TRANSACTION

  -- Verificar que el paciente este conectado
        IF EXISTS (
            SELECT 1
            FROM Expedientes
            WHERE PacienteID=@PacienteID
        )
        BEGIN
			declare @ID int = (SELECT ExpedienteID
            FROM Expedientes
            WHERE PacienteID=@PacienteID)
			SET @Error = 'El paciente ya cuenta con expediente, el numero es '+cast(@ID as varchar);
            ROLLBACK TRANSACTION;
            RETURN;
        END

    INSERT INTO Expedientes (PacienteID, Diagnostico, Padecimientos, FechaDiagnostico, Medicamentos)
    VALUES (@PacienteID, @Diagnostico, @Padecimientos, @FechaDiagnostico, @Medicamentos);
    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
    
END;
GO

CREATE PROCEDURE sp_Actualizar_Expediente
    @ExpedienteID INT,
    @PacienteID INT,
    @Diagnostico VARCHAR(MAX),
	@Padecimientos VARCHAR(MAX),
    @FechaDiagnostico DATE,
    @Medicamentos VARCHAR(MAX)
AS
BEGIN
	BEGIN TRANSACTION

      UPDATE Expedientes
		SET PacienteID = @PacienteID, Diagnostico = @Diagnostico, FechaDiagnostico = @FechaDiagnostico, Medicamentos = @Medicamentos, Padecimientos = @Padecimientos
		WHERE ExpedienteID = @ExpedienteID;   
    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;

END;
GO

CREATE PROCEDURE sp_Eliminar_Expediente
    @ExpedienteID INT
AS
BEGIN
    
BEGIN TRANSACTION

    DELETE FROM Expedientes
    WHERE ExpedienteID = @ExpedienteID;
    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;    
    
END;
GO