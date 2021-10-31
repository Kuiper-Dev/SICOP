/*REQ-58 PROCEDIMIENTO ADMINISTRATIVO
Este reporte detalla 
  DESCRIPCI�N: Este reporte presenta en detalle la informaci�n de los tipos de procedimiento administrativo 
	tramitados a los proveedores que no cumple con lo pactado en los contratos.
		La informaci�n que se desea desplegar es:			 									
			*	N�mero de procedimiento de la compra
			*	N�mero de procedimiento administrativo
			*	Nombre y c�dula instituci�n
			*	Nombre y c�dula contratista
			*	Tipo de procedimiento
*/
CREATE PROCEDURE REP_ProcedimientosAdministrativos
AS
BEGIN
	SELECT
		procedimientos.numeroProcedimiento AS "N�mero de procedimiento"
		,procAdministrativos.numeroProcAdm AS "N�mero de procedimiento administrativo"
		,instituciones.cedulaInstitucion AS "C�dula de la instituci�n"
		,instituciones.nombreinstitucion AS "Nombre de la instituci�n"
		,proveedores.cedulaProveedor AS "C�dula del proveedor"
		,proveedores.nombreProveedor AS "Nombre del proveedor"
		,procAdministrativos.tipoProcedimientoAdm AS "Tipo de procedimiento administrativo"
		,procAdministrativos.multaClausula AS "Resultado del procedimiento"
		,tiempo.fecha AS "Fecha notificaci�n del acto"
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
  DESCRIPCI�N: Este reporte presenta en detalle procedimientos asociados con Mapa de Inversiones.
		La informaci�n que se desea desplegar es:				 									
			*	N�mero de procedimiento
			*	Tipo de Procedimiento
			*	Instituci�n
			*	C�dula de la instituci�n
			*	Nombre del contratista
			*	Cedula del contratista			
			*	C�digo de producto
			*	Subpartida Gasto Objeto
			*	Descripci�n del producto
			*	C�digo/Identificador mapa de inversi�n (Codigo BPIP) 			   
*/
CREATE PROCEDURE REP_MapaInversiones
AS
BEGIN
	SELECT
		procedimientos.numeroProcedimiento AS "N�mero de procedimiento"
		,procedimientos.tipoProcedimiento AS "Tipo de procedimiento"
		,instituciones.cedulaInstitucion AS "C�dula de la instituci�n"
		,instituciones.nombreInstitucion AS "Nombre de la instituci�n"
		,proveedores.cedulaProveedor AS "C�dula del proveedor"
		,proveedores.nombreProveedor AS "Nombre del proveedor"
		,CONCAT(clasificacionesProducto.codigoClasificacion,clasificacionesProducto.codigoIdentificacion,
			productos.codigoProducto) AS "C�digo del producto"
		,adjudicaciones.objetoGasto AS "Subpartida objeto de gasto"
		,productos.descripcionProducto AS "Descripci�n del producto"
		,procedimientos.codigoBPIP AS "Identificador del mapa de inversi�n (BPIP)"
		,tiempo.fecha AS "Fecha solicitud contratacion"
		,CONCAT('Costa Rica, ', instituciones.provinciaInstitucion, ', ' , instituciones.cantonInstitucion,
			', ', instituciones.distritoInstitucion) AS "Ubicaci�n de la instituci�n"			
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
  DESCRIPCI�N: Este reporte presenta en detalle las garant�as de participaci�n en los procedimientos de contrataci�n.
		La informaci�n que se desea desplegar es:				 									
			*	N�mero de procedimiento
			*	Tipo de Procedimiento
			*	Instituci�n
			*	C�dula de la instituci�n
			*	Nombre del Contratista.
			*	C�dula del contratista 
			*	Tipo de Garant�a
			*	Monto de la Garant�a
			*	Estado de la Garant�a
			*	Vigencia de la Garant�a
*/
CREATE PROCEDURE REP_GarantiasParticipacion
AS
BEGIN	
	SELECT
		procedimientos.numeroProcedimiento AS "N�mero de procedimiento"
		,procedimientos.tipoProcedimiento AS "Tipo de procedimiento"
		,instituciones.cedulaInstitucion AS "C�dula de la instituci�n"
		,instituciones.nombreInstitucion AS "Nombre de la instituci�n"
		,proveedores.cedulaProveedor AS "C�dula del proveedor"
		,proveedores.nombreProveedor AS "Nombre del proveedor"
		,garantias.tipoGarantia AS "Tipo de garant�a"
		,garantias.monto AS "Monto de la garant�a"
		,garantias.estado AS "Estado de la garant�a"
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
	-- la fecha de registro de la garant�a es previa a la fecha de la adjudicacion en firme
	WHERE tiempoR.fecha < fechasAdjudicaciones.fechaAdjudicacion 
END
GO

/*REQ-61 GARANTIAS DE CUMPLIMIENTO
  DESCRIPCI�N: Este reporte presenta en detalle las garant�as de cumplimiento en los procedimientos de contrataci�n.
		La informaci�n que se desea desplegar es:				 									
			*	N�mero de procedimiento
			*	Tipo de Procedimiento
			*	Instituci�n
			*	C�dula de la instituci�n
			*	Nombre del Contratista.
			*	C�dula del contratista 
			*	Tipo de Garant�a
			*	Monto de la Garant�a
			*	Estado de la Garant�a
			*	Vigencia de la Garant�a
*/
CREATE PROCEDURE REP_GarantiasCumplimiento
AS
BEGIN
	SELECT
		procedimientos.numeroProcedimiento AS "N�mero de procedimiento"
		,procedimientos.tipoProcedimiento AS "Tipo de procedimiento"
		,instituciones.cedulaInstitucion AS "C�dula de la instituci�n"
		,instituciones.nombreInstitucion AS "Nombre de la instituci�n"
		,proveedores.cedulaProveedor AS "C�dula del proveedor"
		,proveedores.nombreProveedor AS "Nombre del proveedor"
		,garantias.tipoGarantia AS "Tipo de garant�a"
		,garantias.monto AS "Monto de la garant�a"
		,garantias.estado AS "Estado de la garant�a"
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
	-- la fecha de registro de la garant�a es posterior a la fecha de la adjudicacion en firme
	WHERE fechasAdjudicaciones.fechaAdjudicacion <= tiempoR.fecha
END
GO

/*REQ-62 SISTEMA DE EVALUACION OFERTAS
  DESCRIPCI�N: Este reporte presenta en detalle del Sistema de Evaluaci�n de ofertas de los procedimientos de contrataci�n.
		La informaci�n que se desea desplegar es:			 									
			*	N�mero de procedimiento
			*	Tipo de Procedimiento
			*	Instituci�n
			*	C�dula de la instituci�n
			*	Nombre contratista (oferente)
			*	C�dula del contratista (oferente)
			*	Partida (del Cartel)
			*	L�nea
			*	C�digo de Identificaci�n (producto)
			*	Factor de Evaluaci�n
			*	Porcentaje de Evaluaci�n
			*	Fecha de publicaci�n del cartel		   
*/
CREATE PROCEDURE REP_SistemaEvaluacion
AS
BEGIN
	SELECT TOP 20000 -- remover este top
		procedimientos.numeroProcedimiento AS "N�mero de procedimiento"
		,procedimientos.tipoProcedimiento AS "Tipo de Procedimiento"
		,instituciones.cedulaInstitucion AS "C�dula de la instituci�n"
		,instituciones.nombreinstitucion AS "Nombre de la instituci�n"
		,proveedores.cedulaProveedor AS "C�dula del proveedor"
		,proveedores.nombreProveedor AS "Nombre del proveedor"
		,carteles.numeroPartida AS "Partida"
		,carteles.numeroLinea AS "Linea"
		,CONCAT(clasificacionesProducto.codigoClasificacion,clasificacionesProducto.codigoIdentificacion,
			productos.codigoProducto) AS "C�digo de identificaci�n"
		,criterios.factorEvaluar AS "Factor de evaluaci�n"
		,criterios.porcentajeEvaluacion AS "Porcentaje de evaluaci�n"
		,tiempo.fecha AS "Fecha de publicaci�n"
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

/*REQ-63 EMPRESAS CON M�S OBJECIONES
  DESCRIPCI�N: Este reporte presenta las empresas con m�s objeciones y que obstruyen los procesos de compra
			   La informaci�n que se desea ver:
				*	Nombre del Proveedor
				*	Cedula del proveedor
				*	Objeci�n presentada
				*	Numero de procedimiento
				*	Descripci�n del procedimiento
				*	Cantidad  de objeciones presentadas por empresa (proveedor)
				*	Nombre de instituci�n a la que le presentaron la objeci�n
				*	C�dula de instituci�n a la que le presentaron la objeci�n
				*	Cantidad de objeciones presentadas por Instituci�n
*/
CREATE PROCEDURE REP_EmpresasMasObjeciones
AS
BEGIN
	SELECT
		proveedores.nombreProveedor AS "Nombre del proveedor"
		,proveedores.cedulaProveedor AS "C�dula del proveedor"
		,CONCAT(objeciones.tipoRecurso, ' a la linea ',objeciones.lineaObjetada) AS "Objeci�n presentada"
		,procedimientos.numeroProcedimiento AS "N�mero de procedimiento"
		,procedimientos.descripcionProcedimiento AS "Descripci�n del procedimiento"
		,instituciones.nombreInstitucion AS "Nombre de la instituci�n"
		,instituciones.cedulaInstitucion AS "C�dula de la instituci�n"
	FROM [dbo].[hechObjeciones] objeciones 
		INNER JOIN [dbo].[dimProcedimientos] procedimientos
			ON objeciones.procedimiento = procedimientos.idProcedimiento
		INNER JOIN [dbo].[dimInstituciones] instituciones
			ON procedimientos.institucion = instituciones.idInstitucion
		INNER JOIN [dbo].[dimProveedores] proveedores
			ON objeciones.proveedor = proveedores.idProveedor
END
GO