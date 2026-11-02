import { DataTypes, Model, type Sequelize } from 'sequelize';

export class User extends Model {
  declare id: number;
  declare full_name: string;
  declare email: string;
  declare password_hash: string;
  declare avatar_url: string | null;
  declare password_reset_token: string | null;
  declare password_reset_expires: Date | null;
  declare readonly created_at: Date;
  declare readonly updated_at: Date;
}

export function initUser(sequelize: Sequelize) {
  User.init(
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      full_name: {
        type: DataTypes.STRING(100),
        allowNull: false,
      },
      email: {
        type: DataTypes.STRING(150),
        allowNull: false,
        unique: true,
      },
      password_hash: {
        type: DataTypes.STRING(255),
        allowNull: false,
      },
      avatar_url: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      password_reset_token: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      password_reset_expires: {
        type: DataTypes.DATE,
        allowNull: true,
      },
    },
    {
      sequelize,
      tableName: 'user',
      timestamps: true,
      underscored: true,
    },
  );

  return User;
}
