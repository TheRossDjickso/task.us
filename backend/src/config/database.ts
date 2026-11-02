import 'dotenv/config';

export type DatabaseEnv = 'development' | 'test' | 'production';

export interface SequelizeConnectionConfig {
  host: string;
  port: number;
  database: string;
  username: string;
  password: string;
  dialect: 'postgres';
  logging: boolean | ((sql: string) => void);
}

function parsePort(value: string | undefined, fallback: number): number {
  const port = Number(value ?? fallback);
  if (!Number.isInteger(port) || port <= 0) {
    throw new Error(`Invalid DB_PORT: ${value ?? ''}`);
  }
  return port;
}

function getConnectionConfig(): Omit<SequelizeConnectionConfig, 'logging'> {
  return {
    host: process.env.DB_HOST ?? 'localhost',
    port: parsePort(process.env.DB_PORT, 5432),
    database: process.env.DB_NAME ?? 'col_todo',
    username: process.env.DB_USER ?? 'postgres',
    password: process.env.DB_PASSWORD ?? 'postgres',
    dialect: 'postgres',
  };
}

export function getSequelizeConfig(
  env: DatabaseEnv = (process.env.NODE_ENV as DatabaseEnv) ?? 'development',
): SequelizeConnectionConfig {
  const connection = getConnectionConfig();
  const logging =
    env === 'development'
      ? (sql: string) => {
          console.log(`[sequelize] ${sql}`);
        }
      : false;

  return {
    ...connection,
    logging,
  };
}
