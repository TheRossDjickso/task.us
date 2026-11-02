import { Router } from 'express';
import * as tasksController from '../controllers/tasks.controller.js';
import { authenticate } from '../middlewares/authenticate.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();

router.use(authenticate);

router.get('/lists/:listId/tasks', asyncHandler(tasksController.listTasks));
router.post('/lists/:listId/tasks', asyncHandler(tasksController.createTask));

router.get('/tasks/:id', asyncHandler(tasksController.getTask));
router.put('/tasks/:id', asyncHandler(tasksController.updateTask));
router.delete('/tasks/:id', asyncHandler(tasksController.deleteTask));
router.patch('/tasks/:id/move', asyncHandler(tasksController.moveTask));
router.patch('/tasks/:id/done', asyncHandler(tasksController.toggleDone));
router.patch('/tasks/:id/assign', asyncHandler(tasksController.assignTask));

export default router;
