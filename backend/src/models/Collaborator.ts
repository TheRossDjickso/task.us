import { DataTypes, Model, type Sequelize } from 'sequelize';
import type { Projet } from './Projet.js';
import type { User } from './User.js';

export const COLLABORATOR_ROLES = ['admin', 'member', 'viewer'] as const;
export type CollaboratorRole = (typeof COLLABORATOR_ROLES)[number];

export class Collaborator extends Model {
  declare id: number;
  declare user_id: number;
  declare project_id: number;
  declare role: CollaboratorRole;
  declare status: 'pending' | 'accepted';
  declare readonly joined_at: Date;

  declare user?: User;
  declare project?: Projet;
}

export function initCollaborator(sequelize: Sequelize) {
  Collaborator.init(
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      user_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'user',
          key: 'id',
        },
      },
      project_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'projet',
          key: 'id',
        },
      },
      role: {
        type: DataTypes.STRING(20),
        allowNull: false,
        defaultValue: 'member',
        validate: {
          isIn: [COLLABORATOR_ROLES],
        },
      },
      status: {
        type: DataTypes.STRING(20),
        allowNull: false,
        defaultValue: 'accepted',
        validate: {
          isIn: [['pending', 'accepted']],
        },
      },
      joined_at: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
    },
    {
      sequelize,
      tableName: 'collaborator',
      timestamps: false,
      underscored: true,
      indexes: [
        {
          unique: true,
          fields: ['user_id', 'project_id'],
        },
        { fields: ['project_id'] },
        { fields: ['user_id'] },
      ],
    },
  );

  return Collaborator;
}
