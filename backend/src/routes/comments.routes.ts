import { Router } from 'express';
import * as commentsController from '../controllers/comments.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router({ mergeParams: true });

router.use(authenticate);

router.get('/', asyncHandler(commentsController.listComments));
router.post('/', asyncHandler(commentsController.createComment));
router.put('/:id', asyncHandler(commentsController.updateComment));
router.delete('/:id', asyncHandler(commentsController.deleteComment));

export default router;
