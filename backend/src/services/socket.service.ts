import type { Server as HttpServer } from 'node:http';
import { Server } from 'socket.io';

let io: Server | null = null;

export function initSocket(httpServer: HttpServer) {
  io = new Server(httpServer, {
    cors: { origin: process.env.FRONTEND_URL ?? '*' },
  });

  io.on('connection', (socket) => {
    socket.on('join:project', (projectId: number) => {
      socket.join(`project:${projectId}`);
    });

    socket.on('join:user', (userId: number) => {
      socket.join(`user:${userId}`);
    });

    socket.on('join:task', (taskId: number) => {
      socket.join(`task:${taskId}`);
    });
  });

  return io;
}

export function getIO() {
  return io;
}

export function emitToProject(
  projectId: number,
  event: string,
  data: unknown,
) {
  io?.to(`project:${projectId}`).emit(event, data);
}

export function emitToUser(userId: number, event: string, data: unknown) {
  io?.to(`user:${userId}`).emit(event, data);
}

export function emitToTask(taskId: number, event: string, data: unknown) {
  io?.to(`task:${taskId}`).emit(event, data);
}
