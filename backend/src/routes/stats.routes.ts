import { Router } from 'express';
import * as statsController from '../controllers/stats.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { ensureProjectAccess } from '../middlewares/ensureProjectAccess.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();

router.use(authenticate);

router.get(
  '/projects/:id/stats',
  ensureProjectAccess,
  asyncHandler(statsController.getProjectStats),
);

export default router;
