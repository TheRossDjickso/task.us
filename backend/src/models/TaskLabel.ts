import { DataTypes, Model, type Sequelize } from 'sequelize';
import type { Label } from './Label.js';
import type { Task } from './Task.js';

export class TaskLabel extends Model {
  declare task_id: number;
  declare label_id: number;

  declare task?: Task;
  declare label?: Label;
}

export function initTaskLabel(sequelize: Sequelize) {
  TaskLabel.init(
    {
      task_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        primaryKey: true,
        references: {
          model: 'task',
          key: 'id',
        },
      },
      label_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        primaryKey: true,
        references: {
          model: 'label',
          key: 'id',
        },
      },
    },
    {
      sequelize,
      tableName: 'task_label',
      timestamps: false,
      underscored: true,
    },
  );

  return TaskLabel;
}
