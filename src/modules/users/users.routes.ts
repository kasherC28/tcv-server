import { Router } from 'express';
import { asyncWrap } from '../../common/http';
import { auth } from '../../middleware/auth';
import { allowRoles } from '../../middleware/role';
import { validate } from '../../middleware/validate';
import { Role } from '../../common/enums';
import * as controller from './users.controller';
import { idParamSchema, updateMeSchema, updateUserSchema } from './users.schema';

const router = Router();

router.get('/me', auth, asyncWrap(controller.me));
router.patch('/me', auth, validate(updateMeSchema), asyncWrap(controller.updateMe));
router.get('/', auth, allowRoles(Role.ADMIN), asyncWrap(controller.list));
router.get('/:id', auth, allowRoles(Role.ADMIN), validate(idParamSchema, 'params'), asyncWrap(controller.one));
router.patch('/:id', auth, allowRoles(Role.ADMIN), validate(idParamSchema, 'params'), validate(updateUserSchema), asyncWrap(controller.update));

export default router;
