import {Router} from 'express';
import { getInstitucionesJSON } from '../controllers/json.download.controllers';
import { getProcedimientosJSON } from '../controllers/json.download.controllers';
import { getProveedoresJSON } from '../controllers/json.download.controllers';
const router=Router();

router.get('/descargas/json/:id', getInstitucionesJSON);
router.get('/descargas/json/:id', getProcedimientosJSON);
router.get('/descargas/json/:id', getProveedoresJSON);
export default router