import { Router } from 'express';
import { asyncWrap } from '../../common/http';
import { auth } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import * as controller from './sales.controller';
import { createSaleSchema } from './sales.schema';

const router = Router();

router.post('/', auth, validate(createSaleSchema), asyncWrap(controller.create));
router.get('/', auth, asyncWrap(controller.listMine));

export default router;
