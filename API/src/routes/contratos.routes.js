import {Router} from 'express';
import { getContratos } from '../controllers/contratos.controllers';
import { getContratoAdicional } from '../controllers/contratos.controllers';
import { getLineasContratos } from '../controllers/contratos.controllers';
const router=Router();

router.get('/contratos', getContratos);
router.get('/contratos/lineas', getLineasContratos);
router.get('/contratos/adicional', getContratoAdicional);
export default router