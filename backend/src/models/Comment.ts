import { DataTypes, Model, type Sequelize } from 'sequelize';
import type { Task } from './Task.js';
import type { User } from './User.js';

export class Comment extends Model {
  declare id: number;
  declare content: string;
  declare user_id: number;
  declare task_id: number;
  declare parent_id: number | null;
  declare readonly created_at: Date;
  declare readonly updated_at: Date;

  declare user?: User;
  declare task?: Task;
  declare parent?: Comment;
  declare replies?: Comment[];
}

export function initComment(sequelize: Sequelize) {
  Comment.init(
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      content: {
        type: DataTypes.TEXT,
        allowNull: false,
      },
      user_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'user',
          key: 'id',
        },
      },
      task_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'task',
          key: 'id',
        },
      },
      parent_id: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
          model: 'comment',
          key: 'id',
        },
      },
    },
    {
      sequelize,
      tableName: 'comment',
      timestamps: true,
      underscored: true,
      indexes: [{ fields: ['task_id'] }],
    },
  );

  return Comment;
}
