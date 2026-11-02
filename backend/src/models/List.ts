import { DataTypes, Model, type Sequelize } from 'sequelize';
import type { Projet } from './Projet.js';

export class List extends Model {
  declare id: number;
  declare title: string;
  declare position: number;
  declare project_id: number;
  declare readonly created_at: Date;
  declare readonly updated_at: Date;

  declare project?: Projet;
}

export function initList(sequelize: Sequelize) {
  List.init(
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      title: {
        type: DataTypes.STRING(100),
        allowNull: false,
      },
      position: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0,
      },
      project_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'projet',
          key: 'id',
        },
      },
    },
    {
      sequelize,
      tableName: 'list',
      timestamps: true,
      underscored: true,
      indexes: [{ fields: ['project_id'] }],
    },
  );

  return List;
}
