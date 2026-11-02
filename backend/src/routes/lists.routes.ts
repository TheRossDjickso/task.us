import { Router } from 'express';
import * as listsController from '../controllers/lists.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import {
  requireProjectContributor,
  requireProjectMember,
} from '../middlewares/requireRole.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router({ mergeParams: true });

router.use(authenticate);

router.get('/', requireProjectMember(), asyncHandler(listsController.listLists));
router.post(
  '/',
  requireProjectContributor(),
  asyncHandler(listsController.createList),
);
router.patch(
  '/reorder',
  requireProjectContributor(),
  asyncHandler(listsController.reorderLists),
);
router.put(
  '/:id',
  requireProjectContributor(),
  asyncHandler(listsController.updateList),
);
router.delete(
  '/:id',
  requireProjectContributor(),
  asyncHandler(listsController.deleteList),
);

export default router;
