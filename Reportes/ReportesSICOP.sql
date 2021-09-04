/* REQ-28 TIPO DE PROCEDIMIENTOS SICOP
   DESCRIPCION: Generar un reporte que detalle los distintos tipos de figuras 
				contractuales que se realizan en SICOP. Entiéndase por tipo de procedimiento: 
				(esto debe mostrarse en la descripción del reporte: 
				“Este es un reporte ejecutivo a nivel macro, sobre lasadjudicaciones en firme”)
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
GO;
/*REQ-34 INSTITUCIONES QUE UTILIZAN SICOP
  DESCRIPCIÓN: Reporte que facilitará el conocimiento de todas las instituciones que utilizan SICOP. 
			   Poder visualizar las instituciones de Compradoras de Gobierno, 
			   Central, Adscritas, desconcentradas o autónomas. 
			   La información que se desea ver:
						*	Nombre de Institución.
						*	Fecha de ingreso a SICOP.
						*	Fecha de primera adjudicación en SICOP.
						*	Cantidad de procedimientos en total.
						*	Cantidad de procedimientos adjudicados. 
						*	Monto total adjudicado.
*/


CREATE PROCEDURE REP_InstitucionesSICOP
	AS
		BEGIN
			SELECT	instituciones.nombreInstitucion as 'Nombre Institución'
					, instituciones.fechaIngreso as 'Fecha de Ingreso'
					, count(procedimientos.idProcedimiento) as 'Total de Procedimientos'
					,COALESCE(
						SUM(
							CASE 
								WHEN procedimientos.estadoProcedimiento like'Adjudicado' 
									THEN 1 
									ELSE 0 
								END),0) as 'Procedimientos adjudicados'
			FROM 
				[dbo].[hechCarteles] carteles
				INNER JOIN[dbo].[dimInstituciones] instituciones
					ON carteles.institucion = instituciones.idInstitucion
				INNER JOIN [dbo].[dimProcedimientos] procedimientos
					ON carteles.procedimiento=procedimientos.idProcedimiento
			GROUP BY instituciones.nombreInstitucion, instituciones.fechaIngreso 
		END;
GO;
/*REQ-39 INFORMACIÓN RELEVANTE CARTEL
  DESCRIPCIÓN: Este reporte presenta información relevante del cartel.
			   La información que se desea ver:
				*	Nombre de la institución.
				*	Cedula Institución.
				*	Fecha publicación.
				*	Número de procedimiento.
				*	Tipo de procedimiento.
				*	Modalidad de procedimiento.
				*	Clasificación del Objeto (bienes, servicio, obra pública)
				*	Monto.
				*	Estado del Cartel.
				*	Código de la excepción.
				*	Descrip. Excepción de la Contratación.Ver Anexo Listado de  Excepciones.
*/
CREATE PROCEDURE REP_DetallesCartel
	AS
		BEGIN
			SELECT	  instituciones.nombreInstitucion as 'Nombre de la institucion'
					, instituciones.cedulaInstitucion as 'Cédula Institución'
					, tiempo.fecha as 'Fecha de Publicación'
					, procedimientos.numeroProcedimiento as 'Numero Procedimiento'
					, procedimientos.tipoProcedimiento as 'Tipo Procedimiento'
					, procedimientos.modalidadProcedimiento as 'Modalidad Procedimiento'
					, clasificacion.descripcionClasificacion as 'Clasificación del Objeto'
					, carteles.montoReservado as 'Monto'
					, procedimientos.estadoProcedimiento as 'Estado Cartel'
					, procedimientos.codigoExcepcion as 'Código de la Excepción'
					, procedimientos.descripcionExcepcion 'Descripción de la Excepcion'
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
			END;
GO;
/**/

