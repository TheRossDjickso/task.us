import type { Request, Response } from 'express';
import { Op } from 'sequelize';
import { z } from 'zod';
import { Label, Task, User } from '../models/index.js';
import { emitToProject } from '../services/socket.service.js';
import { AppError } from '../utils/errors.js';
import { createNotification } from '../utils/notificationHelper.js';
import {
  getProjectAccess,
  getProjectIdFromList,
  getProjectIdFromTask,
} from '../utils/projectAccess.js';

const taskSchema = z.object({
  title: z.string().min(1).max(200),
  description: z.string().optional(),
  priority: z.union([z.literal(1), z.literal(2), z.literal(3)]).optional(),
  due_date: z.string().date().nullable().optional(),
  assigned_to: z.number().int().positive().nullable().optional(),
  position: z.number().int().min(0).optional(),
});

const moveSchema = z.object({
  list_id: z.number().int().positive(),
  position: z.number().int().min(0),
});

const assignSchema = z.object({
  assigned_to: z.number().int().positive().nullable(),
});

async function ensureAssigneeInProject(
  projectId: number,
  userId: number | null | undefined,
) {
  if (userId == null) return;

  const access = await getProjectAccess(userId, projectId);
  if (!access) {
    throw new AppError(400, 'Assignee must be a project member');
  }
}

async function loadTaskWithAccess(req: Request, taskId: number) {
  const projectId = await getProjectIdFromTask(taskId);
  if (!projectId) {
    throw new AppError(404, 'Task not found');
  }

  const access = await getProjectAccess(req.user!.id, projectId);
  if (!access) {
    throw new AppError(403, 'Access denied');
  }

  const task = await Task.findByPk(taskId, {
    include: [
      { model: User, as: 'assignee', attributes: ['id', 'full_name', 'avatar_url'] },
      { model: User, as: 'creator', attributes: ['id', 'full_name', 'avatar_url'] },
      { model: Label, as: 'labels' },
    ],
  });

  if (!task) {
    throw new AppError(404, 'Task not found');
  }

  return { task, projectId, access };
}

export async function listTasks(req: Request, res: Response) {
  const listId = Number(req.params.listId);
  const projectId = await getProjectIdFromList(listId);

  if (!projectId) {
    throw new AppError(404, 'List not found');
  }

  const access = await getProjectAccess(req.user!.id, projectId);
  if (!access) {
    throw new AppError(403, 'Access denied');
  }

  const where: Record<string, unknown> = { list_id: listId };

  if (req.query.priority) {
    where.priority = Number(req.query.priority);
  }
  if (req.query.assigned_to) {
    where.assigned_to = Number(req.query.assigned_to);
  }
  if (req.query.is_done !== undefined) {
    where.is_done = req.query.is_done === 'true';
  }
  if (req.query.due_date) {
    where.due_date = String(req.query.due_date);
  }
  if (req.query.q) {
    where.title = { [Op.iLike]: `%${String(req.query.q)}%` };
  }

  const labelFilter = req.query.label
    ? { id: Number(req.query.label) }
    : undefined;

  const tasks = await Task.findAll({
    where,
    include: [
      { model: User, as: 'assignee', attributes: ['id', 'full_name', 'avatar_url'] },
      {
        model: Label,
        as: 'labels',
        ...(labelFilter ? { where: labelFilter, required: true } : {}),
      },
    ],
    order: [['position', 'ASC']],
  });

  res.json(tasks);
}

export async function createTask(req: Request, res: Response) {
  const body = taskSchema.parse(req.body);
  const listId = Number(req.params.listId);
  const projectId = await getProjectIdFromList(listId);

  if (!projectId) {
    throw new AppError(404, 'List not found');
  }

  const access = await getProjectAccess(req.user!.id, projectId);
  if (!access || (access.role !== 'owner' && access.role === 'viewer')) {
    throw new AppError(403, 'Insufficient permissions');
  }

  await ensureAssigneeInProject(projectId, body.assigned_to);

  const maxPosition = (await Task.max('position', {
    where: { list_id: listId },
  })) as number | null;

  const task = await Task.create({
    title: body.title,
    description: body.description ?? null,
    priority: body.priority ?? 1,
    due_date: body.due_date ?? null,
    list_id: listId,
    assigned_to: body.assigned_to ?? null,
    created_by: req.user!.id,
    position: body.position ?? (maxPosition ?? -1) + 1,
  });

  if (task.assigned_to && task.assigned_to !== req.user!.id) {
    await createNotification(task.assigned_to, 'task:assigned', {
      task_id: task.id,
      project_id: projectId,
      taskTitle: task.title,
    });
    emitToProject(projectId, 'task:assigned', task);
  }

  res.status(201).json(task);
}

export async function getTask(req: Request, res: Response) {
  const { task } = await loadTaskWithAccess(req, Number(req.params.id));
  res.json(task);
}

export async function updateTask(req: Request, res: Response) {
  const body = taskSchema.partial().parse(req.body);
  const taskId = Number(req.params.id);
  const { task, projectId, access } = await loadTaskWithAccess(req, taskId);

  if (access.role === 'viewer') {
    throw new AppError(403, 'Insufficient permissions');
  }

  await ensureAssigneeInProject(projectId, body.assigned_to);
  const previousAssignee = task.assigned_to;

  await task.update(body);

  if (
    body.assigned_to !== undefined &&
    body.assigned_to !== null &&
    body.assigned_to !== previousAssignee &&
    body.assigned_to !== req.user!.id
  ) {
    await createNotification(body.assigned_to, 'task:assigned', {
      task_id: task.id,
      project_id: projectId,
      taskTitle: task.title,
    });
    emitToProject(projectId, 'task:assigned', task);
  }

  res.json(task);
}

export async function deleteTask(req: Request, res: Response) {
  const { task, access } = await loadTaskWithAccess(req, Number(req.params.id));

  if (access.role === 'viewer') {
    throw new AppError(403, 'Insufficient permissions');
  }

  await task.destroy();
  res.status(204).send();
}

export async function moveTask(req: Request, res: Response) {
  const body = moveSchema.parse(req.body);
  const taskId = Number(req.params.id);
  const { task, projectId, access } = await loadTaskWithAccess(req, taskId);

  if (access.role === 'viewer') {
    throw new AppError(403, 'Insufficient permissions');
  }

  const targetProjectId = await getProjectIdFromList(body.list_id);
  if (targetProjectId !== projectId) {
    throw new AppError(400, 'Cannot move task to a list in another project');
  }

  await task.update({ list_id: body.list_id, position: body.position });
  emitToProject(projectId, 'task:moved', task);

  res.json(task);
}

export async function toggleDone(req: Request, res: Response) {
  const { task, projectId, access } = await loadTaskWithAccess(
    req,
    Number(req.params.id),
  );

  if (access.role === 'viewer') {
    throw new AppError(403, 'Insufficient permissions');
  }

  await task.update({ is_done: !task.is_done });
  emitToProject(projectId, 'task:updated', task);

  res.json(task);
}

export async function assignTask(req: Request, res: Response) {
  const body = assignSchema.parse(req.body);
  const { task, projectId, access } = await loadTaskWithAccess(
    req,
    Number(req.params.id),
  );

  if (access.role === 'viewer') {
    throw new AppError(403, 'Insufficient permissions');
  }

  await ensureAssigneeInProject(projectId, body.assigned_to);
  await task.update({ assigned_to: body.assigned_to });

  if (body.assigned_to && body.assigned_to !== req.user!.id) {
    await createNotification(body.assigned_to, 'task:assigned', {
      task_id: task.id,
      project_id: projectId,
      taskTitle: task.title,
    });
    emitToProject(projectId, 'task:assigned', task);
  }

  res.json(task);
}
