import { Router } from 'express';
import * as labelsController from '../controllers/labels.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import {
  requireProjectContributor,
  requireProjectMember,
} from '../middlewares/requireRole.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const projectLabelsRouter = Router({ mergeParams: true });
projectLabelsRouter.use(authenticate);
projectLabelsRouter.get(
  '/',
  requireProjectMember(),
  asyncHandler(labelsController.listLabels),
);
projectLabelsRouter.post(
  '/',
  requireProjectContributor(),
  asyncHandler(labelsController.createLabel),
);

const router = Router();
router.use('/projects/:projectId/labels', projectLabelsRouter);

router.use(authenticate);
router.put('/labels/:id', asyncHandler(labelsController.updateLabel));
router.delete('/labels/:id', asyncHandler(labelsController.deleteLabel));
router.post('/tasks/:taskId/labels', asyncHandler(labelsController.addLabelToTask));
router.delete(
  '/tasks/:taskId/labels/:labelId',
  asyncHandler(labelsController.removeLabelFromTask),
);

export default router;
