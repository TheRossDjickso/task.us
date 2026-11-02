import 'dotenv/config';
import { createServer } from 'node:http';
import path from 'node:path';
import express from 'express';
import { connectDatabase } from './db/index.js';
import { errorHandler } from './middlewares/errorHandler.js';
import { registerRoutes } from './routes/index.js';
import { initSocket } from './services/socket.service.js';

const app = express();
const port = Number(process.env.PORT ?? 3000);
const uploadDir = process.env.UPLOAD_DIR ?? 'uploads';

app.use(express.json());
app.use(`/${uploadDir}`, express.static(path.resolve(uploadDir)));

registerRoutes(app);
app.use(errorHandler);

const server = createServer(app);

async function start() {
  await connectDatabase();
  initSocket(server);

  server.listen(port, '0.0.0.0', () => {
    console.log(`Server is running at http://0.0.0.0:${port}`);
  });
}

start().catch((error) => {
  console.error('Failed to start server:', error);
  process.exit(1);
});
