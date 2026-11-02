import { DataTypes, Model, type Sequelize } from 'sequelize';
import type { List } from './List.js';
import type { User } from './User.js';

export const TASK_PRIORITIES = [1, 2, 3] as const;
export type TaskPriority = (typeof TASK_PRIORITIES)[number];

export class Task extends Model {
  declare id: number;
  declare title: string;
  declare description: string | null;
  declare is_done: boolean;
  declare priority: TaskPriority;
  declare due_date: string | null;
  declare list_id: number;
  declare position: number;
  declare assigned_to: number | null;
  declare created_by: number;
  declare readonly created_at: Date;
  declare readonly updated_at: Date;

  declare list?: List;
  declare assignee?: User;
  declare creator?: User;
}

export function initTask(sequelize: Sequelize) {
  Task.init(
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      title: {
        type: DataTypes.STRING(200),
        allowNull: false,
      },
      description: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      is_done: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
      priority: {
        type: DataTypes.SMALLINT,
        allowNull: false,
        defaultValue: 1,
        validate: {
          isIn: [TASK_PRIORITIES],
        },
      },
      due_date: {
        type: DataTypes.DATEONLY,
        allowNull: true,
      },
      list_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'list',
          key: 'id',
        },
      },
      position: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0,
      },
      assigned_to: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
          model: 'user',
          key: 'id',
        },
      },
      created_by: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'user',
          key: 'id',
        },
      },
    },
    {
      sequelize,
      tableName: 'task',
      timestamps: true,
      underscored: true,
      indexes: [
        { fields: ['list_id'] },
        { fields: ['assigned_to'] },
      ],
    },
  );

  return Task;
}
