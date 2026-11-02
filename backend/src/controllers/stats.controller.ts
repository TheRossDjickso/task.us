import type { Request, Response } from 'express';
import { Op } from 'sequelize';
import { List, Task, User } from '../models/index.js';

export async function getProjectStats(req: Request, res: Response) {
  const projectId = Number(req.params.id);

  const lists = await List.findAll({
    where: { project_id: projectId },
    attributes: ['id'],
  });

  const listIds = lists.map((l) => l.id);

  if (listIds.length === 0) {
    res.json({
      total: 0,
      done: 0,
      late: 0,
      pending: 0,
      by_member: [],
    });
    return;
  }

  const tasks = await Task.findAll({
    where: { list_id: { [Op.in]: listIds } },
    attributes: ['id', 'is_done', 'due_date', 'assigned_to'],
  });

  const today = new Date().toISOString().slice(0, 10);

  const total = tasks.length;
  const done = tasks.filter((t) => t.is_done).length;
  const late = tasks.filter(
    (t) => !t.is_done && t.due_date && t.due_date < today,
  ).length;
  const pending = total - done;

  const byMemberMap = new Map<number, { assigned: number; done: number }>();

  for (const task of tasks) {
    if (!task.assigned_to) continue;

    const entry = byMemberMap.get(task.assigned_to) ?? {
      assigned: 0,
      done: 0,
    };
    entry.assigned += 1;
    if (task.is_done) entry.done += 1;
    byMemberMap.set(task.assigned_to, entry);
  }

  const userIds = [...byMemberMap.keys()];
  const users = await User.findAll({
    where: { id: { [Op.in]: userIds } },
    attributes: ['id', 'full_name', 'email', 'avatar_url'],
  });

  const by_member = users.map((user) => ({
    user,
    ...(byMemberMap.get(user.id) ?? { assigned: 0, done: 0 }),
  }));

  res.json({ total, done, late, pending, by_member });
}
