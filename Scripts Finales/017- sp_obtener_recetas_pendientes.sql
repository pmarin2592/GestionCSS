USE GestionCitasExpedientes
go

--pprocedimiento 
create PROCEDURE sp_obtener_recetas_pendientes

AS
BEGIN
	select r.RecetaID, r.Medicamentos,c.MedicoID, h.HospitalID HospitalReceta, h.HospitalID HospitalEntrega
	from Recetas r
	inner join Citas c on c.CitaID = r.CitaID
	inner join Medicos m on m.MedicoID = c.MedicoID
	inner join Hospitales h on h.HospitalID = m.HospitalID
	where r.Estado = 'Pendiente' 

END
GO
