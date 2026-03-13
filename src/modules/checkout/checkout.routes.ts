import { Router } from 'express';
import { asyncWrap } from '../../common/http';
import { Role } from '../../common/enums';
import { auth } from '../../middleware/auth';
import { allowRoles } from '../../middleware/role';
import { validate } from '../../middleware/validate';
import * as controller from './checkout.controller';
import { createCheckoutSchema } from './checkout.schema';
import { confirmCheckoutParamsSchema, rejectCheckoutSchema } from './checkout.admin.schema';

const router = Router();

router.post('/', auth, validate(createCheckoutSchema), asyncWrap(controller.create));
router.get('/', auth, allowRoles(Role.ADMIN), asyncWrap(controller.list));
router.post('/:id/confirm', auth, allowRoles(Role.ADMIN), validate(confirmCheckoutParamsSchema, 'params'), asyncWrap(controller.confirm));
router.post('/:id/reject', auth, allowRoles(Role.ADMIN), validate(confirmCheckoutParamsSchema, 'params'), validate(rejectCheckoutSchema), asyncWrap(controller.reject));

export default router;
