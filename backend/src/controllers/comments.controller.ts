import type { Request, Response } from 'express';
import { z } from 'zod';
import { Comment, Task, User } from '../models/index.js';
import { emitToProject, emitToTask } from '../services/socket.service.js';
import { AppError } from '../utils/errors.js';
import { createNotification } from '../utils/notificationHelper.js';
import {
  getProjectAccess,
  getProjectIdFromTask,
} from '../utils/projectAccess.js';

const commentSchema = z.object({
  content: z.string().min(1),
  parent_id: z.number().int().positive().nullable().optional(),
});

async function loadTaskContext(req: Request, taskId: number) {
  const projectId = await getProjectIdFromTask(taskId);
  if (!projectId) {
    throw new AppError(404, 'Task not found');
  }

  const access = await getProjectAccess(req.user!.id, projectId);
  if (!access) {
    throw new AppError(403, 'Access denied');
  }

  return { projectId, access };
}

function buildCommentTree(comments: Comment[]) {
  const roots = comments.filter((c) => !c.parent_id);
  const repliesByParent = new Map<number, Comment[]>();

  for (const comment of comments) {
    if (comment.parent_id) {
      const list = repliesByParent.get(comment.parent_id) ?? [];
      list.push(comment);
      repliesByParent.set(comment.parent_id, list);
    }
  }

  return roots.map((root) => ({
    ...root.toJSON(),
    replies: (repliesByParent.get(root.id) ?? []).map((r) => r.toJSON()),
  }));
}

export async function listComments(req: Request, res: Response) {
  const taskId = Number(req.params.taskId);
  await loadTaskContext(req, taskId);

  const comments = await Comment.findAll({
    where: { task_id: taskId },
    include: [{ model: User, as: 'user', attributes: ['id', 'full_name', 'avatar_url'] }],
    order: [['created_at', 'ASC']],
  });

  res.json(buildCommentTree(comments));
}

export async function createComment(req: Request, res: Response) {
  const body = commentSchema.parse(req.body);
  const taskId = Number(req.params.taskId);
  const { projectId, access } = await loadTaskContext(req, taskId);

  if (access.role === 'viewer') {
    throw new AppError(403, 'Insufficient permissions');
  }

  if (body.parent_id) {
    const parent = await Comment.findOne({
      where: { id: body.parent_id, task_id: taskId },
    });
    if (!parent) {
      throw new AppError(404, 'Parent comment not found');
    }
  }

  const comment = await Comment.create({
    content: body.content,
    user_id: req.user!.id,
    task_id: taskId,
    parent_id: body.parent_id ?? null,
  });

  const full = await Comment.findByPk(comment.id, {
    include: [{ model: User, as: 'user', attributes: ['id', 'full_name', 'avatar_url'] }],
  });

  emitToTask(taskId, 'comment:added', full);
  emitToProject(projectId, 'comment:added', full);

  const task = await Task.findByPk(taskId);
  if (task && task.assigned_to && task.assigned_to !== req.user!.id) {
    await createNotification(task.assigned_to, 'comment:added', {
      task_id: taskId,
      comment_id: comment.id,
      project_id: projectId,
      taskTitle: task.title,
      senderName: req.user!.full_name,
    });
  }

  res.status(201).json(full);
}

export async function updateComment(req: Request, res: Response) {
  const body = commentSchema.pick({ content: true }).parse(req.body);
  const taskId = Number(req.params.taskId);
  await loadTaskContext(req, taskId);

  const comment = await Comment.findOne({
    where: { id: req.params.id, task_id: taskId },
  });

  if (!comment) {
    throw new AppError(404, 'Comment not found');
  }

  if (comment.user_id !== req.user!.id) {
    throw new AppError(403, 'Only the author can edit this comment');
  }

  await comment.update({ content: body.content });
  res.json(comment);
}

export async function deleteComment(req: Request, res: Response) {
  const taskId = Number(req.params.taskId);
  const { access } = await loadTaskContext(req, taskId);

  const comment = await Comment.findOne({
    where: { id: req.params.id, task_id: taskId },
  });

  if (!comment) {
    throw new AppError(404, 'Comment not found');
  }

  const isAuthor = comment.user_id === req.user!.id;
  const isAdmin = access.role === 'admin' || access.role === 'owner';

  if (!isAuthor && !isAdmin) {
    throw new AppError(403, 'Insufficient permissions');
  }

  await comment.destroy();
  res.status(204).send();
}
