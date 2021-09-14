USE dw_sicop

CREATE TABLE dimProveedores(
	idProveedor BIGINT PRIMARY KEY IDENTITY(1,1),
	cedulaProveedor VARCHAR(30) NOT NULL,
	nombreProveedor VARCHAR(200) NOT NULL,
	tipoProveedor VARCHAR(50) NOT NULL,
	tamanoProveedor VARCHAR(30) NOT NULL,
	provinciaProveedor VARCHAR(30) NOT NULL,
	cantonProveedor VARCHAR(30) NOT NULL,
	distritoProveedor VARCHAR(30) NOT NULL,
	fechaConstitucion DATE NOT NULL,
	fechaRegistro DATE NOT NULL
)

CREATE TABLE dimInstituciones(
	idInstitucion BIGINT PRIMARY KEY IDENTITY(1,1),
	cedulaInstitucion VARCHAR(30) NOT NULL,
	nombreInstitucion VARCHAR(200) NOT NULL,
	provinciaInstitucion VARCHAR(30) NOT NULL,
	cantonInstitucion VARCHAR(30) NOT NULL,
	distritoInstitucion VARCHAR(30) NOT NULL,
	fechaIngreso DATE NOT NULL
)

CREATE TABLE dimClasificacionProductos(
	idClasificacionProducto BIGINT PRIMARY KEY IDENTITY(1,1),
	codigoClasificacion VARCHAR(8) NOT NULL,
	codigoIdentificacion VARCHAR(8) NOT NULL,
	descripcionClasificacion VARCHAR(600) NOT NULL
)

CREATE TABLE dimProductos(
	idProducto BIGINT PRIMARY KEY IDENTITY(1,1),
	codigoProducto VARCHAR(8) NOT NULL,
	descripcionProducto VARCHAR(4000) NOT NULL,
	fechaRegistro DATE NOT NULL,
	clasificacionProducto BIGINT NOT NULL,
	CONSTRAINT fk_dimProductos_dimClasificacionProductos FOREIGN KEY (clasificacionProducto)
		REFERENCES dimClasificacionProductos(idClasificacionProducto)
)

CREATE TABLE dimProcedimientos(
	idProcedimiento BIGINT PRIMARY KEY IDENTITY(1,1),
	numeroProcedimiento VARCHAR(50) NOT NULL,
	tipoProcedimiento VARCHAR(50) NOT NULL,
	modalidadProcedimiento VARCHAR(100) NOT NULL,
	descripcionProcedimiento VARCHAR(200) NOT NULL,
	descripcionExcepcion VARCHAR(1000) NOT NULL,
	codigoExcepcion VARCHAR(8) NOT NULL,
	estadoProcedimiento VARCHAR(30) NOT NULL,
	codigoBPIP VARCHAR(20) NOT NULL,
	clasificacion VARCHAR(50) NOT NULL,
	nroSICOP varchar(11) NOT NULL,
	institucion BIGINT NOT NULL
)

CREATE TABLE dimTiempo(
	idTiempo BIGINT PRIMARY KEY IDENTITY(1,1),
	fecha DATE NOT NULL,
	dia SMALLINT NOT NULL,
	mes SMALLINT NOT NULL,
	ano SMALLINT NOT NULL,
	trimestre SMALLINT NOT NULL,
	semestre SMALLINT NOT NULL,
	semana SMALLINT NOT NULL,
	diaAno SMALLINT NOT NULL,
	diaSemana SMALLINT NOT NULL
)


CREATE TABLE dimMonedas(
	idMoneda INTEGER PRIMARY KEY IDENTITY(1,1),
	descripcionMoneda VARCHAR(40) NOT NULL,
	codigoISO VARCHAR(3) NOT NULL
)

CREATE TABLE dimRepresentantes(
	idRepresentante BIGINT PRIMARY KEY IDENTITY(1,1),
	cedulaRepresentante VARCHAR(30) NOT NULL,
	nombreRepresentante VARCHAR(100) NOT NULL
)

CREATE TABLE dimFuncionarios(
	idFuncionario BIGINT PRIMARY KEY IDENTITY(1,1),
	cedulaFuncionario VARCHAR(30) NOT NULL,
	nombreFuncionario VARCHAR(100) NOT NULL
)

CREATE TABLE dimContratos(
	idContrato BIGINT PRIMARY KEY IDENTITY(1,1),
	numeroContrato VARCHAR(20) NOT NULL,
	procedimiento BIGINT NOT NULL,
	institucion BIGINT NOT NULL,
	proveedor BIGINT NOT NULL
	CONSTRAINT fk_dimContratos_dimProcedimientos FOREIGN KEY (procedimiento)
		REFERENCES dimProcedimientos(idProcedimiento),
	CONSTRAINT fk_dimContratos_dimInstituciones FOREIGN KEY (institucion)
		REFERENCES dimInstituciones(idInstitucion),
	CONSTRAINT fk_dimContratos_dimProveedor FOREIGN KEY (proveedor)
		REFERENCES dimProveedores(idProveedor)
)

CREATE TABLE hechCarteles(		
	fechaPublicacion BIGINT NOT NULL,
	procedimiento BIGINT NOT NULL,
	fechaApertura BIGINT NOT NULL,
	clasificacionProducto BIGINT NOT NULL,
	moneda INTEGER NOT NULL,
	numeroLinea SMALLINT NOT NULL,
	numeroPartida SMALLINT NOT NULL,
	cantidadSolicitada INTEGER NOT NULL,
	precioUnitarioEstimado MONEY NOT NULL,
	montoReservado MONEY NOT NULL,
	tipoCambioCRC MONEY NOT NULL,
	tipoCambioUSD MONEY NOT NULL,
	--CONSTRAINT pk_hechCarteles PRIMARY KEY (institucion, fechaPublicacion,
		--procedimiento, fechaApertura, clasificacionProducto, moneda),	
	CONSTRAINT fk_hechCarteles_dimTiempoP FOREIGN KEY (fechaPublicacion) 
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechCarteles_dimProcedimientos FOREIGN KEY (procedimiento) 
		REFERENCES dimProcedimientos(idProcedimiento),
	CONSTRAINT fk_hechCarteles_dimTiempoA FOREIGN KEY (fechaApertura) 
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechCarteles_dimClasificacionProductos FOREIGN KEY (clasificacionProducto)
		REFERENCES dimClasificacionProductos(idClasificacionProducto),
	CONSTRAINT fk_hechCarteles_dimMonedas FOREIGN KEY (moneda) 
		REFERENCES dimMonedas(idMoneda)	
)

CREATE TABLE hechInvitaciones(
	institucion BIGINT NOT NULL,
	procedimiento BIGINT NOT NULL,
	proveedor BIGINT NOT NULL,
	fechaInvitacion BIGINT NOT NULL,
	secuencia VARCHAR(20) NOT NULL,
	--CONSTRAINT pk_hechInvitaciones PRIMARY KEY (institucion,procedimiento,
		--proveedor,fechaInvitacion),
	CONSTRAINT fk_hechosInvitaciones_dimInstituciones FOREIGN KEY (institucion)
		REFERENCES dimInstituciones(idInstitucion),
	CONSTRAINT fk_hechosInvitaciones_dimProcedimientos FOREIGN KEY (procedimiento)
		REFERENCES dimProcedimientos(idProcedimiento),
	CONSTRAINT fk_hechosInvitaciones_dimProveedores FOREIGN KEY (proveedor)
		REFERENCES dimProveedores(idProveedor),
	CONSTRAINT fk_hechosInvitaciones_dimTiempo FOREIGN KEY (fechaInvitacion)
		REFERENCES dimTiempo(idTiempo)
)

CREATE TABLE hechOfertas(	
	proveedor BIGINT NOT NULL,
	fechaPresentacion BIGINT NOT NULL,
	procedimiento BIGINT NOT NULL,
	producto BIGINT NOT NULL,
	moneda INTEGER NOT NULL,
	tipoOferta VARCHAR(30) NOT NULL,
	numeroLinea SMALLINT NOT NULL,
	numeroOferta VARCHAR(50) NOT NULL,
	cantidadOfertada INTEGER NOT NULL,
	precioUnitarioOfertado MONEY NOT NULL,
	descuento MONEY NOT NULL,
	IVAUnidad MONEY NOT NULL,
	acarreos MONEY NOT NULL,
	IVAAcarreos MONEY NOT NULL,
	otrosImpuestos MONEY NOT NULL,	
	tipoCambioCRC MONEY NOT NULL,
	tipoCambioUSD MONEY NOT NULL,
	montoTotal MONEY NOT NULL,
	--CONSTRAINT pk_hechOfertas PRIMARY KEY (proveedor, fechaPresentacion,
		--procedimiento, producto, moneda),
	CONSTRAINT fk_hechOfertas_dimProveedores FOREIGN KEY (proveedor) 
		REFERENCES dimProveedores(idProveedor),
	CONSTRAINT fk_hechOfertas_dimTiempo FOREIGN KEY (fechaPresentacion) 
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechOfertas_dimProcedimientos FOREIGN KEY (procedimiento) 
		REFERENCES dimProcedimientos(idProcedimiento),
	CONSTRAINT fk_hechOfertas_dimProductos FOREIGN KEY (producto) 
		REFERENCES dimProductos(idProducto),	
	CONSTRAINT fk_hechOfertas_dimMonedas FOREIGN KEY (moneda) 
		REFERENCES dimMonedas(idMoneda)	
)

CREATE TABLE hechCriteriosEvaluacion(
	procedimiento BIGINT NOT NULL,
	fechaRegistro BIGINT NOT NULL,
	factorEvaluar VARCHAR(300) NOT NULL,
	porcentajeEvaluacion decimal(6,3) NOT NULL,		
	--CONSTRAINT pk_hechCriteriosEvaluacion PRIMARY KEY (proveedor, fechaRegistro),	
	CONSTRAINT fk_hechCriteriosEvaluacion_dimTiempo FOREIGN KEY (fechaRegistro) 
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechCriteriosEvaluacion_dimProcedimientos FOREIGN KEY (procedimiento) 
		REFERENCES dimProcedimientos(idProcedimiento)
)

CREATE TABLE hechAdjudicaciones(
	institucion BIGINT NOT NULL,
	procedimiento BIGINT NOT NULL,
	proveedor BIGINT NOT NULL,
	perfilProveedor VARCHAR(50) NOT NULL,
	numeroLinea SMALLINT NOT NULL,
	representante BIGINT NOT NULL,
	fechaSolicitudContratacion BIGINT NOT NULL,
	objetoGasto VARCHAR(10) NOT NULL,
	monedaAdjudicada INTEGER NOT NULL,
	montoAdjudicadoLinea MONEY NOT NULL,
	montoAdjudicadoLineaCRC MONEY NOT NULL,
	montoAdjudicadoLineaUSD MONEY NOT NULL,
	fechaAdjudicacionFirme BIGINT NOT NULL,
	unidadMedida VARCHAR(50) NOT NULL,
	monedaPrecioEstimado INTEGER NOT NULL,
	clasificacionProducto BIGINT NOT NULL,
	numeroOferta VARCHAR(50) NOT NULL,
	producto BIGINT NOT NULL,
	numeroActo INTEGER NOT NULL,
	cantidadAdjudicada INTEGER NOT NULL,
	precioUnitarioAdjudicado MONEY NOT NULL,
	acarreo MONEY NOT NULL,
	descuento MONEY NOT NULL,
	IVA MONEY NOT NULL,
	otroImpuesto MONEY NOT NULL,
	tipoCambioCRC MONEY NOT NULL,
	tipoCambioUSD MONEY NOT NULL,
	permiteRecursos VARCHAR(3) NOT NULL,
	desierto VARCHAR(3) NOT NULL,	
	-- CONSTRAINT pk_,	
	CONSTRAINT fk_hechAdjudicaciones_dimInstituciones FOREIGN KEY (institucion)
		REFERENCES dimInstituciones(idInstitucion),
	CONSTRAINT fk_hechAdjudicaciones_dimProcedimientos FOREIGN KEY (procedimiento)
		REFERENCES dimProcedimientos(idProcedimiento),
	CONSTRAINT fk_hechAdjudicaciones_dimProveedores FOREIGN KEY (proveedor)
		REFERENCES dimProveedores(idProveedor),
	CONSTRAINT fk_hechAdjudicaciones_dimRepresentantes FOREIGN KEY (representante)
		REFERENCES dimRepresentantes(idRepresentante),
	CONSTRAINT fk_hechAdjudicaciones_dimTiempoSC FOREIGN KEY (fechaSolicitudContratacion)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechAdjudicaciones_dimTiempoAF FOREIGN KEY (fechaAdjudicacionFirme)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechAdjudicaciones_dimMonedasA FOREIGN KEY (monedaAdjudicada)
		REFERENCES dimMonedas(idMoneda),
	CONSTRAINT fk_hechAdjudicaciones_dimMonedasE FOREIGN KEY (monedaPrecioEstimado)
		REFERENCES dimMonedas(idMoneda),
	CONSTRAINT fk_hechAdjudicaciones_dimProductos FOREIGN KEY (producto)
		REFERENCES dimProductos(idProducto),
	CONSTRAINT fk_hechAdjudicaciones_dimClasificacionProductos FOREIGN KEY (clasificacionProducto)
		REFERENCES dimClasificacionProductos(idClasificacionProducto)
)

CREATE TABLE hechObjeciones(	
	procedimiento BIGINT NOT NULL,
	proveedor BIGINT NOT NULL,
	fechaPresentacion BIGINT NOT NULL,
	numeroRecurso INTEGER NOT NULL,
	numeroActo SMALLINT NOT NULL,
	lineaObjetada SMALLINT NOT NULL,
	tipoRecurso VARCHAR(10) NOT NULL,
	estadoRecurso VARCHAR(2) NOT NULL,
	resultado VARCHAR(30) NOT NULL,
	causaResultado VARCHAR(100) NOT NULL,
	nombreRecurrente VARCHAR(100) NOT NULL,	
	--CONSTRAINT pk_hechOfertas PRIMARY KEY (procedimiento, proveedor, fechaPresentacion),
	CONSTRAINT fk_hechObjeciones_dimProveedores FOREIGN KEY (proveedor) 
		REFERENCES dimProveedores(idProveedor),
	CONSTRAINT fk_hechObjeciones_dimTiempo FOREIGN KEY (fechaPresentacion) 
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechObjeciones_dimProcedimientos FOREIGN KEY (procedimiento) 
		REFERENCES dimProcedimientos(idProcedimiento)	
)

CREATE TABLE hechRemates(
	procedimiento BIGINT NOT NULL,
	proveedor BIGINT NOT NULL,
	fechaInvitacion BIGINT NOT NULL,
	monedaPuja INTEGER NOT NULL,
	montoPuja MONEY NOT NULL,
	montoEstimadoLinea MONEY NOT NULL,
	cantidadEstimada INTEGER NOT NULL,
	monedaAdjudicada INTEGER NOT NULL,
	montoAdjudicado MONEY NOT NULL,
	cantidadAdjudicada INTEGER NOT NULL,
	tipoCambioMoneda MONEY NOT NULL,	
	-- CONSTRAINT pk_,		
	CONSTRAINT fk_hechRemates_dimProcedimientos FOREIGN KEY (procedimiento)
		REFERENCES dimProcedimientos(idProcedimiento),
	CONSTRAINT fk_hechRemates_dimProveedores FOREIGN KEY (proveedor)
		REFERENCES dimProveedores(idProveedor),	
	CONSTRAINT fk_hechRemates_dimTiempo FOREIGN KEY (fechaInvitacion)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechRemates_dimMonedasA FOREIGN KEY (monedaAdjudicada)
		REFERENCES dimMonedas(idMoneda),
	CONSTRAINT fk_hechRemates_dimMonedasP FOREIGN KEY (monedaPuja)
		REFERENCES dimMonedas(idMoneda)	
)

CREATE TABLE hechContrataciones(
	contrato BIGINT NOT NULL,
	procedimiento BIGINT NOT NULL,
	secuencia VARCHAR(3) NOT NULL,
	proveedor BIGINT NOT NULL,
	fechaInicioProrroga BIGINT NOT NULL,
	fechaFinalProrroga BIGINT NOT NULL,
	vigencia VARCHAR(20) NOT NULL,
	moneda INTEGER NOT NULL,
	fechaInicioSuspension BIGINT NOT NULL,
	fechaReanudacionContrato BIGINT NOT NULL,
	plazoSuspension INTEGER NOT NULL,
	tipoContrato VARCHAR(10) NOT NULL,
	tipoModificacion VARCHAR(100) NOT NULL,
	fechaModificacion BIGINT NOT NULL,
	fechaNotificacion BIGINT NOT NULL,
	fechaElaboracion BIGINT NOT NULL,
	tipoAutorizacion VARCHAR(50) NOT NULL,
	tipoDisminucion VARCHAR(8) NOT NULL,
	numeroLineaContrato SMALLINT NOT NULL,
	numeroLineaCartel SMALLINT NOT NULL,
	cantidadAumentada FLOAT NOT NULL,
	cantidadDisminuida FLOAT NOT NULL,
	montoAumentado MONEY NOT NULL,
	montoDisminuido MONEY NOT NULL,
	otrosImpuestos MONEY NOT NULL,
	acarreos	MONEY NOT NULL,
	tipoCambioCRC	MONEY NOT NULL,
	tipoCambioUSD MONEY NOT NULL,
	numeroActo	INTEGER NOT NULL,
	producto BIGINT NOT NULL,
	cantidadContratada INTEGER NOT NULL,
	precioUnitario MONEY NOT NULL,
	moneda INTEGER NOT NULL,
	descuento MONEY NOT NULL,
	IVA MONEY NOT NULL,
	-- CONSTRAINT pk_,
	CONSTRAINT fk_hechContrataciones_dimContratos FOREIGN KEY (contrato)
		REFERENCES dimContratos(idContrato),
	CONSTRAINT fk_hechContrataciones_dimProcedimientos FOREIGN KEY (procedimiento)
		REFERENCES dimProcedimientos(idProcedimiento),
	CONSTRAINT fk_hechContrataciones_dimProveedores FOREIGN KEY (proveedor)
		REFERENCES dimProveedores(idProveedor),
	CONSTRAINT fk_hechContrataciones_dimTiempoIP FOREIGN KEY (fechaInicioProrroga)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechContrataciones_dimTiempoFP FOREIGN KEY (fechaFinalProrroga)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechContrataciones_dimTiempoIS FOREIGN KEY (fechaInicioSuspension)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechContrataciones_dimTiempoRC FOREIGN KEY (fechaReanudacionContrato)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechContrataciones_dimTiempoFM FOREIGN KEY (fechaModificacion)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechContrataciones_dimTiempoFN FOREIGN KEY (fechaNotificacion)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechContrataciones_dimTiempoFE FOREIGN KEY (fechaElaboracion)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechContrataciones_dimProductos FOREIGN KEY (producto)
		REFERENCES	dimProductos(idProducto),
	CONSTRAINT fk_Contrataciones_dimMonedas FOREIGN KEY	(moneda)
		REFERENCES dimMonedas(idMoneda)
)

CREATE TABLE hechGarantias(
	procedimiento BIGINT NOT NULL,
	fechaRegistro BIGINT NOT NULL,
	proveedor BIGINT NOT NULL,
	numeroGarantia VARCHAR(30) NOT NULL,
	cedulaGarante VARCHAR(10) NOT NULL,
	secuenciaGarantia VARCHAR(3) NOT NULL,
	tipoGarantia VARCHAR(30) NOT NULL,
	monto MONEY NOT NULL,
	estado VARCHAR(50) NOT NULL,
	vigencia BIGINT NOT NULL,
	--CONSTRAINT pk_hechGarantias,
	CONSTRAINT fk_hechGarantias_dimProcedimientos FOREIGN KEY (procedimiento)
		REFERENCES dimProcedimientos(idProcedimiento),
	CONSTRAINT fk_hechGarantias_dimTiempo FOREIGN KEY (fechaRegistro)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechGarantias_dimProveedores FOREIGN KEY (proveedor)
		REFERENCES dimProveedores(idProveedor),
	CONSTRAINT fk_hechGarantias_dimTiempoV FOREIGN KEY (vigencia)
		REFERENCES dimTiempo(idTiempo)
)

CREATE TABLE hechReajustesPrecio(
	procedimiento BIGINT NOT NULL,
	proveedor BIGINT NOT NULL,
	fechaInicio BIGINT NOT NULL,
	fechaFin BIGINT NOT NULL,
	mesesAAplicar SMALLINT NOT NULL,
	diasAAplicar SMALLINT NOT NULL,
	moneda INTEGER NOT NULL,
	montoTotal MONEY NOT NULL,
	precioUnitario MONEY NOT NULL,
	numeroReajuste SMALLINT NOT NULL,
	precioAnteriorUltimoReajuste MONEY NOT NULL,
	montoReajuste MONEY NOT NULL,
	nuevoPrecio MONEY NOT NULL,
	porcentajeIncrementoUltimoReajuste DECIMAL(5,2) NOT NULL,
	fechaElaboracion BIGINT NOT NULL,
	producto BIGINT NOT NULL,
	contrato BIGINT NOT NULL,
	numeroLineaContrato SMALLINT NOT NULL,
	cantidadContratada INTEGER NOT NULL,
	--CONSTRAINT pk_hechReajustesPrecio
	CONSTRAINT fk_hechReajustesPrecio_dimProcedimientos FOREIGN KEY (procedimiento)
		REFERENCES dimProcedimientos(idProcedimiento),
	CONSTRAINT fk_hechReajustesPrecio_dimProveedores FOREIGN KEY (proveedor)
		REFERENCES dimProveedores(idProveedor),
	CONSTRAINT fk_hechReajustesPrecio_dimTiempoI FOREIGN KEY (fechaInicio)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechReajustesPrecio_dimTiempoF FOREIGN KEY (fechaFin)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechReajustesPrecio_dimTiempoE FOREIGN KEY (fechaElaboracion)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechReajustesPrecio_dimMonedas FOREIGN KEY (moneda)
		REFERENCES dimMonedas(idMoneda),
	CONSTRAINT fk_hechReajustesPrecio_dimProductos FOREIGN KEY (producto)
		REFERENCES dimProductos(idProducto),
	CONSTRAINT fk_hechREajustesPrecio_dimContratos FOREIGN KEY (contrato)
		REFERENCES dimContratos(idContrato)
)

CREATE TABLE hechOrdenesPedido(
	contrato BIGINT NOT NULL,
	secuenciaContrato VARCHAR(3) NOT NULL,
	numeroOrden VARCHAR(16) NOT NULL,
	fechaElaboracion BIGINT NOT NULL,
	fechaNotificacion BIGINT NOT NULL,
	fechaRecepcionPedido BIGINT NOT NULL, 
	lineaOrdenPedido SMALLINT NOT NULL,
	secuenciaOrden VARCHAR(3) NOT NULL,
	moneda INTEGER NOT NULL,
	totalOrden MONEY NOT NULL,
	totalEstimado MONEY NOT NULL,
	montoUSD MONEY NOT NULL,
	estadoOrden VARCHAR(50) NOT NULL,
	--CONSTRAINT pk_hechOrdenesPedido
	CONSTRAINT fk_hechOrdenesPedido_dimContratos FOREIGN KEY (contrato)
		REFERENCES dimContratos(idContrato),
	CONSTRAINT fk_hechOrdenesPedido_dimTiempoFE FOREIGN KEY (fechaElaboracion)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechOrdenesPedido_dimTiempoFN FOREIGN KEY (fechaNotificacion)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechOrdenesPedido_dimTiempoFR FOREIGN KEY (fechaRecepcionPedido)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechOrdenesPedido_dimMonedas FOREIGN KEY (moneda)
		REFERENCES dimMonedas(idMoneda)
)

CREATE TABLE hechRecepciones(
	contrato BIGINT NOT NULL,
	numeroRecepcionDefinitiva VARCHAR(30) NOT NULL,
	fechaRecepcionDefinitiva BIGINT NOT NULL,
	moneda INTEGER NOT NULL,
	fechaEntregaInicial BIGINT NOT NULL,
	secuencia VARCHAR(3) NOT NULL,
	numeroRecepcionProvisional VARCHAR(30) NOT NULL,
	estadoRecepcionProvisional VARCHAR(50) NOT NULL,
	precio MONEY NOT NULL,
	diasAdelantoAtraso INTEGER NOT NULL,
	estadoRecepcionDefinitiva VARCHAR(50) NOT NULL,
	numeroLinea SMALLINT NOT NULL,
	entrega SMALLINT NOT NULL,
	producto BIGINT NOT NULL,
	cantidadRealRecibida INTEGER NOT NULL,
	--CONSTRAINT pk_hechRecepciones,
	CONSTRAINT fk_hechRecepciones_dimContratos FOREIGN KEY (contrato)
		REFERENCES dimContratos(idContrato),
	CONSTRAINT fk_hechRecepciones_dimTiempoRD FOREIGN KEY (fechaRecepcionDefinitiva)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechRecepciones_dimTiempoEI FOREIGN KEY (fechaEntregaInicial)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechRecepciones_dimMonedas FOREIGN KEY (moneda)
		REFERENCES dimMonedas(idMoneda),
	CONSTRAINT fk_hechRecepciones_dimProductos FOREIGN KEY (producto)
		REFERENCES dimProductos(idProducto),
)

CREATE TABLE hechProcAdministrativos(
	procedimiento BIGINT NOT NULL,
	proveedor BIGINT NOT NULL,
	numeroProcAdm VARCHAR(30) NOT NULL,
	fechaNotificacion BIGINT NOT NULL,
	tipoProcedimientoAdm VARCHAR(30) NOT NULL, 
	multaClausula VARCHAR(30) NOT NULL, 
	--CONSTRAINT pk_hechProcAdministrativos,
	CONSTRAINT fk_hechProcAdministrativos_dimProcedimientos FOREIGN KEY (procedimiento)
		REFERENCES dimProcedimientos(idProcedimiento),
	CONSTRAINT fk_hechProcAdministrativos_dimTiempo FOREIGN KEY (fechaNotificacion)
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechProcAdministrativos_dimProveedores FOREIGN KEY (proveedor)
		REFERENCES dimProveedores(idProveedor)
)

CREATE TABLE hechSanciones(
	institucion BIGINT NOT NULL,
	proveedor BIGINT NOT NULL,
	fechaRegistro BIGINT NOT NULL,
	fechaInicioSancion BIGINT NOT NULL,
	fechaFinalSancion BIGINT NOT NULL,
	codigoProducto VARCHAR(8) NOT NULL,
	descripcionProducto VARCHAR(200) NOT NULL,
	tipoSancion	VARCHAR(30) NOT NULL,
	descripcionSancion VARCHAR(1000),
	estadoSancion VARCHAR(3) NOT NULL,
	numeroResolucion VARCHAR(30) NOT NULL,
	--CONSTRAINT pk_hechSanciones PRIMARY KEY (institucion, proveedor, fechaRegistro
		--fechaInicioSancion, fechaFinalSancion),	
	CONSTRAINT fk_hechSanciones_dimInstituciones FOREIGN KEY (institucion)
		REFERENCES dimInstituciones(idInstitucion),
	CONSTRAINT fk_hechSanciones_dimProveedores FOREIGN KEY (proveedor)
		REFERENCES dimProveedores(idProveedor),
	CONSTRAINT fk_hechSanciones_dimTiempoR FOREIGN KEY (fechaRegistro) 
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechSanciones_dimTiempoI FOREIGN KEY (fechaInicioSancion) 
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechSanciones_dimTiempoF FOREIGN KEY (fechaFinalSancion) 
		REFERENCES dimTiempo(idTiempo)
)

CREATE TABLE hechInhibicionesFuncionario(
	institucion BIGINT NOT NULL,
	funcionario BIGINT NOT NULL,
	fechaRegistro BIGINT NOT NULL,
	fechaInicioInhibicion BIGINT NOT NULL,
	fechaFinalInhibicion BIGINT NOT NULL,		
	estadoInhibicion VARCHAR(3) NOT NULL,	
	--CONSTRAINT pk_hechSanciones PRIMARY KEY (institucion, funcionario, fechaRegistro
		--fechaInicioInhibicion, fechaFinalInhibicion),	
	CONSTRAINT fk_hechInhibicionesFuncionario_dimInstituciones FOREIGN KEY (institucion)
		REFERENCES dimInstituciones(idInstitucion),
	CONSTRAINT fk_hechInhibicionesFuncionario_dimFuncionarios FOREIGN KEY (funcionario)
		REFERENCES dimFuncionarios(idFuncionario),
	CONSTRAINT fk_hechInhibicionesFuncionario_dimTiempoR FOREIGN KEY (fechaRegistro) 
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechInhibicionesFuncionario_dimTiempoI FOREIGN KEY (fechaInicioInhibicion) 
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechInhibicionesFuncionario_dimTiempoF FOREIGN KEY (fechaFinalInhibicion) 
		REFERENCES dimTiempo(idTiempo)
)

---- FINAL SCRIPT ---