import { Router } from 'express';
import * as projectsController from '../controllers/projects.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { ensureProjectAccess } from '../middlewares/ensureProjectAccess.js';
import {
  requireProjectAdmin,
  requireProjectContributor,
  requireProjectMember,
} from '../middlewares/requireRole.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();

router.use(authenticate);

router.get('/', asyncHandler(projectsController.listProjects));
router.post('/', asyncHandler(projectsController.createProject));

router.get('/:id', ensureProjectAccess, asyncHandler(projectsController.getProject));
router.put(
  '/:id',
  ensureProjectAccess,
  requireProjectAdmin(),
  asyncHandler(projectsController.updateProject),
);
router.delete(
  '/:id',
  ensureProjectAccess,
  requireProjectAdmin(),
  asyncHandler(projectsController.deleteProject),
);
router.patch(
  '/:id/archive',
  ensureProjectAccess,
  requireProjectAdmin(),
  asyncHandler(projectsController.archiveProject),
);

router.post(
  '/:id/members',
  ensureProjectAccess,
  requireProjectAdmin(),
  asyncHandler(projectsController.inviteMember),
);
router.post(
  '/:id/members/accept',
  asyncHandler(projectsController.acceptInvitation),
);
router.post(
  '/:id/members/decline',
  asyncHandler(projectsController.declineInvitation),
);
router.put(
  '/:id/members/:userId',
  ensureProjectAccess,
  requireProjectAdmin(),
  asyncHandler(projectsController.updateMember),
);
router.delete(
  '/:id/members/:userId',
  ensureProjectAccess,
  requireProjectAdmin(),
  asyncHandler(projectsController.removeMember),
);

export default router;
