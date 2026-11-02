import { Sequelize } from 'sequelize';
import { getSequelizeConfig } from '../config/database.js';

const config = getSequelizeConfig();

export const sequelize = new Sequelize(
  config.database,
  config.username,
  config.password,
  {
    host: config.host,
    port: config.port,
    dialect: config.dialect,
    logging: config.logging,
  },
);
