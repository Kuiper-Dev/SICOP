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


-- revisar esta carga
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


-- revisar esta carga
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


-- revisar esta carga
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
	DI.idInstitucion
	,DP.idProcedimiento
	,PV.idProveedor
	,DT.idTiempo
	,SECUENCIA
FROM OCPE.ocpe_synapse_dw_copy.SIC.InvitacionProcedimiento IP
	INNER JOIN dimInstituciones DI ON ISNULL(IP.CED_INSTITUCION,'N/A') = DI.cedulaInstitucion
	INNER JOIN dimProcedimientos DP ON IP.NUMERO_PROCEDIMIENTO = DP.numeroProcedimiento
	INNER JOIN dimProveedores PV ON ISNULL(IP.CEDULA_PROVEEDOR,'N/A') = PV.cedulaProveedor
	INNER JOIN dimTiempo DT ON ISNULL(CAST(IP.FECHA_INVITACION AS DATE), '0001-01-01') = DT.fecha

INSERT INTO hechOfertas (proveedor, fechaPresentacion, procedimiento, tipoOferta, producto,
	moneda, numeroLinea, numeroOferta, cantidadOfertada, precioUnitarioOfertado, descuento,
	IVAUnidad, acarreos, IVAAcarreos, otrosImpuestos, tipoCambioCRC, tipoCambioUSD, montoTotal)
SELECT
	PV.idProveedor
	,DT.idTiempo
	,DP.idProcedimiento
	,O.TIPO_OFERTA
	,PR.idProducto	
	,DM.idMoneda
	,CAST(NRO_LINEA AS SMALLINT)
	,O.NRO_OFERTA
	,LO.CANTIDAD_OFERTADA
	,LO.PRECIO_UNITARIO_OFERTADO
	,COALESCE(LO.DESCUENTO, 0)
	,COALESCE(LO.IVA, 0)
	,COALESCE(LO.ACARREOS, 0)
	,0
	,COALESCE(LO.OTROS_IMPUESTOS, 0)
	,CAST(LO.TIPO_CAMBIO_CRC AS MONEY)
	,CAST(LO.TIPO_CAMBIO_DOLAR AS MONEY)
	,0	
FROM OCPE.ocpe_synapse_dw_copy.SIC.Ofertas O
	INNER JOIN OCPE.ocpe_synapse_dw_copy.SIC.LineasOfertadas LO ON O.NRO_OFERTA = LO.NRO_OFERTA
	INNER JOIN dimProcedimientos DP ON O.NRO_SICOP = DP.nroSICOP
	INNER JOIN dimProveedores PV ON O.CEDULA_PROVEEDOR = PV.cedulaProveedor
	INNER JOIN dimTiempo DT ON CAST(O.FECHA_PRESENTA_OFERTA AS DATE) = DT.fecha
	INNER JOIN dimClasificacionProductos CP ON LO.CODIGO_PRODUCTO_CL = CONCAT(CP.codigoClasificacion,CP.codigoIdentificacion)
	INNER JOIN dimProductos PR ON CP.idClasificacionProducto = PR.clasificacionProducto 
		AND SUBSTRING(LO.CODIGO_PRODUCTO,17,8) = PR.codigoProducto	
	INNER JOIN dimMonedas DM ON LO.TIPO_MONEDA = DM.codigoISO

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

INSERT INTO hechAdjudicaciones(institucion,procedimiento,proveedor,perfilProveedor,numeroLinea,
	representante,fechaSolicitudContratacion,objetoGasto,monedaAdjudicada,montoAdjudicadoLinea,
	montoAdjudicadoLineaCRC,montoAdjudicadoLineaUSD,fechaAdjudicacionFirme,unidadMedida,
	monedaPrecioEstimado,clasificacionProducto,numeroOferta,producto,numeroActo,cantidadAdjudicada,
	precioUnitarioAdjudicado,acarreo,descuento,IVA,otroImpuesto,tipoCambioCRC,tipoCambioUSD,permiteRecursos,desierto
)
SELECT
	DP.institucion	,DP.idProcedimiento	,PV.idProveedor	,PA.PERFIL_PROV	
	,PA.LINEA	,RP.idRepresentante	,DTS.idTiempo	,COALESCE(PA.OBJETO_GASTO, 'N/A')
	,DMA.idMoneda	,CAST(PA.MONTO_ADJU_LINEA AS REAL),	CAST(PA.MONTO_ADJU_LINEA_CRC AS REAL)	,CAST(PA.MONTO_ADJU_LINEA_USD AS REAL)
	,DTF.idTiempo	,PA.UNIDAD_MEDIDA	,DME.idMoneda	,DC.idClasificacionProducto
	,LA.NRO_OFERTA	,PR.idProducto	,LA.NRO_ACTO	,LA.CANTIDAD_ADJUDICADA
	,LA.PRECIO_UNITARIO_ADJUDICADO	,LA.ACARREOS	,LA.DESCUENTO	,LA.IVA
	,LA.OTROS_IMPUESTOS	,LA.TIPO_CAMBIO_CRC	,LA.TIPO_CAMBIO_DOLAR	,COALESCE(AF.PERMITE_RECURSOS, 'N/A')
	,AF.DESIERTO
FROM OCPE.ocpe_synapse_dw_copy.SIC.ProcedimientoAdjudicacion PA
	INNER JOIN OCPE.ocpe_synapse_dw_copy.SIC.LineasAdjudicadas LA ON PA.NRO_SICOP = LA.NRO_SICOP
		AND PA.LINEA = LA.NRO_LINEA
		AND PA.CEDULA_PROVEEDOR = LA.CEDULA_PROVEEDOR
	INNER JOIN OCPE.ocpe_synapse_dw_copy.SIC.AdjudicacionesFirme AF ON LA.NRO_SICOP = AF.NRO_SICOP
		AND LA.NRO_ACTO = AF.NRO_ACTO
	INNER JOIN dimProcedimientos DP ON PA.NRO_SICOP = DP.nroSICOP
	INNER JOIN dimProveedores PV ON LA.CEDULA_PROVEEDOR = PV.cedulaProveedor
	INNER JOIN dimRepresentantes RP ON PA.CEDULA_REPRESENTANTE = RP.cedulaRepresentante
	INNER JOIN dimMonedas DMA ON PA.MONEDA_ADJUDICADA = DMA.codigoISO
	INNER JOIN dimMonedas DME ON PA.MONEDA_PRECIO_EST = DME.codigoISO
	INNER JOIN dimTiempo DTS ON
		CASE 
			WHEN PA.FECHA_SOL_CONTRA IS NULL THEN '0001-01-01' 
			ELSE CONCAT(SUBSTRING(PA.FECHA_SOL_CONTRA,7,4),'-',SUBSTRING(PA.FECHA_SOL_CONTRA,4,2),'-',SUBSTRING(PA.FECHA_SOL_CONTRA,1,2)) 
		END = DTS.fecha
	INNER JOIN dimTiempo DTF ON
		CASE
			WHEN PA.FECHA_ADJUD_FIRME IS NULL THEN '0001-01-01' 
			ELSE CONCAT(SUBSTRING(PA.FECHA_ADJUD_FIRME,7,4),'-',SUBSTRING(PA.FECHA_ADJUD_FIRME,4,2),'-',SUBSTRING(PA.FECHA_ADJUD_FIRME,1,2)) 
		END = DTF.fecha
	INNER JOIN dimClasificacionProductos DC ON PA.PROD_ID_CL = CONCAT(DC.codigoClasificacion,DC.codigoIdentificacion)
	INNER JOIN dimProductos PR ON DC.idClasificacionProducto = PR.clasificacionProducto
		AND SUBSTRING(LA.CODIGO_PRODUCTO,17,8) = PR.codigoProducto		

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

INSERT INTO hechRemates(procedimiento, proveedor, fechaInvitacion, monedaPuja, montoPuja, montoEstimadoLinea,
	cantidadEstimada, monedaAdjudicada, montoAdjudicado, cantidadAdjudicada, tipoCambioMoneda)
SELECT
	DP.idProcedimiento
	,PV.idProveedor
	,DT.idTiempo
	,DMP.idMoneda
	,RM.MONTO_PUJA
	,RM.MONTO_EST_LINEA
	,RM.CANT_EST
	,DMA.idMoneda
	,RM.MONTO_ADJ
	,CONVERT(INTEGER,CAST(RM.CANT_ADJ AS REAL))
	,TIPO_CAMBIO_MONEDA
FROM OCPE.ocpe_synapse_dw_copy.SIC.Remates RM
	INNER JOIN dimProcedimientos DP ON RM.NRO_SICOP = DP.nroSICOP
	INNER JOIN dimProveedores PV ON RM.CED_PROVEEDOR = PV.cedulaProveedor
	INNER JOIN dimTiempo DT ON CAST(RM.FECHA_INVITACION AS DATE) = DT.fecha
	INNER JOIN dimMonedas DMP ON RM.MONEDA_PUJA = DMP.codigoISO
	INNER JOIN dimMonedas DMA ON RM.MONEDA_ADJ = DMA.codigoISO

INSERT INTO hechContrataciones(contrato,procedimiento,secuencia,proveedor,fechaInicioProrroga,fechaFinalProrroga
	,vigencia,fechaInicioSuspension,fechaReanudacionContrato,plazoSuspension,tipoContrato,tipoModificacion,fechaModificacion
	,fechaNotificacion,fechaElaboracion,tipoAutorizacion,tipoDisminucion,numeroLineaContrato,numeroLineaCartel,cantidadAumentada
	,cantidadDisminuida,montoAumentado,montoDisminuido,otrosImpuestos,acarreos,tipoCambioCRC,tipoCambioUSD,numeroActo,producto
	,cantidadContratada,precioUnitario,moneda,descuento,IVA)
SELECT
	DC.idContrato, DC.procedimiento, CT.SECUENCIA, DC.proveedor, 5480, 5480, COALESCE(CT.VIGENCIA, 'N/A')
	,5480,5480,COALESCE(CT.FECHA_REINI_CONT,0),CT.TIPO_CONTRATO,CT.TIPO_MODIFICACION,5480,5480,5480
	,CT.TIPO_AUTORIZACION, COALESCE(CT.TIPO_DISMINUCION,'N/A'),LC.NRO_LINEA_CONTRATO,COALESCE(LC.NRO_LINEA_CARTEL,0),CAST(COALESCE(LC.cantidad_aumentada,'0') AS FLOAT)
	,CAST(COALESCE(LC.cantidad_disminuida,'0') AS FLOAT),CAST(COALESCE(LC.monto_aumentado,'0') AS MONEY),CAST(COALESCE(LC.monto_disminuido,'0') AS MONEY)
	,COALESCE(LC.OTROS_IMPUESTOS,0),LC.ACARREOS,CAST(COALESCE(LC.TIPO_CAMBIO_CRC,'0') AS MONEY),CAST(COALESCE(LC.TIPO_CAMBIO_DOLAR,'0') AS MONEY)
	,CAST(COALESCE(LC.NRO_ACTO,'0') AS INTEGER),1,LC.CANTIDAD_CONTRATADA,LC.PRECIO_UNITARIO,22,LC.DESCUENTO,LC.IVA
FROM OCPEO.ocpe_synapse_dw.SIC.Contratos CT
	INNER JOIN OCPEO.ocpe_synapse_dw.SIC.LineasContratadas LC ON (CT.NRO_CONTRATO = LC.NRO_CONTRATO
		AND CT.SECUENCIA = LC.SECUENCIA)
	INNER JOIN dimContratos DC ON CT.NRO_CONTRATO = DC.numeroContrato

UPDATE hechContrataciones
SET fechaInicioProrroga = DTIP.idTiempo
	,fechaFinalProrroga = DTFP.idTiempo
	,fechaInicioSuspension = DTIS.idTiempo
	,fechaReanudacionContrato = DTRC.idTiempo
FROM hechContrataciones HC
	INNER JOIN dimContratos DC ON HC.contrato = DC.idContrato
	INNER JOIN OCPE.ocpe_synapse_dw_copy.SIC.Contratos CT ON DC.numeroContrato = CT.NRO_CONTRATO
		AND HC.secuencia = CT.SECUENCIA
	INNER JOIN dimTiempo DTIP ON ISNULL(CT.FECHA_INI_PRORR,'0001-01-01') = DTIP.fecha
	INNER JOIN dimTiempo DTFP ON ISNULL(CT.FECHA_FIN_PRORR,'0001-01-01') = DTFP.fecha
	INNER JOIN dimTiempo DTIS ON ISNULL(CT.FECHA_INI_SUSP,'0001-01-01') = DTIS.fecha	
	INNER JOIN dimTiempo DTRC ON ISNULL(CT.PLAZO_SUSP,'0001-01-01') = DTRC.fecha

UPDATE hechContrataciones
SET fechaModificacion = DTFM.idTiempo
	,fechaNotificacion = DTFN.idTiempo
	,fechaElaboracion = DTFE.idTiempo
FROM hechContrataciones HC
	INNER JOIN dimContratos DC ON HC.contrato = DC.idContrato
	INNER JOIN OCPE.ocpe_synapse_dw_copy.SIC.Contratos CT ON DC.numeroContrato = CT.NRO_CONTRATO
		AND HC.secuencia = CT.SECUENCIA
	INNER JOIN dimTiempo DTFM ON ISNULL(CT.FECHA_MODIFICACION,'0001-01-01') = DTFM.fecha
	INNER JOIN dimTiempo DTFN ON ISNULL(CT.FECHA_NOTIFICACION,'0001-01-01') = DTFN.fecha
	INNER JOIN dimTiempo DTFE ON ISNULL(CT.FECHA_ELABORACION,'0001-01-01') = DTFE.fecha

UPDATE hechContrataciones
SET producto = PR.idProducto
FROM hechContrataciones HC
	INNER JOIN dimContratos DC ON DC.idContrato = HC.contrato
	INNER JOIN OCPE.ocpe_synapse_dw_copy.SIC.LineasContratadas LC ON DC.numeroContrato = LC.NRO_CONTRATO
		AND HC.secuencia = LC.SECUENCIA	
		AND HC.numeroLineaContrato = LC.NRO_LINEA_CONTRATO
	INNER JOIN dimClasificacionProductos CL ON SUBSTRING(LC.CODIGO_PRODUCTO, 1, 16) = CONCAT(CL.codigoClasificacion,CL.codigoIdentificacion)
	INNER JOIN dimProductos PR ON CL.idClasificacionProducto = PR.clasificacionProducto
		AND SUBSTRING(LC.CODIGO_PRODUCTO,17,8) = PR.codigoProducto

-- carga alternativa (dura mucho combinando todo en una sola consulta ¿?)
DECLARE @temp TABLE (contrato BIGINT, secuencia VARCHAR(3), numeroLineaContrato SMALLINT, moneda INTEGER)
INSERT INTO @temp
SELECT
	DC.idContrato
	,LC.SECUENCIA
	,LC.NRO_LINEA_CONTRATO
	,DM.idMoneda
FROM OCPE.ocpe_synapse_dw_copy.SIC.LineasContratadas LC
	INNER JOIN dimContratos DC ON LC.NRO_CONTRATO = DC.numeroContrato
	INNER JOIN dimMonedas DM ON LC.TIPO_MONEDA = DM.codigoISO
UPDATE hechContrataciones
SET	moneda = temp.moneda
FROM hechContrataciones HC
	INNER JOIN @temp temp ON HC.contrato = temp.contrato
		AND HC.secuencia = temp.secuencia
		AND HC.numeroLineaContrato = temp.numeroLineaContrato	
		

INSERT INTO hechGarantias(procedimiento, fechaRegistro, proveedor, numeroGarantia,
	cedulaGarante, secuenciaGarantia, tipoGarantia, monto, estado, vigencia)
SELECT
	DP.idProcedimiento
	,DTR.idTiempo
	,PV.idProveedor
	,COALESCE(GR.nro_garantia, 'N/A')
	,COALESCE(GR.ced_garante, 'N/A')
	,GR.gara_seq
	,COALESCE(GR.TIPO_GARANTIA, 'N/A')
	,COALESCE(GR.MONTO, 0)
	,GR.ESTADO
	,DTV.idTiempo
FROM OCPE.ocpe_synapse_dw_copy.SIC.Garantias GR
	INNER JOIN dimProcedimientos DP ON GR.NRO_SICOP = DP.nroSICOP
	INNER JOIN dimProveedores PV ON GR.CEDULA_PROVEEDOR = PV.cedulaProveedor
	INNER JOIN dimTiempo DTR ON ISNULL(GR.fecha_registro, '0001-01-01') = DTR.fecha
	INNER JOIN dimTiempo DTV ON 
		CASE WHEN GR.VIGENCIA IS NULL THEN '0001-01-01' 
		ELSE CONCAT(SUBSTRING(GR.VIGENCIA,5,4),'-',SUBSTRING(GR.VIGENCIA,3,2),'-',SUBSTRING(GR.VIGENCIA,1,2)) 
		END = DTV.fecha	

INSERT INTO hechReajustesPrecio(procedimiento,proveedor,fechaInicio,fechaFin,mesesAAplicar,diasAAplicar,moneda,
	montoTotal,precioUnitario,numeroReajuste,precioAnteriorUltimoReajuste,montoReajuste,nuevoPrecio,
	porcentajeIncrementoUltimoReajuste,fechaElaboracion,producto,contrato,numeroLineaContrato,cantidadContratada)
SELECT
	DC.procedimiento, DC.proveedor,DTFI.idTiempo,DTFF.idTiempo,RJ.MESES_APP,RJ.DIAS_APP,DM.idMoneda,RJ.MONTO_TOTAL
	,RJ.PRECIO_UNITARIO,RJ.NUMERO_REAJUSTE,RJ.PRECIO_ANT_ULT_RJ,RJ.MONTO_REAJUSTE,RJ.NUEVO_PRECIO,RJ.PORC_INCR_ULT_RJ
	,DTFE.idTiempo,PR.idProducto,DC.idContrato,RJ.NRO_LINEA_CONTRATO,RJ.CANTIDAD_CONTRATADA
FROM OCPE.ocpe_synapse_dw_copy.SIC.ReajustePrecios RJ
	INNER JOIN dimContratos DC ON RJ.NRO_CONTRATO = DC.numeroContrato
	INNER JOIN dimTiempo DTFI ON CAST(RJ.FECHA_INICIO AS DATE) = DTFI.fecha
	INNER JOIN dimTiempo DTFF ON CAST(RJ.FECHA_FIN AS DATE) = DTFF.fecha
	INNER JOIN dimTiempo DTFE ON CAST(RJ.FECHA_ELABORACION AS DATE) = DTFE.fecha
	INNER JOIN dimClasificacionProductos CL ON SUBSTRING(RJ.CODIGO_PRODUCTO, 1, 16) = CONCAT(CL.codigoClasificacion,CL.codigoIdentificacion)
	INNER JOIN dimProductos PR ON CL.idClasificacionProducto = PR.clasificacionProducto
		AND SUBSTRING(RJ.CODIGO_PRODUCTO,17,8) = PR.codigoProducto
	INNER JOIN dimMonedas DM ON RJ.TIPO_MONEDA = DM.codigoISO

INSERT INTO hechOrdenesPedido(contrato, secuenciaContrato, numeroOrden, fechaElaboracion, fechaNotificacion,
	fechaRecepcionPedido, lineaOrdenPedido, secuenciaOrden, moneda, totalOrden, totalEstimado, montoUSD, estadoOrden)
SELECT
	DC.idContrato
	,OP.SECUENCIA_CONTRATO
	,OP.NRO_ORDEN
	,DTFE.idTiempo
	,DTFN.idTiempo
	,DTFR.idTiempo
	,OP.LINEA_ORD_PEDIDO
	,OP.SECUENCIA
	,DM.idMoneda
	,OP.TOTAL_ORDEN
	,COALESCE(OP.TOTALESTIMADO,0)
	,OP.USD_MONT
	,OP.ESTADO_ORDEN
FROM OCPEO.ocpe_synapse_dw.SIC.OrdenPedido OP
	INNER JOIN dimContratos DC ON OP.CONTRACT_NO = DC.numeroContrato
	INNER JOIN dimTiempo DTFE ON CAST(OP.FECHA_ELABORACION_ORDEN AS DATE) = DTFE.fecha
	INNER JOIN dimTiempo DTFN ON ISNULL(CAST(OP.FECHA_NOTIFICACION_ORDEN AS DATE), '0001-01-01') = DTFN.fecha
	INNER JOIN dimTiempo DTFR ON CAST(OP.FECHA_REC_PEDIDO AS DATE) = DTFR.fecha
	INNER JOIN dimMonedas DM ON OP.MONEDA_ORDEN = DM.codigoISO	

INSERT INTO hechRecepciones(contrato,numeroRecepcionDefinitiva,fechaRecepcionDefinitiva,moneda,fechaEntregaInicial,
	secuencia,numeroRecepcionProvisional,estadoRecepcionProvisional,precio,diasAdelantoAtraso,estadoRecepcionDefinitiva,
	numeroLinea,entrega,producto,cantidadRealRecibida)
SELECT
	DC.idContrato
	,COALESCE(RC.NRO_RECEP_DEFINITIVA,'N/A')
	,DTRD.idTiempo
	,DM.idMoneda
	,DTEI.idTiempo
	,SECUENCIA
	,COALESCE(NRO_RECEP_PROVISIONAL,'N/A')
	,COALESCE(ESTADO_RECEP_PROVISIONAL,'N/A')
	,precio
	,COALESCE(dias_adelanto_atraso,0)
	,COALESCE(ESTADO_RECEP_DEFINITIVA,'N/A')
	,NRO_LINEA
	,ENTREGA
	,PR.idProducto
	,COALESCE(CANTIDAD_REAL_RECIBIDA,0)
FROM OCPEO.ocpe_synapse_dw.SIC.Recepciones RC
	INNER JOIN OCPEO.ocpe_synapse_dw.SIC.LineasRecibidas LR ON RC.NRO_CONTRATO = LR.NRO_CONTRATO
	INNER JOIN dimContratos DC ON RC.NRO_CONTRATO = DC.numeroContrato
	INNER JOIN dimTiempo DTRD ON ISNULL(RC.FECHA_RECEP_DEFINITIVA, '0001-01-01') = DTRD.fecha
	INNER JOIN dimMonedas DM ON RC.moneda = DM.codigoISO
	INNER JOIN dimTiempo DTEI ON ISNULL(RC.fecha_ent_ini, '0001-01-01') = DTEI.fecha
	INNER JOIN dimClasificacionProductos CL ON SUBSTRING(LR.CODIGO_PRODUCTO, 1, 16) = CONCAT(CL.codigoClasificacion,CL.codigoIdentificacion)
	INNER JOIN dimProductos PR ON CL.idClasificacionProducto = PR.clasificacionProducto
		AND SUBSTRING(LR.CODIGO_PRODUCTO, 17, 8) = PR.codigoProducto

INSERT INTO hechProcAdministrativos(procedimiento, proveedor, numeroProcAdm, fechaNotificacion,
	tipoProcedimientoAdm, multaClausula)
SELECT
	DP.idProcedimiento
	,PV.idProveedor
	,PA.NUMERO_PA
	,DT.idTiempo
	,PA.INHAB_APERC
	,PA.MULTA_CAUSULA
FROM OCPE.ocpe_synapse_dw_copy.SIC.ProcedimientoADM PA
	INNER JOIN dimProcedimientos DP ON PA.NRO_SICOP = DP.nroSICOP
	INNER JOIN dimProveedores PV ON PA.CEDULA_PROVEEDOR = PV.cedulaProveedor
	INNER JOIN dimTiempo DT ON ISNULL(CAST(PA.FECHA_NOTIFICACION AS DATE), '0001-01-01') = DT.fecha

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

---- FINAL SCRIPT ---