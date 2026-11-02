import type { Request, Response } from 'express';
import { z } from 'zod';
import {
  Collaborator,
  List,
  Projet,
  Task,
  User,
} from '../models/index.js';
import { AppError } from '../utils/errors.js';
import { parseId } from '../utils/params.js';
import { createNotification } from '../utils/notificationHelper.js';

const projectSchema = z.object({
  title: z.string().min(1).max(150),
  description: z.string().max(500).optional(),
  background_color: z.string().max(20).optional(),
});

const memberSchema = z.object({
  email: z.string().email(),
  role: z.enum(['admin', 'member', 'viewer']).default('member'),
});

const updateMemberSchema = z.object({
  role: z.enum(['admin', 'member', 'viewer']),
});

const archiveSchema = z.object({
  is_archived: z.boolean(),
});

export async function listProjects(req: Request, res: Response) {
  const userId = req.user!.id;

  const includeOptions = [
    { model: User, as: 'owner', attributes: ['id', 'full_name', 'email', 'avatar_url'] },
    {
      model: List,
      as: 'lists',
      include: [
        {
          model: Task,
          as: 'tasks',
          attributes: ['id', 'is_done'],
        },
      ],
    },
    {
      model: Collaborator,
      as: 'memberships',
      include: [{ model: User, as: 'user', attributes: ['id', 'avatar_url'] }],
    },
  ];

  const ownedProjects = await Projet.findAll({
    where: { owner_id: userId },
    include: includeOptions,
    order: [['updated_at', 'DESC']],
  });

  const memberships = await Collaborator.findAll({
    where: { user_id: userId, status: 'accepted' },
    include: [
      {
        model: Projet,
        as: 'project',
        include: includeOptions,
      },
    ],
  });

  const collaboratedProjects = memberships
    .map((m) => m.project)
    .filter((p): p is Projet => p !== undefined && p.owner_id !== userId);

  const formatProject = (project: Projet) => {
    let totalTasks = 0;
    let completedTasks = 0;

    if (project.lists) {
      for (const list of project.lists) {
        if (list.tasks) {
          totalTasks += list.tasks.length;
          completedTasks += list.tasks.filter((t: any) => t.is_done).length;
        }
      }
    }

    const memberAvatars: string[] = [];
    if (project.owner && project.owner.avatar_url) {
      memberAvatars.push(project.owner.avatar_url);
    }
    if (project.memberships) {
      for (const m of project.memberships) {
        if (m.status === 'accepted' && m.user && m.user.avatar_url && m.user.id !== project.owner_id) {
          memberAvatars.push(m.user.avatar_url);
        }
      }
    }

    const updatedAt = project.updated_at
      ? new Date(project.updated_at).toLocaleDateString('fr-FR', {
          day: 'numeric',
          month: 'short',
        })
      : '';

    // Remove relations before sending to match clean model representation
    const raw = project.toJSON();
    delete raw.lists;
    delete raw.memberships;

    return {
      ...raw,
      completedTasks,
      totalTasks,
      memberAvatars,
      updatedAt,
    };
  };

  res.json({
    owned: ownedProjects.map(formatProject),
    collaborated: collaboratedProjects.map(formatProject),
  });
}

export async function createProject(req: Request, res: Response) {
  const body = projectSchema.parse(req.body);

  const project = await Projet.create({
    title: body.title,
    description: body.description ?? null,
    background_color: body.background_color ?? '#0079BF',
    owner_id: req.user!.id,
  });

  await Collaborator.create({
    user_id: req.user!.id,
    project_id: project.id,
    role: 'admin',
  });

  // Auto-create a default list so the frontend can add tasks immediately.
  await List.create({
    title: 'Tasks',
    position: 0,
    project_id: project.id,
  });

  res.status(201).json(project);
}

export async function getProject(req: Request, res: Response) {
  const project = await Projet.findByPk(parseId(req.params.id), {
    include: [
      { model: User, as: 'owner', attributes: ['id', 'full_name', 'email', 'avatar_url'] },
      {
        model: List,
        as: 'lists',
        order: [['position', 'ASC']],
        include: [
          {
            model: Task,
            as: 'tasks',
            order: [['position', 'ASC']],
            include: [
              { model: User, as: 'assignee', attributes: ['id', 'full_name', 'avatar_url'] },
            ],
          },
        ],
      },
      {
        model: Collaborator,
        as: 'memberships',
        include: [{ model: User, as: 'user', attributes: ['id', 'full_name', 'email', 'avatar_url'] }],
      },
    ],
  });

  if (!project) {
    throw new AppError(404, 'Project not found');
  }

  res.json(project);
}

export async function updateProject(req: Request, res: Response) {
  const body = projectSchema.partial().parse(req.body);
  const project = await Projet.findByPk(parseId(req.params.id));

  if (!project) {
    throw new AppError(404, 'Project not found');
  }

  await project.update(body);
  res.json(project);
}

export async function deleteProject(req: Request, res: Response) {
  const project = await Projet.findByPk(parseId(req.params.id));

  if (!project) {
    throw new AppError(404, 'Project not found');
  }

  await project.destroy();
  res.status(204).send();
}

export async function archiveProject(req: Request, res: Response) {
  const body = archiveSchema.parse(req.body);
  const project = await Projet.findByPk(parseId(req.params.id));

  if (!project) {
    throw new AppError(404, 'Project not found');
  }

  await project.update({ is_archived: body.is_archived });
  res.json(project);
}

export async function inviteMember(req: Request, res: Response) {
  const body = memberSchema.parse(req.body);
  const projectId = Number(req.params.id);

  const user = await User.findOne({ where: { email: body.email } });
  if (!user) {
    throw new AppError(404, 'User not found');
  }

  const project = await Projet.findByPk(projectId);
  if (!project) {
    throw new AppError(404, 'Project not found');
  }

  if (project.owner_id === user.id) {
    throw new AppError(400, 'Project owner is already a member');
  }

  const existing = await Collaborator.findOne({
    where: { user_id: user.id, project_id: projectId },
  });
  if (existing) {
    throw new AppError(409, 'User is already a collaborator');
  }

  const membership = await Collaborator.create({
    user_id: user.id,
    project_id: projectId,
    role: body.role,
    status: 'pending',
  });

  await createNotification(user.id, 'project:invite', {
    projectId: project.id,
    projectName: project.title,
    senderName: req.user!.full_name,
    role: body.role,
  });

  res.status(201).json(membership);
}

export async function acceptInvitation(req: Request, res: Response) {
  const projectId = Number(req.params.id);
  const userId = req.user!.id;

  const membership = await Collaborator.findOne({
    where: { user_id: userId, project_id: projectId, status: 'pending' },
  });

  if (!membership) {
    throw new AppError(404, 'No pending invitation found for this project');
  }

  await membership.update({ status: 'accepted' });
  res.json({ message: 'Invitation accepted successfully', membership });
}

export async function declineInvitation(req: Request, res: Response) {
  const projectId = Number(req.params.id);
  const userId = req.user!.id;

  const membership = await Collaborator.findOne({
    where: { user_id: userId, project_id: projectId, status: 'pending' },
  });

  if (!membership) {
    throw new AppError(404, 'No pending invitation found for this project');
  }

  await membership.destroy();
  res.json({ message: 'Invitation declined successfully' });
}

export async function updateMember(req: Request, res: Response) {
  const body = updateMemberSchema.parse(req.body);
  const projectId = Number(req.params.id);
  const userId = Number(req.params.userId);

  const project = await Projet.findByPk(projectId);
  if (!project) {
    throw new AppError(404, 'Project not found');
  }

  if (project.owner_id === userId) {
    throw new AppError(400, 'Cannot change role of project owner');
  }

  const membership = await Collaborator.findOne({
    where: { user_id: userId, project_id: projectId },
  });

  if (!membership) {
    throw new AppError(404, 'Member not found');
  }

  await membership.update({ role: body.role });
  res.json(membership);
}

export async function removeMember(req: Request, res: Response) {
  const projectId = Number(req.params.id);
  const userId = Number(req.params.userId);

  const project = await Projet.findByPk(projectId);
  if (!project) {
    throw new AppError(404, 'Project not found');
  }

  if (project.owner_id === userId) {
    throw new AppError(400, 'Cannot remove project owner');
  }

  const membership = await Collaborator.findOne({
    where: { user_id: userId, project_id: projectId },
  });

  if (!membership) {
    throw new AppError(404, 'Member not found');
  }

  await membership.destroy();
  res.status(204).send();
}
