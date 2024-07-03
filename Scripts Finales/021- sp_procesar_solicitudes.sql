use GestionFarmacia
go

CREATE PROCEDURE sp_procesar_solicitudes
AS
BEGIN
    DECLARE @current_time DATETIME;
    SET @current_time = GETDATE();

    -- Actualizar las solicitudes que tienen más de 10 minutos y están pendientes
    UPDATE SolicitudRecetas
    SET Estado = 'Procesado'
    WHERE estado = 'Pendiente' 
    AND DATEDIFF(MINUTE, FechaRegistro, @current_time) >= 10;
END;