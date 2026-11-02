import { Router } from 'express';
import * as attachmentsController from '../controllers/attachments.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { upload } from '../middlewares/upload.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router({ mergeParams: true });

router.use(authenticate);

router.get('/', asyncHandler(attachmentsController.listAttachments));
router.post(
  '/',
  upload.single('file'),
  asyncHandler(attachmentsController.uploadAttachment),
);
router.delete('/:id', asyncHandler(attachmentsController.deleteAttachment));

export default router;
