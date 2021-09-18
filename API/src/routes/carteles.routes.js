import {Router} from 'express';
import { getDetalleGeneral } from '../controllers/carteles.controllers';
import {getDetalleLineas} from '../controllers/carteles.controllers';
const router=Router();

router.get('/carteles/detalle/general', getDetalleGeneral);
router.get('/carteles/detalle/lineas', getDetalleLineas);

export default router