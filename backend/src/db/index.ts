import { sequelize } from './sequelize.js';
import '../models/index.js';

export async function connectDatabase(): Promise<void> {
  await sequelize.authenticate();
  console.log('PostgreSQL connection established.');
}

export async function disconnectDatabase(): Promise<void> {
  await sequelize.close();
}

export { sequelize };
