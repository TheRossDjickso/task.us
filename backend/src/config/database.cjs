require('dotenv').config();

function parsePort(value, fallback) {
  const port = Number(value ?? fallback);
  if (!Number.isInteger(port) || port <= 0) {
    throw new Error(`Invalid DB_PORT: ${value ?? ''}`);
  }
  return port;
}

function baseConfig() {
  return {
    host: process.env.DB_HOST ?? 'localhost',
    port: parsePort(process.env.DB_PORT, 5432),
    database: process.env.DB_NAME ?? 'col_todo',
    username: process.env.DB_USER ?? 'postgres',
    password: process.env.DB_PASSWORD ?? 'postgres',
    dialect: 'postgres',
  };
}

/** @type {import('sequelize-cli').Config} */
module.exports = {
  development: {
    ...baseConfig(),
    logging: console.log,
  },
  test: {
    ...baseConfig(),
    database: process.env.DB_NAME_TEST ?? `${process.env.DB_NAME ?? 'col_todo'}_test`,
    logging: false,
  },
  production: {
    ...baseConfig(),
    logging: false,
  },
};
