import { Collaborator, Projet } from '../models/index.js';
import type { CollaboratorRole } from '../models/Collaborator.js';

export type ProjectAccessRole = CollaboratorRole | 'owner';

export interface ProjectAccess {
  role: ProjectAccessRole;
  isOwner: boolean;
}

const ROLE_RANK: Record<ProjectAccessRole, number> = {
  viewer: 1,
  member: 2,
  admin: 3,
  owner: 4,
};

export function hasMinimumRole(
  current: ProjectAccessRole,
  required: CollaboratorRole | 'owner',
): boolean {
  return ROLE_RANK[current] >= ROLE_RANK[required];
}

export async function getProjectAccess(
  userId: number,
  projectId: number,
): Promise<ProjectAccess | null> {
  const project = await Projet.findByPk(projectId);
  if (!project) return null;

  if (project.owner_id === userId) {
    return { role: 'owner', isOwner: true };
  }

  const membership = await Collaborator.findOne({
    where: { user_id: userId, project_id: projectId },
  });

  if (!membership || membership.status !== 'accepted') return null;

  return { role: membership.role, isOwner: false };
}

export async function getProjectIdFromList(listId: number): Promise<number | null> {
  const { List } = await import('../models/index.js');
  const list = await List.findByPk(listId, { attributes: ['project_id'] });
  return list?.project_id ?? null;
}

export async function getProjectIdFromTask(taskId: number): Promise<number | null> {
  const { List, Task } = await import('../models/index.js');
  const task = await Task.findByPk(taskId, { attributes: ['list_id'] });
  if (!task) return null;
  return getProjectIdFromList(task.list_id);
}
