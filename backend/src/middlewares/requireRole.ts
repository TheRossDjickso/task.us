import type { NextFunction, Request, Response } from 'express';
import type { CollaboratorRole } from '../models/Collaborator.js';
import { AppError } from '../utils/errors.js';
import { getProjectAccess, hasMinimumRole } from '../utils/projectAccess.js';

function resolveProjectId(req: Request): number {
  const projectId = Number(
    req.params.projectId ?? req.params.id ?? req.projectId,
  );
  if (!Number.isInteger(projectId) || projectId <= 0) {
    throw new AppError(400, 'Invalid project id');
  }
  return projectId;
}

export function requireMinimumProjectRole(minimum: CollaboratorRole) {
  return async (req: Request, _res: Response, next: NextFunction) => {
    if (!req.user) {
      throw new AppError(401, 'Authentication required');
    }

    const projectId = resolveProjectId(req);
    const access = await getProjectAccess(req.user.id, projectId);

    if (!access || !hasMinimumRole(access.role, minimum)) {
      throw new AppError(403, 'Insufficient permissions');
    }

    req.projectId = projectId;
    req.collaboratorRole = access.role;
    next();
  };
}

export function requireProjectMember() {
  return requireMinimumProjectRole('viewer');
}

export function requireProjectContributor() {
  return requireMinimumProjectRole('member');
}

export function requireProjectAdmin() {
  return requireMinimumProjectRole('admin');
}
