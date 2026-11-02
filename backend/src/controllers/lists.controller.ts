import type { Request, Response } from 'express';
import { z } from 'zod';
import { List } from '../models/index.js';
import { AppError } from '../utils/errors.js';

const listSchema = z.object({
  title: z.string().min(1).max(100),
  position: z.number().int().min(0).optional(),
});

const reorderSchema = z.array(
  z.object({
    id: z.number().int().positive(),
    position: z.number().int().min(0),
  }),
);

export async function listLists(req: Request, res: Response) {
  const projectId = Number(req.params.projectId);

  const lists = await List.findAll({
    where: { project_id: projectId },
    order: [['position', 'ASC']],
  });

  res.json(lists);
}

export async function createList(req: Request, res: Response) {
  const body = listSchema.parse(req.body);
  const projectId = Number(req.params.projectId);

  const maxPosition = (await List.max('position', {
    where: { project_id: projectId },
  })) as number | null;

  const list = await List.create({
    title: body.title,
    project_id: projectId,
    position: body.position ?? (maxPosition ?? -1) + 1,
  });

  res.status(201).json(list);
}

export async function updateList(req: Request, res: Response) {
  const body = listSchema.partial().parse(req.body);
  const list = await List.findOne({
    where: { id: req.params.id, project_id: req.params.projectId },
  });

  if (!list) {
    throw new AppError(404, 'List not found');
  }

  await list.update(body);
  res.json(list);
}

export async function deleteList(req: Request, res: Response) {
  const list = await List.findOne({
    where: { id: req.params.id, project_id: req.params.projectId },
  });

  if (!list) {
    throw new AppError(404, 'List not found');
  }

  await list.destroy();
  res.status(204).send();
}

export async function reorderLists(req: Request, res: Response) {
  const items = reorderSchema.parse(req.body);
  const projectId = Number(req.params.projectId);

  await Promise.all(
    items.map((item) =>
      List.update(
        { position: item.position },
        { where: { id: item.id, project_id: projectId } },
      ),
    ),
  );

  const lists = await List.findAll({
    where: { project_id: projectId },
    order: [['position', 'ASC']],
  });

  res.json(lists);
}
