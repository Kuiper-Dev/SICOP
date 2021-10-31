USE ocpe_dw

CREATE TABLE dimProveedores(
	idProveedor BIGINT PRIMARY KEY NONCLUSTERED NOT ENFORCED IDENTITY(1,1),
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
	idInstitucion BIGINT PRIMARY KEY NONCLUSTERED NOT ENFORCED IDENTITY(1,1),
	cedulaInstitucion VARCHAR(30) NOT NULL,
	nombreInstitucion VARCHAR(200) NOT NULL,
	provinciaInstitucion VARCHAR(30) NOT NULL,
	cantonInstitucion VARCHAR(30) NOT NULL,
	distritoInstitucion VARCHAR(30) NOT NULL,
	fechaIngreso DATE NOT NULL
)

CREATE TABLE dimClasificacionProductos(
	idClasificacionProducto BIGINT PRIMARY KEY NONCLUSTERED NOT ENFORCED IDENTITY(1,1),
	codigoClasificacion VARCHAR(8) NOT NULL,
	codigoIdentificacion VARCHAR(8) NOT NULL,
	descripcionClasificacion VARCHAR(600) NOT NULL
)

CREATE TABLE dimProductos(
	idProducto BIGINT PRIMARY KEY NONCLUSTERED NOT ENFORCED IDENTITY(1,1),
	codigoProducto VARCHAR(8) NOT NULL,
	descripcionProducto VARCHAR(4000) NOT NULL,
	fechaRegistro DATE NOT NULL,
	clasificacionProducto BIGINT NOT NULL -- FOREIGN KEY dimClasificacionProductos(idClasificacionProducto)
)

CREATE TABLE dimProcedimientos(
	idProcedimiento BIGINT PRIMARY KEY NONCLUSTERED NOT ENFORCED IDENTITY(1,1),
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
	institucion BIGINT NOT NULL -- FOREIGN KEY dimInstituciones(idInstitucion)
)

CREATE TABLE dimTiempo(
	idTiempo BIGINT PRIMARY KEY NONCLUSTERED NOT ENFORCED IDENTITY(1,1),
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
	idMoneda INTEGER PRIMARY KEY NONCLUSTERED NOT ENFORCED IDENTITY(1,1),
	descripcionMoneda VARCHAR(40) NOT NULL,
	codigoISO VARCHAR(3) NOT NULL
)

CREATE TABLE dimRepresentantes(
	idRepresentante BIGINT PRIMARY KEY NONCLUSTERED NOT ENFORCED IDENTITY(1,1),
	cedulaRepresentante VARCHAR(30) NOT NULL,
	nombreRepresentante VARCHAR(100) NOT NULL
)

CREATE TABLE dimFuncionarios(
	idFuncionario BIGINT PRIMARY KEY NONCLUSTERED NOT ENFORCED IDENTITY(1,1),
	cedulaFuncionario VARCHAR(30) NOT NULL,
	nombreFuncionario VARCHAR(100) NOT NULL
)

CREATE TABLE dimContratos(
	idContrato BIGINT PRIMARY KEY NONCLUSTERED NOT ENFORCED IDENTITY(1,1),
	numeroContrato VARCHAR(20) NOT NULL, 
	procedimiento BIGINT NOT NULL, -- FOREIGN KEY dimProcedimientos(idProcedimiento)
	institucion BIGINT NOT NULL, -- FOREIGN KEY dimInstituciones(idInstitucion)
	proveedor BIGINT NOT NULL -- FOREIGN KEY dimProveedores(idProveedor)	
)

CREATE TABLE hechCarteles(		
	fechaPublicacion BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	procedimiento BIGINT NOT NULL, -- FOREIGN KEY dimProcedimientos(idProcedimiento)
	fechaApertura BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	clasificacionProducto BIGINT NOT NULL, -- FOREIGN KEY dimClasificacionProductos(idClasificacionProducto)
	moneda INTEGER NOT NULL, -- FOREIGN KEY dimMonedas(idMoneda)	
	numeroLinea SMALLINT NOT NULL,
	numeroPartida SMALLINT NOT NULL,
	cantidadSolicitada INTEGER NOT NULL,
	precioUnitarioEstimado MONEY NOT NULL,
	montoReservado MONEY NOT NULL,
	tipoCambioCRC MONEY NOT NULL,
	tipoCambioUSD MONEY NOT NULL	
)

CREATE TABLE hechInvitaciones(
	institucion BIGINT NOT NULL, -- FOREIGN KEY dimInstituciones(idInstitucion)
	procedimiento BIGINT NOT NULL, -- FOREIGN KEY dimProcedimientos(idProcedimiento)
	proveedor BIGINT NOT NULL, -- FOREIGN KEY dimProveedores(idProveedor)
	fechaInvitacion BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	secuencia VARCHAR(20) NOT NULL
)

CREATE TABLE hechOfertas(	
	proveedor BIGINT NOT NULL, -- FOREIGN KEY dimProveedores(idProveedor)
	fechaPresentacion BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	procedimiento BIGINT NOT NULL, -- FOREIGN KEY dimProcedimientos(idProcedimiento)
	producto BIGINT NOT NULL, -- FOREIGN KEY dimProductos(idProducto)
	moneda INTEGER NOT NULL, -- FOREIGN KEY dimMonedas(idMoneda)
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
	montoTotal MONEY NOT NULL	
)

CREATE TABLE hechCriteriosEvaluacion(
	procedimiento BIGINT NOT NULL, -- FOREIGN KEY dimProcedimientos(idProcedimiento)
	fechaRegistro BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	factorEvaluar VARCHAR(300) NOT NULL,
	porcentajeEvaluacion decimal(6,3) NOT NULL	
)

CREATE TABLE hechAdjudicaciones(
	institucion BIGINT NOT NULL, -- FOREIGN KEY dimInstituciones(idInstitucion)
	procedimiento BIGINT NOT NULL, -- FOREIGN KEY dimProcedimientos(idProcedimiento)
	proveedor BIGINT NOT NULL, -- FOREIGN KEY dimProveedores(idProveedor)
	perfilProveedor VARCHAR(50) NOT NULL,
	numeroLinea SMALLINT NOT NULL,
	representante BIGINT NOT NULL, -- FOREIGN KEY dimRepresentantes(idRepresentante)
	fechaSolicitudContratacion BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	objetoGasto VARCHAR(10) NOT NULL,
	monedaAdjudicada INTEGER NOT NULL, -- FOREIGN KEY dimMonedas(idMoneda)
	montoAdjudicadoLinea MONEY NOT NULL,
	montoAdjudicadoLineaCRC MONEY NOT NULL,
	montoAdjudicadoLineaUSD MONEY NOT NULL,
	fechaAdjudicacionFirme BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	unidadMedida VARCHAR(50) NOT NULL,
	monedaPrecioEstimado INTEGER NOT NULL, -- FOREIGN KEY dimMonedas(idMoneda)
	clasificacionProducto BIGINT NOT NULL, -- FOREIGN KEY dimClasificacionProductos(idClasificacionProducto)
	numeroOferta VARCHAR(50) NOT NULL,
	producto BIGINT NOT NULL, -- FOREIGN KEY dimProductos(idProducto)
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
	desierto VARCHAR(3) NOT NULL
)

CREATE TABLE hechObjeciones(
	procedimiento BIGINT NOT NULL, -- FOREIGN KEY dimProcedimientos(idProcedimiento)
	proveedor BIGINT NOT NULL, -- FOREIGN KEY dimProveedores(idProveedor)
	fechaPresentacion BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	numeroRecurso INTEGER NOT NULL,
	numeroActo SMALLINT NOT NULL,
	lineaObjetada SMALLINT NOT NULL,
	tipoRecurso VARCHAR(10) NOT NULL,
	estadoRecurso VARCHAR(2) NOT NULL,
	resultado VARCHAR(30) NOT NULL,
	causaResultado VARCHAR(100) NOT NULL,
	nombreRecurrente VARCHAR(100) NOT NULL
)

CREATE TABLE hechRemates(
	procedimiento BIGINT NOT NULL, -- FOREIGN KEY dimProcedimientos(idProcedimiento)
	proveedor BIGINT NOT NULL, -- FOREIGN KEY dimProveedores(idProveedor)
	fechaInvitacion BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	monedaPuja INTEGER NOT NULL, -- FOREIGN KEY dimMonedas(idMoneda)
	montoPuja MONEY NOT NULL,
	montoEstimadoLinea MONEY NOT NULL,
	cantidadEstimada INTEGER NOT NULL,
	monedaAdjudicada INTEGER NOT NULL,  -- FOREIGN KEY dimMonedas(idMoneda)	
	montoAdjudicado MONEY NOT NULL,
	cantidadAdjudicada INTEGER NOT NULL,
	tipoCambioMoneda MONEY NOT NULL		
)

CREATE TABLE hechContrataciones(
	contrato BIGINT NOT NULL, -- FOREIGN KEY dimContratos(idContrato)
	procedimiento BIGINT NOT NULL, -- FOREIGN KEY dimProcedimientos(idProcedimiento)
	secuencia VARCHAR(3) NOT NULL,
	proveedor BIGINT NOT NULL, -- FOREIGN KEY dimProveedores(idProveedor)
	fechaInicioProrroga BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	fechaFinalProrroga BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	vigencia VARCHAR(20) NOT NULL,	
	fechaInicioSuspension BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	fechaReanudacionContrato BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	plazoSuspension INTEGER NOT NULL,
	tipoContrato VARCHAR(10) NOT NULL,
	tipoModificacion VARCHAR(100) NOT NULL,
	fechaModificacion BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	fechaNotificacion BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	fechaElaboracion BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
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
	producto BIGINT NOT NULL, -- FOREIGN KEY dimProductos(idProducto)
	cantidadContratada INTEGER NOT NULL,
	precioUnitario MONEY NOT NULL,
	moneda INTEGER NOT NULL, -- FOREIGN KEY dimMonedas(idMoneda)
	descuento MONEY NOT NULL,
	IVA MONEY NOT NULL	
)

CREATE TABLE hechGarantias(
	procedimiento BIGINT NOT NULL, -- FOREIGN KEY dimProcedimientos(idProcedimiento)
	fechaRegistro BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	proveedor BIGINT NOT NULL, -- FOREIGN KEY dimProveedores(idProveedor)
	numeroGarantia VARCHAR(30) NOT NULL,
	cedulaGarante VARCHAR(10) NOT NULL,
	secuenciaGarantia VARCHAR(3) NOT NULL,
	tipoGarantia VARCHAR(30) NOT NULL,
	monto MONEY NOT NULL,
	estado VARCHAR(50) NOT NULL,
	vigencia BIGINT NOT NULL -- FOREIGN KEY dimTiempo(idTiempo)	
)

CREATE TABLE hechReajustesPrecio(
	procedimiento BIGINT NOT NULL, -- FOREIGN KEY dimProcedimientos(idProcedimiento)
	proveedor BIGINT NOT NULL, -- FOREIGN KEY dimProveedores(idProveedor)
	fechaInicio BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	fechaFin BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	mesesAAplicar SMALLINT NOT NULL,
	diasAAplicar SMALLINT NOT NULL,
	moneda INTEGER NOT NULL, -- FOREIGN KEY dimMonedas(idMoneda)
	montoTotal MONEY NOT NULL,
	precioUnitario MONEY NOT NULL,
	numeroReajuste SMALLINT NOT NULL,
	precioAnteriorUltimoReajuste MONEY NOT NULL,
	montoReajuste MONEY NOT NULL,
	nuevoPrecio MONEY NOT NULL,
	porcentajeIncrementoUltimoReajuste DECIMAL(5,2) NOT NULL,
	fechaElaboracion BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	producto BIGINT NOT NULL, -- FOREIGN KEY dimProductos(idProducto)
	contrato BIGINT NOT NULL, -- FOREIGN KEY dimContratos(idContrato)
	numeroLineaContrato SMALLINT NOT NULL,
	cantidadContratada INTEGER NOT NULL
)

CREATE TABLE hechOrdenesPedido(
	contrato BIGINT NOT NULL, -- FOREIGN KEY dimContratos(idContrato)
	secuenciaContrato VARCHAR(3) NOT NULL,
	numeroOrden VARCHAR(16) NOT NULL,
	fechaElaboracion BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	fechaNotificacion BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	fechaRecepcionPedido BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	lineaOrdenPedido SMALLINT NOT NULL,
	secuenciaOrden VARCHAR(3) NOT NULL,
	moneda INTEGER NOT NULL, -- FOREIGN KEY dimMonedas(idMoneda)
	totalOrden MONEY NOT NULL,
	totalEstimado MONEY NOT NULL,
	montoUSD MONEY NOT NULL,
	estadoOrden VARCHAR(50) NOT NULL
)

CREATE TABLE hechRecepciones(
	contrato BIGINT NOT NULL, -- FOREIGN KEY dimContratos(idContrato)
	numeroRecepcionDefinitiva VARCHAR(30) NOT NULL,
	fechaRecepcionDefinitiva BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	moneda INTEGER NOT NULL, -- FOREIGN KEY dimMonedas(idMoneda)
	fechaEntregaInicial BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	secuencia VARCHAR(3) NOT NULL,
	numeroRecepcionProvisional VARCHAR(30) NOT NULL,
	estadoRecepcionProvisional VARCHAR(50) NOT NULL,
	precio MONEY NOT NULL,
	diasAdelantoAtraso INTEGER NOT NULL,
	estadoRecepcionDefinitiva VARCHAR(50) NOT NULL,
	numeroLinea SMALLINT NOT NULL,
	entrega SMALLINT NOT NULL,
	producto BIGINT NOT NULL, -- FOREIGN KEY dimProductos(idProducto)
	cantidadRealRecibida INTEGER NOT NULL	
)

CREATE TABLE hechProcAdministrativos(
	procedimiento BIGINT NOT NULL, -- FOREIGN KEY dimProcedimientos(idProcedimiento)
	proveedor BIGINT NOT NULL, -- FOREIGN KEY dimProveedores(idProveedor)
	numeroProcAdm VARCHAR(30) NOT NULL,
	fechaNotificacion BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	tipoProcedimientoAdm VARCHAR(30) NOT NULL, 
	multaClausula VARCHAR(30) NOT NULL	
)

CREATE TABLE hechSanciones(
	institucion BIGINT NOT NULL, -- FOREIGN KEY dimInstituciones(idInstitucion)
	proveedor BIGINT NOT NULL, -- FOREIGN KEY dimProveedores(idProveedor)
	fechaRegistro BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	fechaInicioSancion BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	fechaFinalSancion BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	codigoProducto VARCHAR(8) NOT NULL,
	descripcionProducto VARCHAR(200) NOT NULL,
	tipoSancion	VARCHAR(30) NOT NULL,
	descripcionSancion VARCHAR(1000) NOT NULL,
	estadoSancion VARCHAR(3) NOT NULL,
	numeroResolucion VARCHAR(30) NOT NULL
)

CREATE TABLE hechInhibicionesFuncionario(
	institucion BIGINT NOT NULL, -- FOREIGN KEY dimInstituciones(idInstitucion)
	funcionario BIGINT NOT NULL, -- FOREIGN KEY dimFuncionarios(idFuncionario)
	fechaRegistro BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	fechaInicioInhibicion BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	fechaFinalInhibicion BIGINT NOT NULL, -- FOREIGN KEY dimTiempo(idTiempo)
	estadoInhibicion VARCHAR(10) NOT NULL			
)

---- FINAL SCRIPT ---