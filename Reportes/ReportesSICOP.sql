/* REQ-28 TIPO DE PROCEDIMIENTOS SICOP
   DESCRIPCION: Generar un reporte que detalle los distintos tipos de figuras 
				contractuales que se realizan en SICOP. Enti�ndase por tipo de procedimiento: 
				(esto debe mostrarse en la descripci�n del reporte: 
				�Este es un reporte ejecutivo a nivel macro, sobre lasadjudicaciones en firme�)
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
GO;
/*REQ-34 INSTITUCIONES QUE UTILIZAN SICOP
  DESCRIPCI�N: Reporte que facilitar� el conocimiento de todas las instituciones que utilizan SICOP. 
			   Poder visualizar las instituciones de Compradoras de Gobierno, 
			   Central, Adscritas, desconcentradas o aut�nomas. 
			   La informaci�n que se desea ver:
						*	Nombre de Instituci�n.
						*	Fecha de ingreso a SICOP.
						*	Fecha de primera adjudicaci�n en SICOP.
						*	Cantidad de procedimientos en total.
						*	Cantidad de procedimientos adjudicados. 
						*	Monto total adjudicado.
*/


CREATE PROCEDURE REP_InstitucionesSICOP
	AS
		BEGIN
			SELECT	instituciones.nombreInstitucion as 'Nombre Instituci�n'
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
/*REQ-39 INFORMACI�N RELEVANTE CARTEL
  DESCRIPCI�N: Este reporte presenta informaci�n relevante del cartel.
			   La informaci�n que se desea ver:
				*	Nombre de la instituci�n.
				*	Cedula Instituci�n.
				*	Fecha publicaci�n.
				*	N�mero de procedimiento.
				*	Tipo de procedimiento.
				*	Modalidad de procedimiento.
				*	Clasificaci�n del Objeto (bienes, servicio, obra p�blica)
				*	Monto.
				*	Estado del Cartel.
				*	C�digo de la excepci�n.
				*	Descrip. Excepci�n de la Contrataci�n.Ver Anexo Listado de  Excepciones.
*/
CREATE PROCEDURE REP_DetallesCartel
	AS
		BEGIN
			SELECT	  instituciones.nombreInstitucion as 'Nombre de la institucion'
					, instituciones.cedulaInstitucion as 'C�dula Instituci�n'
					, tiempo.fecha as 'Fecha de Publicaci�n'
					, procedimientos.numeroProcedimiento as 'Numero Procedimiento'
					, procedimientos.tipoProcedimiento as 'Tipo Procedimiento'
					, procedimientos.modalidadProcedimiento as 'Modalidad Procedimiento'
					, clasificacion.descripcionClasificacion as 'Clasificaci�n del Objeto'
					, carteles.montoReservado as 'Monto'
					, procedimientos.estadoProcedimiento as 'Estado Cartel'
					, procedimientos.codigoExcepcion as 'C�digo de la Excepci�n'
					, procedimientos.descripcionExcepcion 'Descripci�n de la Excepcion'
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

