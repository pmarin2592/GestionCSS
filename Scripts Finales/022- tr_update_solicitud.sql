use GestionFarmacia
go

CREATE TRIGGER tr_update_solicitud
ON SolicitudRecetas
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Estado)
    BEGIN
        
       
        DECLARE @estado VARCHAR(20);
		DECLARE @RecetaID int = (Select RecetaID from inserted)
		DECLARE @Asunto VARCHAR(20) = 'Notificacion de prcesamiento de receta en farmacia';
		DECLARE @Cuerpo VARCHAR(MAX);
		DECLARE @Nombre VARCHAR(100) =(select m.Nombre
										from GestionCitasExpedientes.dbo.Pacientes m
										inner join GestionCitasExpedientes.dbo.Recetas r on r.RecetaID  = @RecetaID
										inner join GestionCitasExpedientes.dbo.Citas c on c.CitaID =  r.CitaID and c.PacienteID = m.PacienteID);
		DECLARE @Correo VARCHAR(100) = (select m.Correo
										from GestionCitasExpedientes.dbo.Pacientes m
										inner join GestionCitasExpedientes.dbo.Recetas r on r.RecetaID  = @RecetaID
										inner join GestionCitasExpedientes.dbo.Citas c on c.CitaID =  r.CitaID and c.PacienteID = m.PacienteID);
		DECLARE @Medico VARCHAR(100) = (select m.Nombre
												from GestionCitasExpedientes.dbo.Medicos m
												where 
												m.MedicoID = (Select MedicoID from inserted));
		DECLARE @Hospital VARCHAR(100) = (select h.Nombre
											from  GestionCitasExpedientes.dbo.Hospitales h
											where h.HospitalID =(Select HospitalEntregaID from inserted));
		DECLARE @CorreoMedico Varchar(100)= (select m.Correo
												from GestionCitasExpedientes.dbo.Medicos m
												where 
												m.MedicoID = (Select MedicoID from inserted));
        
        SELECT  @estado = inserted.estado
        FROM inserted;

        IF @estado = 'Procesado'
        BEGIN

            set @cuerpo = '<html><header></header><body><h4>Estimado Paciente. ,</h4><br>'+
			'<b><h2>'+@Nombre+'</h2></b>'+
			'<p>Su solicitud ha sido procesada. Puede retirar sus medicamentos<ul>'+
			'<li>Receta #: </li><b>'+@RecetaID+'</b>'+
            '<li>Medico: </li><b>'+@Medico+'</b>'+
            '<li>Hospital Entrega: </li><b>'+@Hospital+'</b>'+
			'</ul></p><p>Se finaliza proceso de cita</p></body></html>'

			Exec sp_registro_notificacion @Asunto, @Cuerpo, @CorreoMedico 
        END
    END
END;