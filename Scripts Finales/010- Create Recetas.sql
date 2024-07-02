use GestionCitasExpedientes
go
-- Tabla de Recetas
CREATE TABLE Recetas (
    RecetaID INT PRIMARY KEY IDENTITY(1,1),
    CitaID INT FOREIGN KEY REFERENCES Citas(CitaID),
    Medicamentos VARCHAR(MAX) NOT NULL,
    Estado VARCHAR(20) NOT NULL,
    FechaRegistro DATETIME NOT NULL
);
go
-- Triggers

CREATE TRIGGER trg_Bitacora_Recetas
ON Recetas
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Descripcion NVARCHAR(MAX);
	--Variables datos nuevos
	DECLARE @RecetaID INT = (SELECT RecetaID from inserted)
	DECLARE @CitaID INT = (SELECT CitaID from inserted)
	DECLARE @Medicamentos VARCHAR(MAX) = (SELECT Medicamentos from inserted)
	DECLARE @Estado VARCHAR(MAX) = (SELECT Estado from inserted)
    DECLARE @FechaRegistro DATETIME= (SELECT FechaRegistro from inserted)

	--Variables datos Viejos
	DECLARE @RecetaIDOld INT = (SELECT RecetaID from inserted)
	DECLARE @CitaIDOld INT = (SELECT CitaID from inserted)
	DECLARE @MedicamentosOld VARCHAR(MAX) = (SELECT Medicamentos from inserted)
	DECLARE @EstadoOld VARCHAR(MAX) = (SELECT Estado from inserted)
    DECLARE @FechaRegistroOld DATETIME= (SELECT FechaRegistro from inserted)

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @Descripcion = 'UPDATE en la tabla Recetas Datos nuevos: ID Receta: '+CAST(@RecetaID as varchar)+' ID Cita: '+CAST(@CitaID as varchar) + ' Medicamentos : '+ @Medicamentos 
		+ ' Estado: '+@Estado +' Fecha Registro: '+@FechaRegistro
		+' Datos viejos ID Receta: '+CAST(@RecetaIDOld as varchar)+' ID Cita: '+CAST(@CitaIDOld as varchar) + ' Medicamentos : '+ @MedicamentosOld 
		+ ' Estado: '+@EstadoOld +' Fecha Registro: '+@FechaRegistroOld;
    END
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
        SET @Descripcion = 'INSERT en la tabla Recetas Datos nuevos: ID Receta: '+CAST(@RecetaID as varchar)+' ID Cita: '+CAST(@CitaID as varchar) + ' Medicamentos : '+ @Medicamentos 
		+ ' Estado: '+@Estado +' Fecha Registro: '+@FechaRegistro
    END
    ELSE
    BEGIN
       SET @Descripcion = 'Delete  en la tabla Recetas Datos nuevos: ID Receta: '+CAST(@RecetaID as varchar)+' ID Cita: '+CAST(@CitaID as varchar) + ' Medicamentos : '+ @Medicamentos 
		+ ' Estado: '+@Estado +' Fecha Registro: '+@FechaRegistro
		+' Datos viejos ID Receta: '+CAST(@RecetaIDOld as varchar)+' ID Cita: '+CAST(@CitaIDOld as varchar) + ' Medicamentos : '+ @MedicamentosOld 
		+ ' Estado: '+@EstadoOld +' Fecha Registro: '+@FechaRegistroOld;
    END

    Exec sp_crear_bitacora @Descripcion;
END;
go

-- Procedimientos para la tabla Recetas
CREATE PROCEDURE sp_Insertar_Receta
    @CitaID INT,
    @Medicamentos NVARCHAR(MAX),
    @Estado NVARCHAR(20),
    @FechaRegistro DATETIME
AS
BEGIN


   BEGIN TRANSACTION

	INSERT INTO Recetas (CitaID, Medicamentos, Estado, FechaRegistro)
    VALUES (@CitaID, @Medicamentos, @Estado, @FechaRegistro);
    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
    
    
END;
GO

CREATE PROCEDURE sp_Actualizar_Receta
    @RecetaID INT,
    @CitaID INT,
    @Medicamentos NVARCHAR(MAX),
    @Estado NVARCHAR(20),
    @FechaRegistro DATETIME
AS
BEGIN
   
    
     BEGIN TRANSACTION

	UPDATE Recetas
    SET CitaID = @CitaID, Medicamentos = @Medicamentos, Estado = @Estado, FechaRegistro = @FechaRegistro
    WHERE RecetaID = @RecetaID;
    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
END;
GO

CREATE PROCEDURE sp_Eliminar_Receta
    @RecetaID INT
AS
BEGIN
    

	 BEGIN TRANSACTION


	UPDATE Recetas
    SET Estado = 'Anulado'
    WHERE RecetaID = @RecetaID;
    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
    
   
END;
GO
