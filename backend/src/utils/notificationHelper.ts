import { Notification, DeviceToken, Task } from '../models/index.js';
import { emitToUser } from '../services/socket.service.js';
import { sendPushNotification } from '../services/firebase.service.js';

export async function createNotification(
  userId: number,
  type: string,
  payload: Record<string, unknown>,
) {
  const notification = await Notification.create({
    user_id: userId,
    type,
    payload,
    is_read: false,
  });

  emitToUser(userId, 'notification:new', notification);

  // Send Push Notification in the background without blocking the HTTP response
  sendPush(userId, type, payload, notification.id).catch((err) => {
    console.error('Error handling background push notification dispatch:', err);
  });

  return notification;
}

async function sendPush(userId: number, type: string, payload: Record<string, unknown>, notificationId?: number) {
  // Query active device tokens for the recipient user
  const deviceTokens = await DeviceToken.findAll({
    where: { user_id: userId },
    attributes: ['token'],
  });

  if (deviceTokens.length === 0) return;
  const tokens = deviceTokens.map((dt) => dt.token);

  let title = 'Nouvelle notification';
  let body = 'Vous avez reçu une nouvelle mise à jour.';
  const data: Record<string, string> = {
    type,
    project_id: String(payload.project_id || payload.projectId || ''),
    task_id: String(payload.task_id || ''),
  };

  if (notificationId) {
    data.notification_id = String(notificationId);
  }

  if (type === 'project:invite') {
    const projectName = payload.projectName || 'un projet';
    const senderName = payload.senderName || 'Un utilisateur';
    title = 'Invitation à un projet';
    body = `${senderName} vous a invité à collaborer sur le projet "${projectName}".`;
  } else if (type === 'task:assigned') {
    const taskId = payload.task_id as number;
    let taskTitle = 'Nouvelle tâche';
    if (taskId) {
      const task = await Task.findByPk(taskId, { attributes: ['title'] });
      if (task) {
        taskTitle = task.title;
      }
    }
    title = 'Nouvelle tâche assignée';
    body = `Vous avez été assigné à la tâche : "${taskTitle}".`;
  } else if (type === 'comment:added') {
    const taskId = payload.task_id as number;
    let taskTitle = 'tâche';
    if (taskId) {
      const task = await Task.findByPk(taskId, { attributes: ['title'] });
      if (task) {
        taskTitle = task.title;
      }
    }
    title = 'Nouveau commentaire';
    body = `Un commentaire a été ajouté sur la tâche : "${taskTitle}".`;
  }

  await sendPushNotification(tokens, title, body, data);
}
