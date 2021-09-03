/*	STORED PROCEDURES REPORTES
	Proyecto: Observatorio Compras Publicas del Estado
	Versión 1.0
	Creación 1-9-2021
	Ultima Modificación:1-9-2021
	Creador. Alfredo Marrero Víquez
	Kuiper
	Outsourcing para Arkkosoft*/

/*	REQ. 28
	Descripcion:	Generar un reporte que detalle los distintos tipos de figuras 
					contractuales que se realizan en SICOP.
					Entiéndase por tipo de procedimiento: 
					(esto debe mostrarse en la descripción del reporte: 
					“Este es un reporte ejecutivo a nivel macro, sobre las
					adjudicaciones en firme”)
						*	LN: Licitación Nacional Pública.
						*	LI: Licitación Internacional.
						*	LA: Licitación Abreviada.
						*	PP: Procedimiento por principio.
						*	CD: Contratación Directa.
						*	CE: Contratación Especial.
						*	RE: Remate.
*/

CREATE PROCEDURE REP_Procedimientos
AS
BEGIN
SELECT	procedimiento.tipoProcedimiento as Procedimiento
		, count(procedimiento.idProcedimiento) as Cantidad  
FROM [dbo].[dimProcedimientos] procedimiento 
WHERE procedimiento.estadoProcedimiento = 'Adjudicación en firme' 
GROUP BY procedimiento.tipoProcedimiento
END;

/*	REQ. 29
	Descripcion:Reporte donde muestra los proveedores que han sido invitados
				a cada licitación (proceso) realizada.
					*	Número de procedimiento.
					*	Nombre del proveedor.
					*	Cedula del proveedor.
					*	Participo, SI   NO  .
					*	Fecha que se publica el cartel.
					*	Fecha y hora de la apertura.
					*	¿Ofertó?,  SI   NO  .
					*	Código de producto.
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
	Descripcion: Reporte que facilitará el conocimiento de todas 
				 las instituciones que utilizan SICOP. 
				 Poder visualizar las instituciones de Compradoras de Gobierno, 
				 Central, Adscritas, desconcentradas o autónomas. 
				 La información que se desea ver:
						•	Nombre de Institución.
						•	Fecha de ingreso a SICOP.
						•	Fecha de primera adjudicación en SICOP.
						•	Cantidad de procedimientos en total.
						•	Cantidad de procedimientos adjudicados. 
						•	Monto total adjudicado. */

SELECT	instituciones.nombreInstitucion
		, instituciones.fechaIngreso
FROM [dbo].[dimInstituciones] instituciones

/*	REQ. 39
	Descripción:Este reporte presenta información relevante del cartel.
				La información que se desea ver:
				•	Nombre de la institución.
				•	Cedula Institución.
				•	Fecha publicación.
				•	Número de procedimiento.
				•	Tipo de procedimiento.
				•	Modalidad de procedimiento.
				•	Clasificación del Objeto (bienes, servicio, obra pública)
				•	Monto.
				•	Estado del Cartel.
				•	Código de la excepción.
				•	Descrip. Excepción de la Contratación.  
					Ver Anexo Listado de  Excepciones. */
SELECT	  instituciones.nombreInstitucion as 'Nombre de la institucion'
		, instituciones.cedulaInstitucion as 'Cédula Institución'
		, tiempo.fecha as 'Fecha de Publicación'
		, procedimientos.numeroProcedimiento as 'Numero Procedimiento'
		, procedimientos.tipoProcedimiento as 'Tipo Procedimiento'
		, procedimientos.modalidadProcedimiento as 'Modalidad Procedimiento'
		, clasificacion.descripcionClasificacion as 'Clasificación del Objeto'
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
