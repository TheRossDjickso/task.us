import { DataTypes, Model, type Sequelize } from 'sequelize';
import type { Task } from './Task.js';
import type { User } from './User.js';

export class Attachment extends Model {
  declare id: number;
  declare filename: string;
  declare url: string;
  declare task_id: number;
  declare uploaded_by: number;
  declare readonly created_at: Date;

  declare task?: Task;
  declare uploader?: User;
}

export function initAttachment(sequelize: Sequelize) {
  Attachment.init(
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      filename: {
        type: DataTypes.STRING(255),
        allowNull: false,
      },
      url: {
        type: DataTypes.STRING(500),
        allowNull: false,
      },
      task_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'task',
          key: 'id',
        },
      },
      uploaded_by: {
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
      tableName: 'attachment',
      timestamps: true,
      updatedAt: false,
      underscored: true,
    },
  );

  return Attachment;
}
