USE GestionCitasExpedientes
go

-- Tabla de Citas
CREATE TABLE Citas (
    CitaID INT PRIMARY KEY IDENTITY(1,1),
    PacienteID INT FOREIGN KEY REFERENCES Pacientes(PacienteID),
    MedicoID INT FOREIGN KEY REFERENCES Medicos(MedicoID),
    FechaHora DATETIME NOT NULL,
    Estado VARCHAR(20) NOT NULL default 'Registrada'
);
go

-- Triggers

CREATE TRIGGER trg_Bitacora_Citas
ON Citas
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Descripcion NVARCHAR(MAX);
	--Variables datos nuevos
	DECLARE @CitaID INT = (SELECT CitaID from inserted)
	DECLARE @PacienteID INT = (SELECT PacienteID from inserted)
	DECLARE @MedicoID INT = (SELECT MedicoID from inserted)
	DECLARE @FechaHora DATETIME = (SELECT FechaHora from inserted)
    DECLARE @Estado VARCHAR(20)= (SELECT Estado from inserted)
  
	--Variables datos Viejos
	DECLARE @CitaID_Old INT = (SELECT CitaID from deleted)
	DECLARE @PacienteID_Old INT = (SELECT PacienteID from deleted)
	DECLARE @MedicoID_Old INT = (SELECT MedicoID from deleted)
	DECLARE @FechaHora_Old DATETIME = (SELECT FechaHora from deleted)
    DECLARE @Estado_Old VARCHAR(20)= (SELECT Estado from deleted)

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @Descripcion = 'UPDATE en la tabla Citas Datos nuevos: ID Cita: '+CAST(@CitaID as varchar)+' ID Paciente: '+CAST(@PacienteID as varchar) + ' ID Medico : '+CAST(@MedicoID AS varchar) 
		+ ' FechaHora: '+@FechaHora +' Estado: '+@Estado+  
		+' Datos viejos ID Cita: '+CAST(@CitaID as varchar)+' ID Paciente: '+CAST(@PacienteID as varchar) + ' ID Medico : '+CAST(@MedicoID AS varchar) 
		+ ' FechaHora: '+@FechaHora +' Estado: '+@Estado;
    END
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
        SET @Descripcion = 'INSERT en la tabla Citas Datos nuevos: ID Cita: '+CAST(@CitaID as varchar)+' ID Paciente: '+CAST(@PacienteID as varchar) + ' ID Medico : '+CAST(@MedicoID AS varchar) 
		+ ' FechaHora: '+@FechaHora +' Estado: '+@Estado
    END
    ELSE
    BEGIN
        SET @Descripcion = 'DELETE en la tabla Citas Datos nuevos: ID Cita: '+CAST(@CitaID as varchar)+' ID Paciente: '+CAST(@PacienteID as varchar) + ' ID Medico : '+CAST(@MedicoID AS varchar) 
		+ ' FechaHora: '+@FechaHora +' Estado: '+@Estado+  
		+' Datos viejos ID Cita: '+CAST(@CitaID as varchar)+' ID Paciente: '+CAST(@PacienteID as varchar) + ' ID Medico : '+CAST(@MedicoID AS varchar) 
		+ ' FechaHora: '+@FechaHora +' Estado: '+@Estado;
    END

    Exec sp_crear_bitacora @Descripcion;
END;
go

-- Procedimientos

CREATE PROCEDURE sp_Insertar_Cita
    @PacienteID INT,
    @MedicoID INT,
    @FechaHora DATETIME,
	@Error varchar(200) out
AS
BEGIN
   DECLARE @DiaSemana varchar(1) = LEFT(DateName(dw,@FechaHora),1);
   DECLARE @Hora time = cast(@FechaHora as time);
   DECLARE @Asunto VARCHAR(20) = 'Notificacion de registro de cita';
   DECLARE @Cuerpo VARCHAR(MAX);
   DECLARE @Nombre VARCHAR(100);
   DECLARE @Correo VARCHAR(100);
   DECLARE @Medico VARCHAR(100);
   DECLARE @Hospital VARCHAR(100);
   DECLARE @CorreoMedico Varchar(100);

      -- Verificar que el paciente este conectado
        IF NOT EXISTS (
            SELECT 1
            FROM Pacientes
            WHERE PacienteID=@PacienteID and Conectado = 1
        )
        BEGIN
			SET @Error = 'El paciente no esta conectado';
            ROLLBACK TRANSACTION;
            RETURN;
        END

    -- Verificar disponibilidad del médico en su horario de trabajo
        IF NOT EXISTS (
            SELECT 1
            FROM HorariosMedicos
            WHERE MedicoID = @MedicoID
              AND DiaSemana = @DiaSemana
              AND @Hora BETWEEN Hora_Inicio AND Hora_Final
        )
        BEGIN
			SET @Error = 'El médico no está disponible en ese horario de trabajo';
            ROLLBACK TRANSACTION;
            RETURN;
        END

    -- Verificar si el médico ya tiene una cita en el mismo horario
		IF EXISTS (
			SELECT 1
			FROM Citas
			WHERE MedicoID = @MedicoID
				AND FechaHora = @FechaHora
		)
		BEGIN
			SET @Error = 'El médico ya tiene una cita agendada en ese horario';
			ROLLBACK TRANSACTION;
			RETURN;
		END

		 BEGIN TRANSACTION

			 -- Insertar la cita
			INSERT INTO Citas (MedicoID, PacienteID, FechaHora)
			VALUES (@MedicoID, @PacienteID, @FechaHora);

			set @Nombre = (select Nombre + Apellidos from Pacientes where PacienteID = @PacienteID);
			set @Correo  = (select Correo from Pacientes where PacienteID = @PacienteID);
			set @Medico = (select Nombre from Medicos where MedicoID = @MedicoID);
			set @Hospital = (select h.Nombre from Hospitales h inner join Medicos m on m.HospitalID = h.HospitalID and m.MedicoID = @MedicoID);
			set @CorreoMedico = (select Correo from Medicos where MedicoID = @MedicoID);

			set @cuerpo = '<html><header></header><body><h4>Registro de cita,</h4><br>'+
			'<b><h2>'+@Nombre+'</h2></b>'+
			'<p>Datos de Cita:<ul>'+
            '<li>Medico: </li><b>'+@Medico+'</b>'+
            '<li>Hospital: </li><b>'+@Hospital+'</b>'+
            '<li>Fecha y Hora: </li><b>'+@FechaHora+'</b>'+
			'</ul></p><p>Debe presentarse 30 minutos antes de la hora de la cita, en caso de alguna duda favor enviar un correo</p></body></html>'

			Exec sp_registro_notificacion @Asunto, @Cuerpo, @Correo

			set @cuerpo = '<html><header></header><body><h4>Registro de cita,</h4><br>'+
			'<b><h2>'+@Medico+'</h2></b>'+
			'<p>Datos de Cita del paciente:<ul>'+
            '<li>Nombre: </li><b>'+@Nombre+'</b>'+
            '<li>Hospital: </li><b>'+@Hospital+'</b>'+
            '<li>Fecha y Hora: </li><b>'+@FechaHora+'</b>'+
			'</ul></p><p>Se adjunta los datos de la cita, en caso de anularla favor proceder desde el sistema</p></body></html>'

			Exec sp_registro_notificacion @Asunto, @Cuerpo, @CorreoMedico

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK;
		END

		COMMIT;
		
END;
GO

CREATE PROCEDURE sp_actualizar_cita
    @CitaID INT,
	@Estado VARCHAR(20)
AS
BEGIN
	
   BEGIN TRANSACTION

	UPDATE Citas
    SET Estado = @Estado
    WHERE CitaID = @CitaID;
    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
  
END;
GO

CREATE PROCEDURE sp_DeleteCita
    @CitaID INT
AS
BEGIN
    
    
	 BEGIN TRANSACTION

	 UPDATE Citas
    SET Estado = 'Cancelada'
    WHERE CitaID = @CitaID;
    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
END;
GO

