import { DataTypes, Model, type Sequelize } from 'sequelize';
import type { User } from './User.js';

export class Projet extends Model {
  declare id: number;
  declare title: string;
  declare description: string | null;
  declare background_color: string;
  declare owner_id: number;
  declare is_archived: boolean;
  declare readonly created_at: Date;
  declare readonly updated_at: Date;

  declare owner?: User;
  declare lists?: any[];
  declare memberships?: any[];
}

export function initProjet(sequelize: Sequelize) {
  Projet.init(
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      title: {
        type: DataTypes.STRING(150),
        allowNull: false,
      },
      description: {
        type: DataTypes.STRING(500),
        allowNull: true,
      },
      background_color: {
        type: DataTypes.STRING(20),
        allowNull: false,
        defaultValue: '#0079BF',
      },
      owner_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'user',
          key: 'id',
        },
      },
      is_archived: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
    },
    {
      sequelize,
      tableName: 'projet',
      timestamps: true,
      underscored: true,
    },
  );

  return Projet;
}
