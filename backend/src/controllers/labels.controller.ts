import type { Request, Response } from 'express';
import { z } from 'zod';
import { Label, Task, TaskLabel } from '../models/index.js';
import { AppError } from '../utils/errors.js';
import { parseId } from '../utils/params.js';
import {
  getProjectAccess,
  getProjectIdFromTask,
} from '../utils/projectAccess.js';

const labelSchema = z.object({
  name: z.string().min(1).max(50),
  color: z.string().max(20).optional(),
});

export async function listLabels(req: Request, res: Response) {
  const projectId = Number(req.params.projectId);

  const labels = await Label.findAll({
    where: { project_id: projectId },
    order: [['name', 'ASC']],
  });

  res.json(labels);
}

export async function createLabel(req: Request, res: Response) {
  const body = labelSchema.parse(req.body);
  const projectId = Number(req.params.projectId);

  const label = await Label.create({
    name: body.name,
    color: body.color ?? '#61BD4F',
    project_id: projectId,
  });

  res.status(201).json(label);
}

export async function updateLabel(req: Request, res: Response) {
  const body = labelSchema.partial().parse(req.body);
  const label = await Label.findByPk(parseId(req.params.id));

  if (!label) {
    throw new AppError(404, 'Label not found');
  }

  const access = await getProjectAccess(req.user!.id, label.project_id);
  if (!access || access.role === 'viewer') {
    throw new AppError(403, 'Insufficient permissions');
  }

  await label.update(body);
  res.json(label);
}

export async function deleteLabel(req: Request, res: Response) {
  const label = await Label.findByPk(parseId(req.params.id));

  if (!label) {
    throw new AppError(404, 'Label not found');
  }

  const access = await getProjectAccess(req.user!.id, label.project_id);
  if (!access || access.role === 'viewer') {
    throw new AppError(403, 'Insufficient permissions');
  }

  await label.destroy();
  res.status(204).send();
}

export async function addLabelToTask(req: Request, res: Response) {
  const taskId = Number(req.params.taskId);
  const { label_id } = z.object({ label_id: z.number().int().positive() }).parse(req.body);

  const projectId = await getProjectIdFromTask(taskId);
  if (!projectId) {
    throw new AppError(404, 'Task not found');
  }

  const access = await getProjectAccess(req.user!.id, projectId);
  if (!access || access.role === 'viewer') {
    throw new AppError(403, 'Insufficient permissions');
  }

  const label = await Label.findByPk(label_id);
  if (!label || label.project_id !== projectId) {
    throw new AppError(404, 'Label not found in this project');
  }

  const task = await Task.findByPk(taskId);
  if (!task) {
    throw new AppError(404, 'Task not found');
  }

  await TaskLabel.findOrCreate({
    where: { task_id: taskId, label_id },
    defaults: { task_id: taskId, label_id },
  });

  const updated = await Task.findByPk(taskId, {
    include: [{ association: 'labels' }],
  });

  res.status(201).json(updated);
}

export async function removeLabelFromTask(req: Request, res: Response) {
  const taskId = Number(req.params.taskId);
  const labelId = Number(req.params.labelId);

  const projectId = await getProjectIdFromTask(taskId);
  if (!projectId) {
    throw new AppError(404, 'Task not found');
  }

  const access = await getProjectAccess(req.user!.id, projectId);
  if (!access || access.role === 'viewer') {
    throw new AppError(403, 'Insufficient permissions');
  }

  await TaskLabel.destroy({
    where: { task_id: taskId, label_id: labelId },
  });

  res.status(204).send();
}
