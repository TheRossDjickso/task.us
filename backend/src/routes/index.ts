import type { Express } from 'express';
import attachmentsRoutes from './attachments.routes.js';
import authRoutes from './auth.routes.js';
import commentsRoutes from './comments.routes.js';
import labelsRoutes from './labels.routes.js';
import listsRoutes from './lists.routes.js';
import notificationsRoutes from './notifications.routes.js';
import projectsRoutes from './projects.routes.js';
import statsRoutes from './stats.routes.js';
import tasksRoutes from './tasks.routes.js';

export function registerRoutes(app: Express) {
  app.use('/api/auth', authRoutes);
  app.use('/api/projects', projectsRoutes);
  app.use('/api/projects/:projectId/lists', listsRoutes);
  app.use('/api', tasksRoutes);
  app.use('/api', labelsRoutes);
  app.use('/api/tasks/:taskId/comments', commentsRoutes);
  app.use('/api/tasks/:taskId/attachments', attachmentsRoutes);
  app.use('/api/notifications', notificationsRoutes);
  app.use('/api', statsRoutes);
}
