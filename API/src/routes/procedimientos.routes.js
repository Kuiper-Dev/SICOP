import {Router} from 'express';
import { getTipoProcedimientos } from '../controllers/procedimientos.controllers';

const router=Router();

router.get('/procedimientos', getTipoProcedimientos);

export default router