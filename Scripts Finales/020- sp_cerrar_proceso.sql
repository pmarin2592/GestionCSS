USE [GestionCitasExpedientes]
GO

create PROCEDURE [dbo].[sp_cerrar_proceso]
    @RecetaID INT
AS
BEGIN
   
    Declare @CitaID int = (select c.CitaID from Citas c inner join Recetas r on r.CitaID = c.CitaID and r.RecetaID = @RecetaID)
	DECLARE @Asunto VARCHAR(20) = 'Notificacion de registro de receta en farmacia';
	DECLARE @Cuerpo VARCHAR(MAX);
	DECLARE @Nombre VARCHAR(100) =(select m.Nombre
									from Pacientes m
									inner join Recetas r on r.RecetaID  = @RecetaID
									inner join Citas c on c.CitaID =  r.CitaID and c.PacienteID = m.PacienteID);
	DECLARE @Correo VARCHAR(100) = (select m.Correo
									from Pacientes m
									inner join Recetas r on r.RecetaID  = @RecetaID
									inner join Citas c on c.CitaID =  r.CitaID and c.PacienteID = m.PacienteID);
	DECLARE @Medico VARCHAR(100) = (select m.Nombre
											from Medicos m
											inner join Recetas r on r.RecetaID  = @RecetaID
											inner join Citas c on c.CitaID =  r.CitaID and c.MedicoID = m.MedicoID);
	DECLARE @Hospital VARCHAR(100) = (select h.Nombre
										from Hospitales h
										inner join Recetas r on r.RecetaID  = @RecetaID
										inner join Medicos m on m.HospitalID =h.HospitalID
										inner join Citas c on c.CitaID =  r.CitaID and c.MedicoID = m.MedicoID);
	DECLARE @CorreoMedico Varchar(100)= (select m.Correo
											from Medicos m
											inner join Recetas r on r.RecetaID  = @RecetaID
											inner join Citas c on c.CitaID =  r.CitaID and c.MedicoID = m.MedicoID);

     BEGIN TRANSACTION
	
	EXEC sp_Actualizar_Estado_Receta @RecetaID;
	EXEC sp_actualizar_cita @CitaID, 'Finalizada';

	set @cuerpo = '<html><header></header><body><h4>Estimado Doc. ,</h4><br>'+
			'<b><h2>'+@Medico+'</h2></b>'+
			'<p>Se le informa que se registro en farmacia la siguiente receta:<ul>'+
			'<li>Receta #: </li><b>'+@RecetaID+'</b>'+
            '<li>Nombre del Paciente: </li><b>'+@Nombre+'</b>'+
            '<li>Hospital: </li><b>'+@Hospital+'</b>'+
			'</ul></p><p>Se finaliza proceso de cita</p></body></html>'

			Exec sp_registro_notificacion @Asunto, @Cuerpo, @CorreoMedico 
    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
END;
