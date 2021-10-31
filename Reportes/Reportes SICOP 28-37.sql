/* REQ-28 TIPO DE PROCEDIMIENTOS SICOP FINIQUITADO
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
	SELECT
		procedimientos.numeroProcedimiento AS "Número de procedimiento"
		,procedimientos.tipoProcedimiento AS "Tipo de procedimiento"	
		,monedas.codigoISO AS "Moneda"
		,SUM(adjudicaciones.montoAdjudicadoLinea) AS "Monto adjudicado"
		,SUM(adjudicaciones.montoAdjudicadoLineaUSD) AS "Monto adjudicado (equivalente en USD)"
		,MAX(tiempo.fecha) AS "Fecha adjudicación"
	FROM [dbo].[hechAdjudicaciones] adjudicaciones
		INNER JOIN [dbo].[dimProcedimientos] procedimientos
			ON adjudicaciones.procedimiento = procedimientos.idProcedimiento
		INNER JOIN [dbo].[dimMonedas] monedas
			ON monedas.idMoneda = adjudicaciones.monedaAdjudicada	
		INNER JOIN [dbo].[dimTiempo] tiempo
			ON adjudicaciones.fechaAdjudicacionFirme = tiempo.idTiempo
	WHERE procedimientos.estadoProcedimiento IN ('Contrato', 'Finiquitado', 'Adjudicación en firme')
	GROUP BY procedimientos.numeroProcedimiento, procedimientos.tipoProcedimiento,
		procedimientos.descripcionProcedimiento, monedas.codigoISO						
END
GO

/*	REQ-29 COMPRAS POR INSTITUCION, PRODUCTOS, PRECIO AÑO
	DESCRIPCION: Generar un reporte que detalle las distintas compras por entidad pública que se realizan en SICOP.
		La información que se presentará para este reporte será la siguiente:
			*	Nombre de la Institución. 
			*	Número de Procedimiento. 
			*	Descripción por procedimiento. 
			*	Moneda.
			*	Monto reservado.
			*	Monto del procedimiento (adjudicado).
			*	Monto Contratado.
			*	Región (Distrito)
*/
CREATE PROCEDURE REP_ComprasInstitucion
AS
BEGIN
	SELECT
		procedimiento
		,moneda
		,SUM(montoReservado) AS "totalReservado"
		,SUM(montoReservado / tipoCambioUSD) "totalReservadoUSD"
	INTO #montoReservado
	FROM [dbo].[hechCarteles]
	GROUP BY procedimiento, moneda
	
	SELECT
		procedimiento
		,monedaAdjudicada AS "moneda"
		,SUM(montoAdjudicadoLinea) AS "totalAdjudicado"
		,SUM(montoAdjudicadoLineaUSD) AS "totalAdjudicadoUSD"
		,MAX(tiempo.fecha) AS "fechaUltimaAdjudicacion"
	INTO #montoAdjudicado
	FROM [dbo].[hechAdjudicaciones] adjudicaciones		
		INNER JOIN dimTiempo tiempo
			ON adjudicaciones.fechaAdjudicacionFirme = tiempo.idTiempo
	GROUP BY procedimiento, monedaAdjudicada

	SELECT
		procedimiento
		,moneda
		,SUM(cantidadContratada * precioUnitario - descuento + IVA) AS "totalContratado"
		,SUM((cantidadContratada * precioUnitario - descuento + IVA) / tipoCambioUSD) AS "totalContratadoUSD"
	INTO #montoContratado
	FROM [dbo].[hechContrataciones]		
	-- deja por fuera las contrataciones que tienen tipo de cambio en 0 (NULL en el origen), para evitar una división por cero
	-- pedir que introduzcan esa información o re-estructurar todo el almacen de datos para contemplar una dimensión tipo de cambio
	WHERE tipoCambioUSD <> 0
	GROUP BY procedimiento, moneda
		
	SELECT
		instituciones.nombreInstitucion AS "Nombre de la institución"
		,instituciones.distritoInstitucion AS "Región"
		,procedimientos.numeroProcedimiento AS "Número del procedimiento"
		,procedimientos.descripcionProcedimiento AS "Descripción del procedimiento"
		,procedimientos.tipoProcedimiento AS "Tipo de procedimiento"
		,monedas.descripcionMoneda AS "Moneda"		
		,COALESCE(reservados.totalReservado, 0) AS "Monto reservado (moneda)"
		,COALESCE(reservados.totalReservadoUSD, 0) AS "Monto reservado (equivalente en USD)"
		,COALESCE(adjudicados.totalAdjudicado, 0) AS "Monto adjudicado (moneda)"
		,COALESCE(adjudicados.totalAdjudicadoUSD, 0) AS "Monto adjudicado (equivalente en USD)"
		,COALESCE(contratados.totalContratado, 0) AS "Monto contratado (moneda)"
		,COALESCE(contratados.totalContratadoUSD, 0) AS "Monto contratado (equivalente en USD)"
		,adjudicados.fechaUltimaAdjudicacion AS "Fecha de Adjudicación"
	FROM (
			SELECT 
				procedimiento
				,moneda
			FROM #montoReservado
			UNION
			SELECT 
				procedimiento
				,moneda
			FROM #montoAdjudicado
			UNION
			SELECT 
				procedimiento
				,moneda
			FROM #montoContratado
		) AS procedimientoMoneda
		LEFT JOIN #montoReservado reservados
			ON procedimientoMoneda.procedimiento = reservados.procedimiento
				AND procedimientoMoneda.moneda = reservados.moneda
		LEFT JOIN #montoAdjudicado adjudicados
			ON procedimientoMoneda.procedimiento = adjudicados.procedimiento
				AND procedimientoMoneda.moneda = adjudicados.moneda
		LEFT JOIN #montoContratado contratados
			ON procedimientoMoneda.procedimiento = contratados.procedimiento
				AND procedimientoMoneda.moneda = contratados.moneda
		INNER JOIN [dbo].[dimProcedimientos] procedimientos
			ON procedimientoMoneda.procedimiento = procedimientos.idProcedimiento
		INNER JOIN [dbo].[dimInstituciones] instituciones
			ON procedimientos.institucion = instituciones.idInstitucion
		INNER JOIN [dbo].[dimMonedas] monedas
			ON procedimientoMoneda.moneda = monedas.idMoneda
END
GO

/*	REQ-30 MERCANCIAS, SERVICIOS Y BIENES MAS COMPRADOS
	DESCRIPCION: Reporte con el detalle de compras de códigos de identificación y productos.
		La información que se presentará para este reporte será la siguiente:
			*	Código de identificación
			*	Código de producto. 
			*	Clasificación presupuestaria. 
			*	Cantidad
			*	Monto
			*	Moneda
*/
CREATE PROCEDURE REP_Mercancias
AS
BEGIN
	SELECT
		instituciones.cedulaInstitucion AS "Cédula de la institución"
		,instituciones.nombreInstitucion AS "Nombre de la institución"
		,clasificacionesProducto.codigoIdentificacion AS "Código de identificación"
		,CONCAT(clasificacionesProducto.codigoClasificacion, clasificacionesProducto.codigoIdentificacion,
			productos.codigoProducto) AS "Código de producto"
		,adjudicaciones.objetoGasto AS "Clasificación presupuestaria"
		,monedas.descripcionMoneda AS "Moneda"
		,tiempo.fecha AS "Fecha Adjudicación"			
		,SUM(adjudicaciones.montoAdjudicadoLinea) AS "Monto"
		,SUM(adjudicaciones.cantidadAdjudicada) AS "Cantidad"
	FROM [dbo].[hechAdjudicaciones] adjudicaciones
		INNER JOIN [dbo].[dimProcedimientos] procedimientos
			ON adjudicaciones.procedimiento = procedimientos.idProcedimiento
		INNER JOIN [dbo].[dimInstituciones] instituciones
			ON adjudicaciones.institucion = instituciones.idInstitucion
		INNER JOIN [dbo].[dimMonedas] monedas
			ON adjudicaciones.monedaAdjudicada = monedas.idMoneda
		INNER JOIN [dbo].[dimTiempo] tiempo
			ON adjudicaciones.fechaAdjudicacionFirme =tiempo.idTiempo
		INNER JOIN [dbo].[dimProductos] productos
			ON adjudicaciones.producto = productos.idProducto
		INNER JOIN [dbo].[dimClasificacionProductos] clasificacionesProducto
			ON productos.clasificacionProducto = clasificacionesProducto.idClasificacionProducto
		GROUP BY instituciones.cedulaInstitucion
			,instituciones.nombreInstitucion
			,clasificacionesProducto.codigoIdentificacion
			,CONCAT(clasificacionesProducto.codigoClasificacion, clasificacionesProducto.codigoIdentificacion,
				productos.codigoProducto)
			,adjudicaciones.objetoGasto
			,monedas.descripcionMoneda
			,tiempo.fecha
END
GO

/*REQ-31 Invitados y Ofertas por proceso FINIQUITADO
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

EXEC REP_InvitadosYOfertas
CREATE PROCEDURE REP_InvitadosYOfertas
	AS
		BEGIN
			SELECT distinct
				procedimientos.numeroProcedimiento
				,instituciones.nombreInstitucion
				,proveedores.nombreProveedor
				,proveedores.cedulaProveedor
				,(CASE WHEN invitaciones.fechaInvitacion IS NOT NULL
					THEN 
						'SÍ'
					ELSE 
						'NO'
							END) as '¿Participó?'
				,publicación.fecha as 'Publicación del Cartel'
				,apertura.fecha as 'Apertura del Cartel'
				,(CASE WHEN ofertas.fechaPresentacion IS NOT NULL
					THEN 
						'SÍ'
					ELSE 
						'NO'
							END) as '¿Ofertó?'
				,productos.codigoProducto
				,ofertas.cantidadOfertada as 'Cantidad de Unidades'

				

			FROM
				[dbo].[hechInvitaciones] invitaciones
				INNER JOIN [dbo].[dimInstituciones] instituciones
					ON invitaciones.institucion = instituciones.idInstitucion
				INNER JOIN [dbo].[dimProveedores] proveedores
					ON invitaciones.proveedor = proveedores.idProveedor
				INNER JOIN [dbo].[dimProcedimientos] procedimientos
					ON invitaciones.procedimiento = procedimientos.idProcedimiento
				INNER JOIN [dbo].[hechOfertas] ofertas
					ON invitaciones.procedimiento = ofertas.procedimiento 
						AND invitaciones.proveedor = ofertas.proveedor
				INNER JOIN [dbo].[dimProductos] productos
					ON ofertas.producto = productos.codigoProducto
				INNER JOIN[dbo].[hechCarteles] carteles
					ON invitaciones.procedimiento = carteles.procedimiento
				INNER JOIN [dbo].[dimTiempo] apertura
					ON carteles.fechaApertura = apertura.idTiempo
				INNER JOIN [dbo].[dimTiempo] publicación
					ON carteles.fechaPublicacion = publicación.idTiempo
						
		END;
GO;

/*REQ-33 COMPARATIVO PRECIO DE UN PRODUCTO POR INSTITUCION FINIQUITADO
  DESCRIPCION: Reporte que presenta los precios finales de los códigos de producto adquiridos 
               en diferentes procesos de contratación.
				La información a presentar es la siguiente:
				•	Instituciones.
				•	Números de procedimiento.
				•	Código de producto.
				•	Descripción del bien o servicio.
				•	Precios de producto.
				•	Fecha de adjudicación.
				•	Nombre Contratista.
				•	Cedula del contratista.
*/

CREATE PROCEDURE REP_ComparativaPrecioProducto
	AS
		BEGIN
			SELECT
				instituciones.nombreInstitucion
				, procedimientos.numeroProcedimiento
				, productos.codigoProducto
				, productos.descripcionProducto
				, adjudicaciones.montoAdjudicadoLinea
				, tiempoAdjudicacion.fecha
				, proveedores.nombreProveedor
				, proveedores.cedulaProveedor
				
			FROM
				[dbo].[hechAdjudicaciones] adjudicaciones
				INNER JOIN [dbo].[dimInstituciones] instituciones
					ON adjudicaciones.institucion= instituciones.idInstitucion
				INNER JOIN [dbo].[dimProcedimientos] procedimientos
					ON adjudicaciones.procedimiento= procedimientos.idProcedimiento
				INNER JOIN [dbo].[dimProductos] productos
					ON adjudicaciones.producto= productos.idProducto
				INNER JOIN [dbo].[dimProveedores] proveedores
					ON adjudicaciones.proveedor= proveedores.idProveedor
				INNER JOIN [dbo].[dimTiempo] tiempoAdjudicacion
					ON adjudicaciones.fechaAdjudicacionFirme= tiempoAdjudicacion.idTiempo
				GROUP BY instituciones.nombreInstitucion
						,procedimientos.numeroProcedimiento
						,productos.codigoProducto
						,productos.descripcionProducto
						,adjudicaciones.montoAdjudicadoLinea
						,tiempoAdjudicacion.fecha
						,proveedores.nombreProveedor
						,proveedores.cedulaProveedor
						

		END;
GO;
/*REQ-34 INSTITUCIONES QUE UTILIZAN SICOP FINIQUITADO
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
			SELECT
				T0.nombreInstitucion 'Nombre Institución'
				,T0.fechaIngreso as 'Fecha Ingreso SICOP'
				,MIN(tiempoAdjudicacion.fecha) as 'Fecha Primera Adjudicación SICOP '
				,T0.[Total Procedimientos] as 'Total Procedmientos'
				,T0.[Procedimientos adjudicados] as 'Total Adjudicaciones'
				,SUM(adjudicaciones.montoAdjudicadoLineaUSD) as 'Monto Total Adjudicado'

			FROM 
				(
					SELECT
						instituciones.idInstitucion,instituciones.nombreInstitucion,instituciones.fechaIngreso
						,COUNT(procedimientos.idProcedimiento) as 'Total Procedimientos'
						,SUM(CASE WHEN procedimientos.estadoProcedimiento like'Adjudicado'
								THEN 1 
								ELSE 0 
							END) as 'Procedimientos adjudicados'
					FROM
					[dbo].[dimProcedimientos] procedimientos
					INNER JOIN [dbo].[dimInstituciones] instituciones
						ON procedimientos.institucion = instituciones.idInstitucion
					GROUP BY instituciones.idInstitucion, instituciones.nombreInstitucion, instituciones.fechaIngreso
				) AS T0
				INNER JOIN [dbo].[hechAdjudicaciones] adjudicaciones
					ON T0.idInstitucion = adjudicaciones.institucion
				INNER JOIN [dbo].[dimTiempo] tiempoAdjudicacion
					ON adjudicaciones.fechaAdjudicacionFirme = tiempoAdjudicacion.idTiempo
				GROUP BY T0.nombreInstitucion, T0.fechaIngreso, T0.[Total Procedimientos], T0.[Procedimientos adjudicados]
				ORDER BY T0.nombreInstitucion
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
/*REQ-36 REPORTES PROVEEDORES-CONTRATISTAS
  DESCRIPCION:Reporte que muestra las órdenes de compra de cada proveedor.
			  Mostrará información de proveedores más frecuentes medidos por cantidad de órdenes de compras
			  y por monto económico adjudicado
			  Se requiere un mapa de Costa Rica en el dashboard que permita al dar clic en una zona geográfica específica
			  , abrir un cuadro de diálogo sobre información de la institución o empresa
			  , y a su vez que genere el reporte con la información descrita a continuación.
			  El mapa debe detallar
			     1- ubicación de los proveedores, 
				 2- ubicación de instituciones compradoras.
*/

CREATE PROCEDURE REP_ProveedoresYOrdenes
	AS
		BEGIN
			SELECT
				T0.idProveedor
				,T0.[Tipo de Cédula]
				,T0.[Cedula de Proveedor]
				,T0.[Nombre Proveedor]
				,count (contratos.idContrato) as 'Cantidad de Contratos'
			
			FROM
				(SELECT
					proveedores.idProveedor
					,proveedores.tipoProveedor as 'Tipo de Cédula'
					,proveedores.cedulaProveedor as 'Cedula de Proveedor'
					, proveedores.nombreProveedor as 'Nombre Proveedor'
					, proveedores.tamanoProveedor as 'Tipo de Empresa'
					, proveedores.provinciaProveedor as 'Provincia'
					, proveedores.cantonProveedor as 'Canton'
					, proveedores.fechaRegistro as 'Fecha Registro SICOP'
				FROM
					[dbo].[dimProveedores] proveedores) AS T0		
					LEFT JOIN [dbo].[dimContratos] as contratos
						ON T0.idProveedor = contratos.proveedor
				GROUP BY
					T0.idProveedor
					,T0.[Tipo de Cédula]
					,T0.[Cedula de Proveedor]
					,T0.[Nombre Proveedor]
		END;
GO;

SELECT
	proveedores.idProveedor
	,count(contratos.idContrato)
	,count(sanciones.proveedor)
	,count(invitaciones.proveedor)
	,count(ofertas.proveedor)
FROM
	[dbo].[dimProveedores] proveedores
	LEFT JOIN [dbo].[dimContratos] contratos
		ON proveedores.idProveedor = contratos.proveedor
	LEFT JOIN [dbo].[hechSanciones] sanciones
		ON proveedores.idProveedor = sanciones.proveedor
	LEFT JOIN [dbo].[hechInvitaciones] invitaciones
		ON proveedores.idProveedor= invitaciones.proveedor
	LEFT  JOIN [dbo].[hechOfertas] ofertas
		ON proveedores.idProveedor = ofertas.proveedor
	GROUP BY proveedores.idProveedor
/*REQ-37 REPORTES PROVEEDORES-CONTRATISTAS FINIQUITADO
  DESCRIPCION: Reporte que muestra los proveedores registrados en SICOP 
			   y las instituciones públicas que compran bienes y servicios
			   La información que se desea ver:
					• Nombre del Proveedor
					• Cédula del Proveedor
					• Nombre de Institución
					• Número de Procedimiento
					• Descripción del Procedimiento
					• Monto Adjudicado
					• Estado del Concurso/Procedimiento
*/
CREATE PROCEDURE REP_Proveedores
AS
BEGIN
	SELECT
		proveedores.nombreProveedor as 'Nombre Proveedor'
		,proveedores.cedulaProveedor as 'Cédula Proveedor'
		, instituciones.nombreInstitucion as 'Nombre Institución'
		, procedimientos.numeroProcedimiento as 'Nuúmero de Procedimiento'
		, procedimientos.descripcionProcedimiento as 'Descripción del Procedimiento'
		, SUM(adjudicaciones.montoAdjudicadoLinea) as 'Monto Adjudicado'
		, procedimientos.estadoProcedimiento as 'Estado del Procedimiento'
	FROM
		[dbo].[hechAdjudicaciones] adjudicaciones
		INNER JOIN [dbo].[dimProveedores] proveedores
			ON adjudicaciones.proveedor = proveedores.idProveedor
		INNER JOIN [dbo].[dimProcedimientos] procedimientos
			ON adjudicaciones.procedimiento= procedimientos.idProcedimiento
		INNER JOIN [dbo].[dimInstituciones] instituciones
			ON adjudicaciones.institucion= instituciones.idInstitucion
		GROUP BY proveedores.nombreProveedor
				, proveedores.cedulaProveedor
				, instituciones.nombreInstitucion
				, procedimientos.numeroProcedimiento
				, procedimientos.descripcionProcedimiento
				, procedimientos.estadoProcedimiento

END;
GO;