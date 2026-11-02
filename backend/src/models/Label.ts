import { DataTypes, Model, type Sequelize } from 'sequelize';
import type { Projet } from './Projet.js';

export class Label extends Model {
  declare id: number;
  declare name: string;
  declare color: string;
  declare project_id: number;

  declare project?: Projet;
}

export function initLabel(sequelize: Sequelize) {
  Label.init(
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      name: {
        type: DataTypes.STRING(50),
        allowNull: false,
      },
      color: {
        type: DataTypes.STRING(20),
        allowNull: false,
        defaultValue: '#61BD4F',
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
      tableName: 'label',
      timestamps: false,
      underscored: true,
    },
  );

  return Label;
}
