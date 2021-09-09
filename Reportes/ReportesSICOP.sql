
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
			SELECT 	procedimiento.tipoProcedimiento as Procedimiento
					, count(procedimiento.idProcedimiento) as Cantidad  
			FROM [dbo].[dimProcedimientos] procedimiento 
			WHERE procedimiento.estadoProcedimiento = 'Adjudicación en firme' 
			GROUP BY procedimiento.tipoProcedimiento 
		END;
GO;

/*REQ-31 Invitados y Ofertas por proceso MODIFICAR
  DESCRIPCIÓN:Reporte donde muestra los proveedores que han sido invitados 
              a cada licitación (proceso) realizada.
				•	Número de procedimiento.
				•	Nombre del proveedor.
				•	Cedula del proveedor.
				•	Participo, SI   NO  .
				•	Fecha que se publica el cartel.
				•	Fecha y hora de la apertura.
				•	¿Ofertó?,  SI   NO  .
				•	Código de producto.
				•	Cantidad de unidades.
*/

CREATE PROCEDURE REP_InvitadosYOfertas
	AS
		BEGIN
			SELECT TOP 50
				procedimientos.numeroProcedimiento as 'Numero de Procedimiento'
				, proveedores.nombreProveedor as 'Nombre Proveedor'
				, proveedores.cedulaProveedor as 'Cedula Proveedor'
				, tiempo.fecha as 'Fecha Publicacion Cartel'
				, tiempoApertura.fecha as 'Fecha Apertura'
				, productos.codigoProducto as 'Código de Producto'


			FROM
				[dbo].[hechInvitaciones] invitaciones
				INNER JOIN [dbo].[dimProcedimientos] procedimientos
					ON invitaciones.procedimiento = procedimientos.idProcedimiento
				INNER JOIN [dbo].[dimProveedores] proveedores
					ON invitaciones.proveedor =proveedores.idProveedor
				INNER JOIN [dbo].[hechCarteles] carteles
					ON invitaciones.procedimiento = carteles.procedimiento
				INNER JOIN [dbo].[dimTiempo] tiempo
					ON carteles.fechaPublicacion = tiempo.idTiempo
				INNER JOIN [dbo].[dimTiempo] tiempoApertura
					ON carteles.fechaApertura = tiempoApertura.idTiempo
				INNER JOIN [dbo].[dimProductos] productos
					ON carteles.clasificacionProducto = productos.clasificacionProducto


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
					,SUM(CASE 
							WHEN procedimientos.estadoProcedimiento like'Adjudicado'
								THEN 1 
								ELSE 0 
									END) as 'Procedimientos adjudicados'
			FROM 
				[dbo].[hechCarteles] carteles
				INNER JOIN[dbo].[dimInstituciones] instituciones
					ON carteles.institucion = instituciones.idInstitucion
				INNER JOIN [dbo].[dimProcedimientos] procedimientos
					ON carteles.procedimiento=procedimientos.idProcedimiento
			GROUP BY instituciones.nombreInstitucion, instituciones.fechaIngreso 
		END;
GO;

/*REQ-35 SANCIONES A PROVEEDORES
  DESCRIPCION:  Reporte que muestra las sanciones aplicadas a proveedores. 
				A saber, los tipos de Sanción son Apercibimiento e Inhabilitación. 
				La información que se desea ver:
					•	Cedula Jurídica del Proveedor
					•	Nombre del Proveedor
					•	Tipo de Sanción
					•	Descripción de la Sanción
					•	Vigencia de la Sanción
					•	Fecha final de Sanción
*/
select* from[dbo].[hechCarteles]
CREATE PROCEDURE REP_SancionesProveedores
	AS
		BEGIN
			SELECT
					proveedores.cedulaProveedor
					,proveedores.nombreProveedor
					,sanciones.tipoSancion
					, sanciones.descripcionSancion
					, tiempoIS.fecha
					, tiempoFS.fecha
			FROM	[dbo].[hechSanciones] sanciones
					INNER JOIN [dbo].[dimProveedores] proveedores
						ON sanciones.proveedor= proveedores.idProveedor
					INNER JOIN [dbo].[dimTiempo] tiempoIS
						ON sanciones.fechaInicioSancion = tiempoIS.idTiempo
					INNER JOIN [dbo].[dimTiempo] tiempoFS
						ON sanciones.fechaFinalSancion = tiempoFS.idTiempo
			END;
GO;


/*REQ-38 FUNCIONARIO INHIBIDOS
  DESCRIPCION:Reporte que presenta los funcionarios inhibidos.
				La información que se desea ver:
				•	Cedula del funcionario
				•	Nombre del funcionario
				•	Institución donde labora
				•	Fecha de inicio de Inhibido
				•	Fecha de fin de Inhibido
*/
CREATE PROCEDURE REP_FuncionariosInhibidos
	AS
		BEGIN
			SELECT funcionarios.cedulaFuncionario as 'Cédula del Funcionario'
				   ,funcionarios.nombreFuncionario as 'Nombre del Funcionario'
				   ,instituciones.nombreInstitucion as 'Institucioón donde Labora'
				   ,tiempoFI.fecha as 'Fecha de Inicio de Inhibido'
				   ,tiempoFS.fecha as 'Fecha de Fin de Inhibido'
			FROM
				[dbo].[hechInhibicionesFuncionario] inhibiciones
				INNER JOIN [dbo].[dimFuncionarios] funcionarios
				ON inhibiciones.funcionario = funcionarios.idFuncionario
				INNER JOIN [dbo].[dimInstituciones] instituciones
				ON inhibiciones.institucion = instituciones.idInstitucion
				INNER JOIN [dbo].[dimTiempo] tiempoFI
				ON inhibiciones.fechaInicioInhibicion = tiempoFI.idTiempo
				INNER JOIN [dbo].[dimTiempo] tiempoFS
				ON inhibiciones.fechaFinalInhibicion = tiempoFS.idTiempo
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

/*REQ-42
  DESCRIPCIÓN: Presenta en detalle variables de los Proveedores adjudicados.
			   La información que se desea ver:
					•	Nombre de proveedor
					•	Cédula proveedor.
					•	Tipo de moneda
					•	Monto adjudicado 
					•	Nombre de la Institución
*/
CREATE PROCEDURE REP_ProveedoresAdjudicados
	AS
		BEGIN
			SELECT
					proveedores.nombreProveedor as 'Nombre del Proveedor'
					, proveedores.cedulaProveedor as 'Cedula del Proveedor'
					,monedas.descripcionMoneda as 'Moneda'
					,adjudicaciones.montoAdjudicadoLinea as 'Monto Adjudicado'
					, instituciones.nombreInstitucion
			FROM
					[dbo].[hechAdjudicaciones] adjudicaciones
					INNER JOIN [dbo].[dimProveedores] proveedores
						ON adjudicaciones.proveedor = proveedores.idProveedor
					INNER JOIN [dbo].[dimMonedas] monedas
						ON adjudicaciones.monedaAdjudicada = monedas.idMoneda
					INNER JOIN [dbo].[dimInstituciones] instituciones
						ON adjudicaciones.institucion = instituciones.idInstitucion FOR XML PATH
		END;
GO;

/*REQ-63 EMPRESAS CON MÁS OBJECIONES
  DESCRIPCIÓN: Este reporte presenta las empresas con más objeciones y que obstruyen los procesos de compra
			   La información que se desea ver:
				*	Nombre del Proveedor
				*	Cedula del proveedor
				*	Objeción presentada
				*	Numero de procedimiento
				*	Descripción del procedimiento
				*	Cantidad  de objeciones presentadas por empresa (proveedor)
				*	Nombre de institución a la que le presentaron la objeción
				*	Cédula de institución a la que le presentaron la objeción
				*	Cantidad de objeciones presentadas por Institución
*/
CREATE PROCEDURE REP_EmpresasMasObjeciones
AS
BEGIN
	SELECT
		proveedores.nombreProveedor AS "Nombre del proveedor"
		,proveedores.cedulaProveedor AS "Cédula del proveedor"
		,CONCAT(objeciones.tipoRecurso, ' a la linea ',objeciones.lineaObjetada) AS "Objeción presentada"
		,procedimientos.numeroProcedimiento AS "Número de procedimiento"
		,procedimientos.descripcionProcedimiento AS "Descripción del procedimiento"
		,instituciones.nombreInstitucion AS "Nombre de la institución"
		,instituciones.cedulaInstitucion AS "Cédula de la institución"
	FROM [dbo].[hechObjeciones] objeciones 
		INNER JOIN [dbo].[dimProcedimientos] procedimientos
			ON objeciones.procedimiento = procedimientos.idProcedimiento
		INNER JOIN [dbo].[dimInstituciones] instituciones
			ON procedimientos.institucion = instituciones.idInstitucion
		INNER JOIN [dbo].[dimProveedores] proveedores
			ON objeciones.proveedor = proveedores.idProveedor
END
GO

select* from

