/*REQ-58 PROCEDIMIENTO ADMINISTRATIVO
Este reporte detalla 
  DESCRIPCIÓN: Este reporte presenta en detalle la información de los tipos de procedimiento administrativo 
	tramitados a los proveedores que no cumple con lo pactado en los contratos.
		La información que se desea desplegar es:			 									
			*	Número de procedimiento de la compra
			*	Número de procedimiento administrativo
			*	Nombre y cédula institución
			*	Nombre y cédula contratista
			*	Tipo de procedimiento
*/
CREATE PROCEDURE REP_ProcedimientosAdministrativos
AS
BEGIN
	SELECT
		procedimientos.numeroProcedimiento AS "Número de procedimiento"
		,procAdministrativos.numeroProcAdm AS "Número de procedimiento administrativo"
		,instituciones.cedulaInstitucion AS "Cédula de la institución"
		,instituciones.nombreinstitucion AS "Nombre de la institución"
		,proveedores.cedulaProveedor AS "Cédula del proveedor"
		,proveedores.nombreProveedor AS "Nombre del proveedor"
		,procAdministrativos.tipoProcedimientoAdm AS "Tipo de procedimiento administrativo"
		,procAdministrativos.multaClausula AS "Resultado del procedimiento"
		,tiempo.fecha AS "Fecha notificación del acto"
	FROM [dbo].[hechProcAdministrativos] procAdministrativos
		INNER JOIN [dbo].[dimProcedimientos] procedimientos
			ON procAdministrativos.procedimiento = procedimientos.idProcedimiento
		INNER JOIN [dbo].[dimProveedores] proveedores
			ON procAdministrativos.proveedor = proveedores.idProveedor
		INNER JOIN [dbo].[dimTiempo] tiempo
			ON procAdministrativos.fechaNotificacion = tiempo.idTiempo
		INNER JOIN [dbo].[dimInstituciones] instituciones
			ON procedimientos.institucion = instituciones.idInstitucion
END
GO

/*REQ-59 MAPA DE INVERSIONES
  DESCRIPCIÓN: Este reporte presenta en detalle procedimientos asociados con Mapa de Inversiones.
		La información que se desea desplegar es:				 									
			*	Número de procedimiento
			*	Tipo de Procedimiento
			*	Institución
			*	Cédula de la institución
			*	Nombre del contratista
			*	Cedula del contratista			
			*	Código de producto
			*	Subpartida Gasto Objeto
			*	Descripción del producto
			*	Código/Identificador mapa de inversión (Codigo BPIP) 			   
*/
CREATE PROCEDURE REP_MapaInversiones
AS
BEGIN
	SELECT
		procedimientos.numeroProcedimiento AS "Número de procedimiento"
		,procedimientos.tipoProcedimiento AS "Tipo de procedimiento"
		,instituciones.cedulaInstitucion AS "Cédula de la institución"
		,instituciones.nombreInstitucion AS "Nombre de la institución"
		,proveedores.cedulaProveedor AS "Cédula del proveedor"
		,proveedores.nombreProveedor AS "Nombre del proveedor"
		,CONCAT(clasificacionesProducto.codigoClasificacion,clasificacionesProducto.codigoIdentificacion,
			productos.codigoProducto) AS "Código del producto"
		,adjudicaciones.objetoGasto AS "Subpartida objeto de gasto"
		,productos.descripcionProducto AS "Descripción del producto"
		,procedimientos.codigoBPIP AS "Identificador del mapa de inversión (BPIP)"
		,tiempo.fecha AS "Fecha solicitud contratacion"
		,CONCAT('Costa Rica, ', instituciones.provinciaInstitucion, ', ' , instituciones.cantonInstitucion,
			', ', instituciones.distritoInstitucion) AS "Ubicación de la institución"			
	FROM [dbo].[hechAdjudicaciones] adjudicaciones
		INNER JOIN [dbo].[dimProcedimientos] procedimientos
			ON adjudicaciones.procedimiento = procedimientos.idProcedimiento
		INNER JOIN [dbo].[dimInstituciones] instituciones
			ON adjudicaciones.institucion = instituciones.idInstitucion
		INNER JOIN [dbo].[dimProveedores] proveedores
			ON adjudicaciones.proveedor = proveedores.idProveedor
		INNER JOIN [dbo].[dimProductos] productos
			ON adjudicaciones.producto = productos.idProducto
		INNER JOIN [dbo].[dimClasificacionProductos] clasificacionesProducto
			ON productos.clasificacionProducto = clasificacionesProducto.idClasificacionProducto
		INNER JOIN [dbo].[dimTiempo] tiempo
			ON adjudicaciones.fechaSolicitudContratacion = tiempo.idTiempo
	WHERE procedimientos.codigoBPIP NOT LIKE 'N/A'
END
GO

/*REQ-60 GARANTIAS DE PARTICIPACION
  DESCRIPCIÓN: Este reporte presenta en detalle las garantías de participación en los procedimientos de contratación.
		La información que se desea desplegar es:				 									
			*	Número de procedimiento
			*	Tipo de Procedimiento
			*	Institución
			*	Cédula de la institución
			*	Nombre del Contratista.
			*	Cédula del contratista 
			*	Tipo de Garantía
			*	Monto de la Garantía
			*	Estado de la Garantía
			*	Vigencia de la Garantía
*/
CREATE PROCEDURE REP_GarantiasParticipacion
AS
BEGIN	
	SELECT
		procedimientos.numeroProcedimiento AS "Número de procedimiento"
		,procedimientos.tipoProcedimiento AS "Tipo de procedimiento"
		,instituciones.cedulaInstitucion AS "Cédula de la institución"
		,instituciones.nombreInstitucion AS "Nombre de la institución"
		,proveedores.cedulaProveedor AS "Cédula del proveedor"
		,proveedores.nombreProveedor AS "Nombre del proveedor"
		,garantias.tipoGarantia AS "Tipo de garantía"
		,garantias.monto AS "Monto de la garantía"
		,garantias.estado AS "Estado de la garantía"
		,tiempoV.fecha AS "Fecha de vigencia"		
	FROM [dbo].[hechGarantias] garantias
		INNER JOIN [dbo].[dimProcedimientos] procedimientos
			ON garantias.procedimiento = procedimientos.idProcedimiento
		INNER JOIN [dbo].[dimInstituciones] instituciones
			ON procedimientos.institucion = instituciones.idInstitucion
		INNER JOIN [dbo].[dimProveedores] proveedores
			ON garantias.proveedor = proveedores.idProveedor
		INNER JOIN [dbo].[dimTiempo] tiempoV
			ON garantias.vigencia = tiempoV.idTiempo
		INNER JOIN [dbo].[dimTiempo] tiempoR
			ON garantias.fechaRegistro = tiempoR.idTiempo
		INNER JOIN (
			SELECT 
				adjudicaciones.procedimiento AS "procedimiento"
				,adjudicaciones.proveedor AS "proveedor"
				,tiempo.fecha AS "fechaAdjudicacion"
			FROM [dbo].[hechAdjudicaciones] adjudicaciones
				INNER JOIN [dbo].[dimTiempo] tiempo
					ON adjudicaciones.fechaAdjudicacionFirme = tiempo.idTiempo
			GROUP BY procedimiento, proveedor, tiempo.fecha			
		) fechasAdjudicaciones
			ON garantias.procedimiento = fechasAdjudicaciones.procedimiento
				AND garantias.proveedor = fechasAdjudicaciones.proveedor
	-- la fecha de registro de la garantía es previa a la fecha de la adjudicacion en firme
	WHERE tiempoR.fecha < fechasAdjudicaciones.fechaAdjudicacion 
END
GO

/*REQ-61 GARANTIAS DE CUMPLIMIENTO
  DESCRIPCIÓN: Este reporte presenta en detalle las garantías de cumplimiento en los procedimientos de contratación.
		La información que se desea desplegar es:				 									
			*	Número de procedimiento
			*	Tipo de Procedimiento
			*	Institución
			*	Cédula de la institución
			*	Nombre del Contratista.
			*	Cédula del contratista 
			*	Tipo de Garantía
			*	Monto de la Garantía
			*	Estado de la Garantía
			*	Vigencia de la Garantía
*/
CREATE PROCEDURE REP_GarantiasCumplimiento
AS
BEGIN
	SELECT
		procedimientos.numeroProcedimiento AS "Número de procedimiento"
		,procedimientos.tipoProcedimiento AS "Tipo de procedimiento"
		,instituciones.cedulaInstitucion AS "Cédula de la institución"
		,instituciones.nombreInstitucion AS "Nombre de la institución"
		,proveedores.cedulaProveedor AS "Cédula del proveedor"
		,proveedores.nombreProveedor AS "Nombre del proveedor"
		,garantias.tipoGarantia AS "Tipo de garantía"
		,garantias.monto AS "Monto de la garantía"
		,garantias.estado AS "Estado de la garantía"
		,tiempoV.fecha AS "Fecha de vigencia"
	FROM [dbo].[hechGarantias] garantias
		INNER JOIN [dbo].[dimProcedimientos] procedimientos
			ON garantias.procedimiento = procedimientos.idProcedimiento
		INNER JOIN [dbo].[dimInstituciones] instituciones
			ON procedimientos.institucion = instituciones.idInstitucion
		INNER JOIN [dbo].[dimProveedores] proveedores
			ON garantias.proveedor = proveedores.idProveedor
		INNER JOIN [dbo].[dimTiempo] tiempoV
			ON garantias.vigencia = tiempoV.idTiempo
		INNER JOIN [dbo].[dimTiempo] tiempoR
			ON garantias.fechaRegistro = tiempoR.idTiempo
		INNER JOIN (
			SELECT 
				adjudicaciones.procedimiento AS "procedimiento"
				,adjudicaciones.proveedor AS "proveedor"
				,tiempo.fecha AS "fechaAdjudicacion"
			FROM [dbo].[hechAdjudicaciones] adjudicaciones
				INNER JOIN [dbo].[dimTiempo] tiempo
					ON adjudicaciones.fechaAdjudicacionFirme = tiempo.idTiempo
			GROUP BY procedimiento, proveedor, tiempo.fecha			
		) fechasAdjudicaciones
			ON garantias.procedimiento = fechasAdjudicaciones.procedimiento
				AND garantias.proveedor = fechasAdjudicaciones.proveedor
	-- la fecha de registro de la garantía es posterior a la fecha de la adjudicacion en firme
	WHERE fechasAdjudicaciones.fechaAdjudicacion <= tiempoR.fecha
END
GO

/*REQ-62 SISTEMA DE EVALUACION OFERTAS
  DESCRIPCIÓN: Este reporte presenta en detalle del Sistema de Evaluación de ofertas de los procedimientos de contratación.
		La información que se desea desplegar es:			 									
			*	Número de procedimiento
			*	Tipo de Procedimiento
			*	Institución
			*	Cédula de la institución
			*	Nombre contratista (oferente)
			*	Cédula del contratista (oferente)
			*	Partida (del Cartel)
			*	Línea
			*	Código de Identificación (producto)
			*	Factor de Evaluación
			*	Porcentaje de Evaluación
			*	Fecha de publicación del cartel		   
*/
CREATE PROCEDURE REP_SistemaEvaluacion
AS
BEGIN
	SELECT TOP 20000 -- remover este top
		procedimientos.numeroProcedimiento AS "Número de procedimiento"
		,procedimientos.tipoProcedimiento AS "Tipo de Procedimiento"
		,instituciones.cedulaInstitucion AS "Cédula de la institución"
		,instituciones.nombreinstitucion AS "Nombre de la institución"
		,proveedores.cedulaProveedor AS "Cédula del proveedor"
		,proveedores.nombreProveedor AS "Nombre del proveedor"
		,carteles.numeroPartida AS "Partida"
		,carteles.numeroLinea AS "Linea"
		,CONCAT(clasificacionesProducto.codigoClasificacion,clasificacionesProducto.codigoIdentificacion,
			productos.codigoProducto) AS "Código de identificación"
		,criterios.factorEvaluar AS "Factor de evaluación"
		,criterios.porcentajeEvaluacion AS "Porcentaje de evaluación"
		,tiempo.fecha AS "Fecha de publicación"
	FROM [dbo].[hechCarteles] carteles
		INNER JOIN [dbo].[hechOfertas] ofertas
			ON carteles.procedimiento = ofertas.procedimiento
				AND carteles.numeroLinea = ofertas.numeroLinea		
		INNER JOIN [dbo].[hechCriteriosEvaluacion] criterios
			ON carteles.procedimiento = criterios.procedimiento 
		INNER JOIN [dbo].[dimProcedimientos] procedimientos
			ON carteles.procedimiento = procedimientos.idProcedimiento
		INNER JOIN [dbo].[dimProveedores] proveedores
			ON ofertas.proveedor = proveedores.idProveedor
		INNER JOIN [dbo].[dimInstituciones] instituciones
			ON procedimientos.institucion = instituciones.idInstitucion
		INNER JOIN [dbo].[dimProductos] productos
			ON ofertas.producto = productos.idProducto
		INNER JOIN [dbo].[dimClasificacionProductos] clasificacionesProducto
			ON productos.clasificacionProducto = clasificacionesProducto.idClasificacionProducto
		INNER JOIN [dbo].[dimTiempo] tiempo
			ON carteles.fechaPublicacion = tiempo.idTiempo
END
GO

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