import type { CollaboratorRole } from '../models/Collaborator.js';

declare global {
  namespace Express {
    interface Request {
      user?: {
        id: number;
        email: string;
        full_name: string;
      };
      projectId?: number;
      collaboratorRole?: CollaboratorRole | 'owner';
    }
  }
}

export {};
