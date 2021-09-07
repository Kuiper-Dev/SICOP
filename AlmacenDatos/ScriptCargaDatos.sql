USE dw_sicop

--- cargas de informacion ---

CREATE PROCEDURE InsertarFecha
   @CurrentDate DATE
AS
	INSERT INTO dimTiempo (fecha,dia,mes,ano,trimestre,semestre,semana,diaAno,diaSemana)
	VALUES (
		@CurrentDate
		, DATEPART(day , @CurrentDate)
		, DATEPART(month , @CurrentDate)
		, DATEPART(year , @CurrentDate)
		, DATEPART(quarter , @CurrentDate)
		, CASE WHEN DATEPART(quarter , @CurrentDate) <= 2 THEN 1 ELSE 2 END
		, DATEPART(week , @CurrentDate)
		, DATEPART(dayofyear , @CurrentDate)
		, DATEPART(weekday , @CurrentDate)
   )


declare @StartDate datetime, @EndDate datetime
set @StartDate = '2010-01-01'
set @EndDate = '2049-12-31'

while @StartDate <= @EndDate begin
   exec InsertarFecha @StartDate
   set @StartDate = dateadd(day,1,@StartDate) 
end

INSERT INTO dimProveedores(cedulaProveedor, nombreProveedor, tipoProveedor, tamanoProveedor, 
	provinciaProveedor, cantonProveedor, distritoProveedor, fechaConstitucion, fechaRegistro)
VALUES ('N/A','N/A','N/A','N/A','N/A','N/A','N/A','0001-01-01','0001-01-01')

INSERT INTO dimTiempo(fecha, dia, mes, ano, trimestre, semestre, semana, diaAno, diaSemana)
VALUES ('0001-01-01',0,0,0,0,0,0,0,0)

INSERT INTO dimInstituciones(cedulaInstitucion, nombreInstitucion, provinciaInstitucion, cantonInstitucion,
	distritoInstitucion, fechaIngreso)
VALUES ('N/A','N/A','N/A','N/A','N/A','0001-01-01')

--- consultas para cargar dimensiones ---

INSERT INTO dimProveedores (cedulaProveedor, nombreProveedor, tipoProveedor, tamanoProveedor, provinciaProveedor,
	cantonProveedor, distritoProveedor, fechaConstitucion, fechaRegistro)
SELECT
	COALESCE (CEDULA_PROVEEDOR, 'N/A')
	,COALESCE (NOMBRE_PROVEEDOR, 'N/A')
	,COALESCE (TIPO_PROVEEDOR, 'N/A')
	,COALESCE (TAMAÑO_PROVEEDOR, 'N/A')
	,CASE
		WHEN zona_geo_prov like ', , ' then 'N/A'
		ELSE SUBSTRING(zona_geo_prov,LEN(zona_geo_prov)-CHARINDEX(',',REVERSE(zona_geo_prov))+3, LEN(zona_geo_prov))
		END -- provinciaProveedor
	,CASE 
		WHEN zona_geo_prov like ', , %' then 'N/A'
		ELSE SUBSTRING(zona_geo_prov, CHARINDEX(',',zona_geo_prov)+2, 
			(LEN(zona_geo_prov)-CHARINDEX(',', REVERSE(zona_geo_prov))+1)-(CHARINDEX(',',zona_geo_prov)+2))
		END -- cantonProveedor
	,CASE
		WHEN zona_geo_prov like ', %, %' then 'N/A'
		ELSE SUBSTRING(zona_geo_prov, 1, CHARINDEX(',',zona_geo_prov)-1)
		END --distritoProveedor					
	,CASE FECHA_CONSTITUCION 
		WHEN 'No aplica' THEN '0001-01-01'
		WHEN NULL THEN '0001-01-01'
		ELSE CONCAT(SUBSTRING(FECHA_CONSTITUCION,5,4),'-',SUBSTRING(FECHA_CONSTITUCION,3,2),
			'-',SUBSTRING(FECHA_CONSTITUCION,1,2))
		END			
	,COALESCE(FECHA_REGISTRO, '0001-01-01')
FROM OCPE.ocpe_synapse_dw_copy.SIC.Proveedores

INSERT INTO dimInstituciones (cedulaInstitucion, nombreInstitucion, provinciaInstitucion, cantonInstitucion,
	distritoInstitucion, fechaIngreso)
SELECT
	COALESCE (CEDULA, 'N/A')
	,COALESCE (NOMBRE_INSTITUCION, 'N/A')
	,SUBSTRING(ZONA_GEO_INST,LEN(ZONA_GEO_INST)-CHARINDEX(',',REVERSE(ZONA_GEO_INST))+3, LEN(ZONA_GEO_INST)) --provinciaInstitucion		
	,SUBSTRING(ZONA_GEO_INST, CHARINDEX(',',ZONA_GEO_INST)+2, 
			(LEN(ZONA_GEO_INST)-CHARINDEX(',', REVERSE(ZONA_GEO_INST))+1)-(CHARINDEX(',',ZONA_GEO_INST)+2)) --cantonInstitucion		
	,SUBSTRING(ZONA_GEO_INST, 1, CHARINDEX(',',ZONA_GEO_INST)-1) --distritoInstitucion		
	,COALESCE(FECHA_INGRESO, '0001-01-01')	
FROM OCPE.ocpe_synapse_dw_copy.SIC.InstitucionesRegistradas

INSERT INTO dimClasificacionProductos (codigoClasificacion, codigoIdentificacion, descripcionClasificacion)
SELECT
	SUBSTRING(T0.codigo, 1, 8)
	,SUBSTRING(T0.codigo, 9, 8)	
	, T0.descripcion
FROM(
	SELECT 
		CODIGO_IDENTIFICACION AS codigo		
		,DESC_LINEA AS descripcion		
	FROM OCPE.ocpe_synapse_dw_copy.SIC.DetalleLineaCartel
	GROUP BY CODIGO_IDENTIFICACION, DESC_LINEA
) AS T0

INSERT INTO dimProductos (codigoProducto, descripcionProducto, fechaRegistro,
	clasificacionProducto)
SELECT
	CP.CODIGO_PRODUCTO
	,CP.DESC_BIEN_SERVICIO
	,COALESCE(CP.fecha_registro, '0001-01-01')			
	,CL.idClasificacionProducto
FROM OCPE.ocpe_synapse_dw_copy.SIC.CodigosProducto CP
		INNER JOIN dimClasificacionProductos CL ON CP.CODIGO_CLASIFICACION = CL.codigoClasificacion 
			AND CP.CODIGO_IDENTIFICACION = CL.codigoIdentificacion

INSERT INTO dimMonedas (descripcionMoneda, codigoISO)
SELECT 
	UPPER(Descripcion)
	,COALESCE(CodigoISO, 'N/A')
FROM OCPE.ocpe_synapse_dw_copy.CGR.Moneda

INSERT INTO dimProcedimientos(numeroProcedimiento, tipoProcedimiento, modalidadProcedimiento,
	descripcionProcedimiento, descripcionExcepcion, codigoExcepcion, estadoProcedimiento,
	codigoBPIP, clasificacion, nroSICOP, institucion)
SELECT
	NRO_PROCEDIMIENTO
	,TIPO_PROCEDIMIENTO
	,MODALIDAD_PROCEDIMIENTO
	,CARTEL_NM
	,COALESCE(DES_EXCEPCION, 'N/A')
	,COALESCE(COD_EXCEPCION, 'N/A')
	,CARTEL_STAT
	,COALESCE(CODIGO_BPIP, 'N/A')
	,CLAS_OBJ
	,NRO_SICOP
	,DI.idInstitucion
FROM OCPE.ocpe_synapse_dw_copy.SIC.DetalleCarteles DC
	INNER JOIN dimInstituciones DI ON DC.CEDULA_INSTITUCION = DI.cedulaInstitucion

INSERT INTO dimRepresentantes(cedulaRepresentante, nombreRepresentante)
SELECT
	T0.cedula
	,T0.nombre
FROM (
	SELECT 
		COALESCE(CEDULA_REPRESENTANTE, 'N/A') AS cedula
		,COALESCE(REPRESENTANTE, 'N/A') AS nombre		
	FROM OCPE.ocpe_synapse_dw_copy.SIC.ProcedimientoAdjudicacion
	GROUP BY CEDULA_REPRESENTANTE, REPRESENTANTE	
) AS T0

INSERT INTO dimFuncionarios(cedulaFuncionario, nombreFuncionario)
SELECT
	T0.cedula
	,T0.nombre
FROM (
	SELECT 
		COALESCE(CED_FUNCIONARIO, 'N/A') AS cedula
		,COALESCE(NOM_FUNCIONARIO, 'N/A') AS nombre		
	FROM OCPE.ocpe_synapse_dw_copy.SIC.FuncionariosInhibicion
	GROUP BY CED_FUNCIONARIO, NOM_FUNCIONARIO	
) AS T0

-- consultas para cargar hechos --

INSERT INTO hechCarteles(fechaPublicacion, procedimiento, fechaApertura,
	numeroLinea, numeroPartida, cantidadSolicitada, precioUnitarioEstimado, moneda,
	montoReservado, clasificacionProducto, tipoCambioCRC, tipoCambioUSD)
SELECT	
	DT1.idTiempo
	,DP.idProcedimiento
	,DT2.idTiempo
	,LC.NUMERO_LINEA
	,CAST(LC.NUMERO_PARTIDA AS INTEGER)
	,LC.CANTIDAD_SOLICITADA
	,LC.PRECIO_UNITARIO_ESTIMADO
	,DM.idMoneda
	,LC.MONTO_RESERVADO
	,CP.idClasificacionProducto
	,CAST(LC.TIPO_CAMBIO_CRC AS MONEY)
	,CAST(LC.TIPO_CAMBIO_DOLAR AS MONEY)
FROM OCPE.ocpe_synapse_dw_copy.SIC.DetalleCarteles DC
	INNER JOIN OCPE.ocpe_synapse_dw_copy.SIC.DetalleLineaCartel LC ON DC.NRO_SICOP = LC.NRO_SICOP
	INNER JOIN dimTiempo DT1 ON CAST(DC.FECHA_PUBLICACION AS DATE) = DT1.fecha
	INNER JOIN dimProcedimientos DP ON DC.NRO_PROCEDIMIENTO = DP.numeroProcedimiento
	INNER JOIN dimTiempo DT2 ON CAST(DC.FECHAH_APERTURA AS DATE) = DT2.fecha
	INNER JOIN dimMonedas DM ON LC.TIPO_MONEDA = DM.codigoISO
	INNER JOIN dimClasificacionProductos CP ON LC.CODIGO_IDENTIFICACION = CONCAT(CP.codigoClasificacion,CP.codigoIdentificacion)

INSERT INTO hechInvitaciones(institucion, procedimiento, proveedor, fechaInvitacion, secuencia)
SELECT
	,DI.idInstitucion
	,DP.idProcedimiento
	,PV.idProveedor
	,DT.idTiempo
	,SECUENCIA
FROM OCPE.ocpe_synapse_dw_copy.SIC.InvitacionProcedimiento IP
	INNER JOIN dimInstituciones DI ON ISNULL(IP.CED_INSTITUCION,'N/A') = DI.cedulaInstitucion
	INNER JOIN dimProcedimientos DP ON IP.NUMERO_PROCEDIMIENTO = DP.numeroProcedimiento
	INNER JOIN dimProveedores PV ON ISNULL(IP.CEDULA_PROVEEDOR,'N/A') = PV.cedulaProveedor
	INNER JOIN dimTiempo DT ON ISNULL(CAST(IP.FECHA_INVITACION AS DATE), '0001-01-01') = DT.fecha

--INSERT INTO hechOfertas (proveedor, fechaPresentacion, procedimiento, tipoOferta, producto,
--	moneda, numeroLinea, numeroOferta, cantidadOfertada, precioUnitarioOfertado, descuento,
--	IVAUnidad, acarreos, IVAAcarreos, otrosImpuestos, tipoCambioCRC, tipoCambioUSD, montoTotal)
--SELECT top 100
--	--PV.idProveedor
--	--,DT.idTiempo
--	--,DP.idProcedimiento
--	O.TIPO_OFERTA
--	,PR.idProducto
--	--,DM.idMoneda
--	,CAST(NRO_LINEA AS SMALLINT)
--	,O.NRO_OFERTA
--	,LO.CANTIDAD_OFERTADA
--	,LO.PRECIO_UNITARIO_OFERTADO
--	,LO.DESCUENTO
--	,LO.IVA
--	,LO.ACARREOS
--	,LO.OTROS_IMPUESTOS
--	,CAST(LO.TIPO_CAMBIO_CRC AS MONEY)
--	,CAST(LO.TIPO_CAMBIO_DOLAR AS MONEY)
--	,0	
--FROM OCPE.ocpe_synapse_dw_copy.SIC.Ofertas O
--	INNER JOIN OCPE.ocpe_synapse_dw_copy.SIC.LineasOfertadas LO ON O.NRO_OFERTA = LO.NRO_OFERTA
--	--INNER JOIN dimProcedimientos DP ON O.NRO_SICOP = DP.nroSICOP
--	--INNER JOIN dimProveedores PV ON O.CEDULA_PROVEEDOR = PV.cedulaProveedor
--	--INNER JOIN dimTiempo DT ON CAST(O.FECHA_PRESENTA_OFERTA AS DATE) = DT.fecha
--	INNER JOIN dimClasificacionProductos CP ON LO.CODIGO_PRODUCTO_CL = CONCAT(CP.codigoClasificacion,CP.codigoIdentificacion)
--	INNER JOIN dimProductos PR ON LO.CODIGO_PRODUCTO = CONCAT(CP.codigoClasificacion,CP.codigoIdentificacion,PR.codigoProducto)		
--	--INNER JOIN dimMonedas DM ON LO.TIPO_MONEDA = DM.codigoISO
--where nro_oferta = 'D2012030116343611811330641276741A'

INSERT hechCriteriosEvaluacion(procedimiento, fechaRegistro, factorEvaluar, porcentajeEvaluacion)
SELECT
	DP.idProcedimiento
	,DT.idTiempo
	,T0.factor
	,T0.porcentaje
FROM (
	SELECT 
		NRO_SICOP AS nroSICOP		
		,FACTOR_EVAL AS factor
		,PORC_EVAL AS porcentaje
		,fecha_registro AS fechaRegistro		
		,EVAL_ITEM_SEQNO AS columna5
	FROM OCPE.ocpe_synapse_dw_copy.SIC.SistemaEvaluacionOfertas
	GROUP BY NRO_SICOP, FACTOR_EVAL, PORC_EVAL, fecha_registro, EVAL_ITEM_SEQNO
) AS T0
	INNER JOIN dimProcedimientos DP ON T0.nroSICOP = DP.nroSICOP
	INNER JOIN dimTiempo DT ON T0.fechaRegistro =  DT.fecha


INSERT INTO hechSanciones(institucion, proveedor, fechaRegistro, fechaInicioSancion, fechaFinalSancion, 
	codigoProducto, descripcionProducto, tipoSancion, descripcionSancion, estadoSancion, numeroResolucion)
SELECT
	DI.idInstitucion
	,PV.idProveedor
	,DTR.idTiempo
	,DTI.idTiempo
	,DTF.idTiempo
	,SP.CODIGO_PRODUCTO
	,SP.DESCRIP_PRODUCTO
	,SP.TIPO_SANCION
	,SP.DESCR_SANCION
	,COALESCE(SP.ESTADO,'N/A')
	,COALESCE(SP.NO_RESOLUCION, 'N/A')
FROM OCPE.ocpe_synapse_dw_copy.SIC.SancionProveedores SP
	INNER JOIN dimInstituciones DI ON ISNULL(SP.CEDULA_INSTITUCION,'N/A') = DI.cedulaInstitucion
	INNER JOIN dimProveedores PV ON ISNULL(SP.CEDULA_PROVEEDOR,'N/A') = PV.cedulaProveedor
	INNER JOIN dimTiempo DTR ON ISNULL(SP.fecha_registro, '0001-01-01') = DTR.fecha
	INNER JOIN dimTiempo DTI ON 
		CASE WHEN INICIO_SANCION IS NULL THEN '0001-01-01' 
		ELSE CONCAT(SUBSTRING(INICIO_SANCION,5,4),'-',SUBSTRING(INICIO_SANCION,3,2),'-',SUBSTRING(INICIO_SANCION,1,2)) 
		END = DTI.fecha
	INNER JOIN dimTiempo DTF ON 
		CASE WHEN FINAL_SANCION IS NULL THEN '0001-01-01' 
		ELSE CONCAT(SUBSTRING(FINAL_SANCION,5,4),'-',SUBSTRING(FINAL_SANCION,3,2),'-',SUBSTRING(FINAL_SANCION,1,2)) 
		END = DTF.fecha

INSERT INTO hechInhibicionesFuncionario(institucion, funcionario, fechaRegistro, fechaInicioInhibicion, 
	fechaFinalInhibicion, estadoInhibicion)
SELECT
	DI.idInstitucion
	,DF.idFuncionario
	,DTR.idTiempo
	,DTI.idTiempo
	,DTF.idTiempo	
	,FI.ESTADO	
FROM OCPE.ocpe_synapse_dw_copy.SIC.FuncionariosInhibicion FI
	INNER JOIN dimInstituciones DI ON FI.CED_INSTITUCION = DI.cedulaInstitucion
	INNER JOIN dimFuncionarios DF ON FI.CED_FUNCIONARIO = DF.cedulaFuncionario
	INNER JOIN dimTiempo DTR ON FI.fecha_registro = DTR.fecha
	INNER JOIN dimTiempo DTI ON CAST(FECHA_INICIO AS DATE) = DTI.fecha
	INNER JOIN dimTiempo DTF ON CAST(FECHA_FIN  AS DATE) = DTF.fecha

INSERT INTO hechObjeciones(procedimiento, proveedor, fechaPresentacion, numeroRecurso, numeroActo,
	lineaObjetada, tipoRecurso, estadoRecurso, resultado, causaResultado, nombreRecurrente)
SELECT
	DP.idProcedimiento
	,PV.idProveedor
	,DT.idTiempo	
	,RO.NRO_RECURSO
	,COALESCE(RO.NRO_ACTO, 0)
	,RO.LINEA_OBJETADA
	,RO.TIPO_RECURSO
	,RO.recurso_stat
	,RO.RESULTADO
	,RO.CAUSA_RESULTADO
	,reqer_nm	
FROM OCPE.ocpe_synapse_dw_copy.SIC.RecursosObjecion RO	
	INNER JOIN dimProcedimientos DP ON RO.NRO_SICOP = DP.nroSICOP
	INNER JOIN dimProveedores PV ON RO.CEDULA_PROVEEDOR = PV.cedulaProveedor
	INNER JOIN dimTiempo DT ON CAST(RO.FECHA_PRESENTACION_RECURSO AS DATE) = DT.fecha

INSERT INTO dimContratos(numeroContrato, procedimiento, institucion, proveedor)
SELECT 
	T0.NRO_CONTRATO
	,DP.idProcedimiento
	,DI.idInstitucion
	,PV.idProveedor	
FROM ( 
	SELECT
		NRO_CONTRATO
		,NRO_SICOP
		,CEDULA_INSTITUCION
		,CEDULA_PROVEEDOR
		FROM OCPE.ocpe_synapse_dw_copy.SIC.Contratos
		GROUP BY NRO_CONTRATO ,NRO_SICOP ,CEDULA_INSTITUCION ,CEDULA_PROVEEDOR
) AS T0
	INNER JOIN dimProcedimientos DP ON T0.NRO_SICOP = DP.nroSICOP
	INNER JOIN dimInstituciones DI ON T0.CEDULA_INSTITUCION = DI.cedulaInstitucion
	INNER JOIN dimProveedores PV ON T0.CEDULA_PROVEEDOR = PV.cedulaProveedor

---- FINAL SCRIPT ---