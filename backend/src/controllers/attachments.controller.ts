import fs from 'node:fs/promises';
import path from 'node:path';
import type { Request, Response } from 'express';
import { Attachment } from '../models/index.js';
import { AppError } from '../utils/errors.js';
import {
  getProjectAccess,
  getProjectIdFromTask,
} from '../utils/projectAccess.js';

export async function listAttachments(req: Request, res: Response) {
  const taskId = Number(req.params.taskId);
  const projectId = await getProjectIdFromTask(taskId);

  if (!projectId) {
    throw new AppError(404, 'Task not found');
  }

  const access = await getProjectAccess(req.user!.id, projectId);
  if (!access) {
    throw new AppError(403, 'Access denied');
  }

  const attachments = await Attachment.findAll({
    where: { task_id: taskId },
    order: [['created_at', 'DESC']],
  });

  res.json(attachments);
}

export async function uploadAttachment(req: Request, res: Response) {
  const taskId = Number(req.params.taskId);
  const projectId = await getProjectIdFromTask(taskId);

  if (!projectId) {
    throw new AppError(404, 'Task not found');
  }

  const access = await getProjectAccess(req.user!.id, projectId);
  if (!access || access.role === 'viewer') {
    throw new AppError(403, 'Insufficient permissions');
  }

  if (!req.file) {
    throw new AppError(400, 'No file uploaded');
  }

  const uploadDir = process.env.UPLOAD_DIR ?? 'uploads';
  const url = `/${uploadDir}/${req.file.filename}`;

  const attachment = await Attachment.create({
    filename: req.file.originalname,
    url,
    task_id: taskId,
    uploaded_by: req.user!.id,
  });

  res.status(201).json(attachment);
}

export async function deleteAttachment(req: Request, res: Response) {
  const taskId = Number(req.params.taskId);
  const projectId = await getProjectIdFromTask(taskId);

  if (!projectId) {
    throw new AppError(404, 'Task not found');
  }

  const access = await getProjectAccess(req.user!.id, projectId);
  if (!access || access.role === 'viewer') {
    throw new AppError(403, 'Insufficient permissions');
  }

  const attachment = await Attachment.findOne({
    where: { id: req.params.id, task_id: taskId },
  });

  if (!attachment) {
    throw new AppError(404, 'Attachment not found');
  }

  const uploadDir = process.env.UPLOAD_DIR ?? 'uploads';
  const filePath = path.join(uploadDir, path.basename(attachment.url));

  try {
    await fs.unlink(filePath);
  } catch {
    // file may already be deleted
  }

  await attachment.destroy();
  res.status(204).send();
}
