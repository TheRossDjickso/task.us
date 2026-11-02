import { DataTypes, Model, type Sequelize } from 'sequelize';
import type { User } from './User.js';

export class DeviceToken extends Model {
  declare id: number;
  declare user_id: number;
  declare token: string;
  declare platform: string;
  declare readonly created_at: Date;
  declare readonly updated_at: Date;

  declare user?: User;
}

export function initDeviceToken(sequelize: Sequelize) {
  DeviceToken.init(
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
      token: {
        type: DataTypes.STRING(512),
        allowNull: false,
        unique: true,
      },
      platform: {
        type: DataTypes.STRING(50),
        allowNull: false,
      },
    },
    {
      sequelize,
      tableName: 'device_token',
      timestamps: true,
      underscored: true,
      indexes: [
        { fields: ['user_id'] },
        { fields: ['token'], unique: true },
      ],
    },
  );

  return DeviceToken;
}
