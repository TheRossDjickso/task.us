import { Router } from 'express';
import * as notificationsController from '../controllers/notifications.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();

router.use(authenticate);

router.get('/', asyncHandler(notificationsController.listNotifications));
router.patch('/read-all', asyncHandler(notificationsController.markAllAsRead));
router.patch('/:id/read', asyncHandler(notificationsController.markAsRead));

router.post('/devices', asyncHandler(notificationsController.registerDeviceToken));
router.delete('/devices', asyncHandler(notificationsController.unregisterDeviceToken));

export default router;
