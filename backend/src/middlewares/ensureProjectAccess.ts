import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../utils/errors.js';
import { getProjectAccess } from '../utils/projectAccess.js';

export async function ensureProjectAccess(
  req: Request,
  _res: Response,
  next: NextFunction,
) {
  if (!req.user) {
    throw new AppError(401, 'Authentication required');
  }

  const projectId = Number(req.params.id ?? req.params.projectId);
  if (!Number.isInteger(projectId) || projectId <= 0) {
    throw new AppError(400, 'Invalid project id');
  }

  const access = await getProjectAccess(req.user.id, projectId);
  if (!access) {
    throw new AppError(403, 'Access denied to this project');
  }

  req.projectId = projectId;
  req.collaboratorRole = access.role;
  next();
}
