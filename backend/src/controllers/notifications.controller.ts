import type { Request, Response } from 'express';
import { z } from 'zod';
import { Notification, DeviceToken } from '../models/index.js';
import { AppError } from '../utils/errors.js';

const deviceSchema = z.object({
  token: z.string().min(1).max(512),
  platform: z.enum(['android', 'ios']).default('android'),
});

const unregisterSchema = z.object({
  token: z.string().min(1).max(512),
});

export async function listNotifications(req: Request, res: Response) {
  const notifications = await Notification.findAll({
    where: { user_id: req.user!.id },
    order: [['created_at', 'DESC']],
    limit: 50,
  });

  res.json(notifications);
}

export async function markAsRead(req: Request, res: Response) {
  const notification = await Notification.findOne({
    where: { id: req.params.id, user_id: req.user!.id },
  });

  if (!notification) {
    throw new AppError(404, 'Notification not found');
  }

  await notification.update({ is_read: true });
  res.json(notification);
}

export async function markAllAsRead(req: Request, res: Response) {
  await Notification.update(
    { is_read: true },
    { where: { user_id: req.user!.id, is_read: false } },
  );

  res.json({ message: 'All notifications marked as read' });
}

export async function registerDeviceToken(req: Request, res: Response) {
  const { token, platform } = deviceSchema.parse(req.body);
  const userId = req.user!.id;

  const [deviceToken, created] = await DeviceToken.findOrCreate({
    where: { token },
    defaults: {
      user_id: userId,
      token,
      platform,
    },
  });

  if (!created && deviceToken.user_id !== userId) {
    await deviceToken.update({ user_id: userId, platform });
  }

  res.status(201).json(deviceToken);
}

export async function unregisterDeviceToken(req: Request, res: Response) {
  const { token } = unregisterSchema.parse(req.body);
  const userId = req.user!.id;

  await DeviceToken.destroy({
    where: {
      token,
      user_id: userId,
    },
  });

  res.status(204).send();
}

