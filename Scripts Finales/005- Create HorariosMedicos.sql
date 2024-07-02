USE GestionCitasExpedientes;
GO

CREATE TABLE HorariosMedicos(
HorarioID INT PRIMARY KEY IDENTITY(1,1),
MedicoID INT FOREIGN KEY REFERENCES Medicos(MedicoID),
DiaSemana VARCHAR(1) NOT NULL CHECK(DiaSemana in('L','K','M','J','V','S','D')),
Hora_Inicio TIME NOT NULL,
Hora_Final TIME	NOT NULL
);
go

-- Triggers

CREATE TRIGGER trg_Bitacora_HorariosMedicos
ON HorariosMedicos
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Descripcion NVARCHAR(MAX);
	--Variables datos nuevos
	DECLARE @HorarioIDD INT = (SELECT MedicoID from inserted)
	DECLARE @MedicoID INT = (SELECT MedicoID from inserted)
	DECLARE @DiaSemana VARCHAR(1) = (SELECT DiaSemana from inserted)
	DECLARE @Hora_Inicio VARCHAR(100) = cast((SELECT Hora_Inicio from inserted)as varchar)
	DECLARE @Hora_Final VARCHAR(100) = cast((SELECT Hora_Final from inserted)as varchar)

	--Variables datos Viejos
	DECLARE @HorarioIDD_Old INT = (SELECT MedicoID from deleted)
	DECLARE @MedicoID_Old INT = (SELECT MedicoID from deleted)
	DECLARE @DiaSemana_Old VARCHAR(1) = (SELECT DiaSemana from deleted)
	DECLARE @Hora_Inicio_Old VARCHAR(100) = cast((SELECT Hora_Inicio from deleted)as varchar)
	DECLARE @Hora_Final_Old VARCHAR(100) = cast((SELECT @Hora_Final from deleted)as varchar)

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @Descripcion = 'UPDATE en la tabla HorariosMedicos Datos nuevos: ID Medico: '+CAST(@MedicoID as varchar)
		+' ID Horario: '+CAST(@HorarioIDD as varchar) + ' DiaSemana : '+@DiaSemana + ' Hora Inicio: '+@Hora_Inicio +' Hora Final: '+@Hora_Final+ 'Datos viejos ID Medico: '+CAST(@MedicoID_Old as varchar)
		+' ID Horario: '+CAST(@HorarioIDD_Old as varchar) + ' DiaSemana : '+@DiaSemana_Old + ' Hora Inicio: '+@Hora_Inicio_Old +' Hora Final: '+@Hora_Final_Old ;
    END
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
        SET @Descripcion = 'INSERT en la tabla HorariosMedicos Datos nuevos: ID Medico: '+CAST(@MedicoID as varchar)
		+' ID Horario: '+CAST(@HorarioIDD as varchar) + ' DiaSemana : '+@DiaSemana + ' Hora Inicio: '+@Hora_Inicio +' Hora Final: '+@Hora_Final;
    END
    ELSE
    BEGIN
        SET @Descripcion = 'DELETE en la tabla HorariosMedicos Datos nuevos: ID Medico: '+CAST(@MedicoID as varchar)
		+' ID Horario: '+CAST(@HorarioIDD as varchar) + ' DiaSemana : '+@DiaSemana + ' Hora Inicio: '+@Hora_Inicio +' Hora Final: '+@Hora_Final+ 'Datos viejos ID Medico: '+CAST(@MedicoID_Old as varchar)
		+' ID Horario: '+CAST(@HorarioIDD_Old as varchar) + ' DiaSemana : '+@DiaSemana_Old + ' Hora Inicio: '+@Hora_Inicio_Old +' Hora Final: '+@Hora_Final_Old ;
    END

    Exec sp_crear_bitacora @Descripcion;
END;
go

--Procedimientos



CREATE PROCEDURE sp_regsitro_HorariosMedicos
	@MedicoID INT,
	@DiaSemana VARCHAR(1),
	@Hora_Inicio TIME,
	@Hora_Final TIME
AS
BEGIN
	
	BEGIN TRANSACTION

	 INSERT INTO HorariosMedicos (MedicoID, DiaSemana,Hora_Inicio,Hora_Final )
     VALUES (@MedicoID, @DiaSemana, @Hora_Inicio, @Hora_Final);

    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
  END;
GO

CREATE PROCEDURE sp_actualizar_HorariosMedicos
    @HorarioID INT,
	@MedicoID INT,
	@DiaSemana VARCHAR(1),
	@Hora_Inicio TIME,
	@Hora_Final TIME
AS
BEGIN
	BEGIN TRANSACTION
	UPDATE HorariosMedicos
    SET Hora_Inicio = @Hora_Inicio,
	Hora_Final = @Hora_Final
    WHERE HorarioID = @HorarioID  AND
	MedicoID = @MedicoID AND
	DiaSemana = @DiaSemana;

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;    
END;
GO

CREATE PROCEDURE sp_eliminar_HorariosMedicos
    @HorarioID INT,
	@MedicoID INT,
	@DiaSemana VARCHAR(1)
AS
BEGIN
	BEGIN TRANSACTION
		DELETE FROM HorariosMedicos
		WHERE  HorarioID = @HorarioID  AND
		MedicoID = @MedicoID AND
		DiaSemana = @DiaSemana;

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END
	COMMIT;   
END;
go