/*	STORED PROCEDURES REPORTES
	Proyecto: Observatorio Compras Publicas del Estado
	Versi�n 1.0
	Creaci�n 1-9-2021
	Ultima Modificaci�n:1-9-2021
	Creador. Alfredo Marrero V�quez
	Kuiper
	Outsourcing para Arkkosoft*/

/*	REQ. 28
	Descripcion:	Generar un reporte que detalle los distintos tipos de figuras 
					contractuales que se realizan en SICOP.
					Enti�ndase por tipo de procedimiento: 
					(esto debe mostrarse en la descripci�n del reporte: 
					�Este es un reporte ejecutivo a nivel macro, sobre las
					adjudicaciones en firme�)
						*	LN: Licitaci�n Nacional P�blica.
						*	LI: Licitaci�n Internacional.
						*	LA: Licitaci�n Abreviada.
						*	PP: Procedimiento por principio.
						*	CD: Contrataci�n Directa.
						*	CE: Contrataci�n Especial.
						*	RE: Remate.
*/

CREATE PROCEDURE REP_Procedimientos
AS
BEGIN
SELECT	procedimiento.tipoProcedimiento as Procedimiento
		, count(procedimiento.idProcedimiento) as Cantidad  
FROM [dbo].[dimProcedimientos] procedimiento 
WHERE procedimiento.estadoProcedimiento = 'Adjudicaci�n en firme' 
GROUP BY procedimiento.tipoProcedimiento
END;

/*	REQ. 29
	Descripcion:Reporte donde muestra los proveedores que han sido invitados
				a cada licitaci�n (proceso) realizada.
					*	N�mero de procedimiento.
					*	Nombre del proveedor.
					*	Cedula del proveedor.
					*	Participo, SI   NO  .
					*	Fecha que se publica el cartel.
					*	Fecha y hora de la apertura.
					*	�Ofert�?,  SI   NO  .
					*	C�digo de producto.
					*	Cantidad de unidades.*/
select* from [dbo].[hechInvitaciones];
select* from [dbo].[dimProcedimientos];
select* from [dbo].[hechOfertas];
select* from [dbo].[hechCarteles];
select* from [dbo].[dimProveedores];
select* from [dbo].[dimRepresentantes];
select* from [dbo].[hechCriteriosEvaluacion];
select* from [dbo].[dimInstituciones];
select* from [dbo].[dimProductos];
select* from [dbo].[dimClasificacionProductos];
select* from [dbo].[dimTiempo];

/*	REQ. 34
	Descripcion: Reporte que facilitar� el conocimiento de todas 
				 las instituciones que utilizan SICOP. 
				 Poder visualizar las instituciones de Compradoras de Gobierno, 
				 Central, Adscritas, desconcentradas o aut�nomas. 
				 La informaci�n que se desea ver:
						�	Nombre de Instituci�n.
						�	Fecha de ingreso a SICOP.
						�	Fecha de primera adjudicaci�n en SICOP.
						�	Cantidad de procedimientos en total.
						�	Cantidad de procedimientos adjudicados. 
						�	Monto total adjudicado. */

SELECT	instituciones.nombreInstitucion
		, instituciones.fechaIngreso
FROM [dbo].[dimInstituciones] instituciones

/*	REQ. 39
	Descripci�n:Este reporte presenta informaci�n relevante del cartel.
				La informaci�n que se desea ver:
				�	Nombre de la instituci�n.
				�	Cedula Instituci�n.
				�	Fecha publicaci�n.
				�	N�mero de procedimiento.
				�	Tipo de procedimiento.
				�	Modalidad de procedimiento.
				�	Clasificaci�n del Objeto (bienes, servicio, obra p�blica)
				�	Monto.
				�	Estado del Cartel.
				�	C�digo de la excepci�n.
				�	Descrip. Excepci�n de la Contrataci�n.  
					Ver Anexo Listado de  Excepciones. */
SELECT	  instituciones.nombreInstitucion as 'Nombre de la institucion'
		, instituciones.cedulaInstitucion as 'C�dula Instituci�n'
		, tiempo.fecha as 'Fecha de Publicaci�n'
		, procedimientos.numeroProcedimiento as 'Numero Procedimiento'
		, procedimientos.tipoProcedimiento as 'Tipo Procedimiento'
		, procedimientos.modalidadProcedimiento as 'Modalidad Procedimiento'
		, clasificacion.descripcionClasificacion as 'Clasificaci�n del Objeto'
FROM
	[dbo].[hechCarteles] carteles 
		LEFT JOIN [dbo].[dimInstituciones] instituciones
			ON carteles.institucion = instituciones.idInstitucion
				LEFT JOIN [dbo].[dimTiempo] tiempo
					ON carteles.fechaPublicacion = tiempo.idTiempo 
						LEFT JOIN [dbo].[dimProcedimientos] procedimientos
							ON carteles.procedimiento = procedimientos.idProcedimiento
								LEFT JOIN [dbo].[dimClasificacionProductos] clasificacion
									ON carteles.clasificacionProducto = clasificacion.idClasificacionProducto
