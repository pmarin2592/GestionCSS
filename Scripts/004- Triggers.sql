use GestionCitasExpedientes
go

-- Trigger para registrar movimientos en la bitácora y crear notificaciones
CREATE TRIGGER trg_Bitacora_Pacientes 
ON Pacientes
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Descripcion NVARCHAR(MAX), @PacienteID INT, @MedicoID INT;

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @Descripcion = 'UPDATE en la tabla Pacientes';
        SELECT @PacienteID = inserted.PacienteID FROM inserted;
    END
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
        SET @Descripcion = 'INSERT en la tabla Pacientes';
        SELECT @PacienteID = inserted.PacienteID FROM inserted;
    END
    ELSE
    BEGIN
        SET @Descripcion = 'DELETE en la tabla Pacientes';
        SELECT @PacienteID = deleted.PacienteID FROM deleted;
    END

    INSERT INTO Bitacora (Tabla, Descripcion) VALUES ('Pacientes', @Descripcion);

    -- Aquí se puede insertar la lógica para crear notificaciones si es necesario
    IF @Descripcion = 'INSERT en la tabla Pacientes' OR @Descripcion = 'UPDATE en la tabla Pacientes'
    BEGIN
        SET @MedicoID = (SELECT MedicoID FROM Citas WHERE PacienteID = @PacienteID);
        INSERT INTO Notificaciones (PacienteID, MedicoID, Mensaje) VALUES (@PacienteID, @MedicoID, @Descripcion);
    END
END;

-- Repetir para las otras tablas

-- Trigger para la tabla Medicos
CREATE TRIGGER trg_Bitacora_Medicos 
ON Medicos
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Descripcion NVARCHAR(MAX), @MedicoID INT;

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @Descripcion = 'UPDATE en la tabla Medicos';
        SELECT @MedicoID = inserted.MedicoID FROM inserted;
    END
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
        SET @Descripcion = 'INSERT en la tabla Medicos';
        SELECT @MedicoID = inserted.MedicoID FROM inserted;
    END
    ELSE
    BEGIN
        SET @Descripcion = 'DELETE en la tabla Medicos';
        SELECT @MedicoID = deleted.MedicoID FROM deleted;
    END

    INSERT INTO Bitacora (Tabla, Descripcion) VALUES ('Medicos', @Descripcion);
END;

-- Trigger para la tabla Hospitales
CREATE TRIGGER trg_Bitacora_Hospitales 
ON Hospitales
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Descripcion NVARCHAR(MAX);

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @Descripcion = 'UPDATE en la tabla Hospitales';
    END
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
        SET @Descripcion = 'INSERT en la tabla Hospitales';
    END
    ELSE
    BEGIN
        SET @Descripcion = 'DELETE en la tabla Hospitales';
    END

    INSERT INTO Bitacora (Tabla, Descripcion) VALUES ('Hospitales', @Descripcion);
END;

-- Trigger para la tabla Citas
CREATE TRIGGER trg_Bitacora_Citas 
ON Citas
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Descripcion NVARCHAR(MAX), @PacienteID INT, @MedicoID INT, @FechaHora DATETIME;

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @Descripcion = 'UPDATE en la tabla Citas';
        SELECT @PacienteID = inserted.PacienteID, @MedicoID = inserted.MedicoID, @FechaHora = inserted.FechaHora FROM inserted;
    END
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
        SET @Descripcion = 'INSERT en la tabla Citas';
        SELECT @PacienteID = inserted.PacienteID, @MedicoID = inserted.MedicoID, @FechaHora = inserted.FechaHora FROM inserted;
    END
    ELSE
    BEGIN
        SET @Descripcion = 'DELETE en la tabla Citas';
        SELECT @PacienteID = deleted.PacienteID, @MedicoID = deleted.MedicoID, @FechaHora = deleted.FechaHora FROM deleted;
    END

    INSERT INTO Bitacora (Tabla, Descripcion) VALUES ('Citas', @Descripcion);

    -- Crear notificación para la cita
    IF @Descripcion = 'INSERT en la tabla Citas' OR @Descripcion = 'UPDATE en la tabla Citas'
    BEGIN
        INSERT INTO Notificaciones (PacienteID, MedicoID, Mensaje) VALUES (@PacienteID, @MedicoID, 'Cita agendada/actualizada para el ' + CAST(@FechaHora AS NVARCHAR(20)));
    END
END;

-- Repetir triggers similares para las tablas Expedientes y Recetas
