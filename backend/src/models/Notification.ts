import { DataTypes, Model, type Sequelize } from 'sequelize';
import type { User } from './User.js';

export class Notification extends Model {
  declare id: number;
  declare user_id: number;
  declare type: string;
  declare payload: Record<string, unknown>;
  declare is_read: boolean;
  declare readonly created_at: Date;

  declare user?: User;
}

export function initNotification(sequelize: Sequelize) {
  Notification.init(
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
      type: {
        type: DataTypes.STRING(50),
        allowNull: false,
      },
      payload: {
        type: DataTypes.JSONB,
        allowNull: false,
        defaultValue: {},
      },
      is_read: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
    },
    {
      sequelize,
      tableName: 'notification',
      timestamps: true,
      updatedAt: false,
      underscored: true,
      indexes: [
        { fields: ['user_id'] },
        { fields: ['user_id', 'is_read'] },
      ],
    },
  );

  return Notification;
}
