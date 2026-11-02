import type { Sequelize } from 'sequelize';
import { sequelize } from '../db/sequelize.js';
import { Attachment, initAttachment } from './Attachment.js';
import { Collaborator, initCollaborator } from './Collaborator.js';
import { Comment, initComment } from './Comment.js';
import { Label, initLabel } from './Label.js';
import { List, initList } from './List.js';
import { Notification, initNotification } from './Notification.js';
import { Projet, initProjet } from './Projet.js';
import { Task, initTask } from './Task.js';
import { TaskLabel, initTaskLabel } from './TaskLabel.js';
import { User, initUser } from './User.js';
import { DeviceToken, initDeviceToken } from './DeviceToken.js';

function defineAssociations() {
  User.hasMany(Projet, { foreignKey: 'owner_id', as: 'ownedProjects' });
  Projet.belongsTo(User, { foreignKey: 'owner_id', as: 'owner' });

  User.belongsToMany(Projet, {
    through: Collaborator,
    foreignKey: 'user_id',
    otherKey: 'project_id',
    as: 'collaboratingProjects',
  });
  Projet.belongsToMany(User, {
    through: Collaborator,
    foreignKey: 'project_id',
    otherKey: 'user_id',
    as: 'collaborators',
  });
  Collaborator.belongsTo(User, { foreignKey: 'user_id', as: 'user' });
  Collaborator.belongsTo(Projet, { foreignKey: 'project_id', as: 'project' });
  User.hasMany(Collaborator, { foreignKey: 'user_id', as: 'memberships' });
  Projet.hasMany(Collaborator, { foreignKey: 'project_id', as: 'memberships' });

  Projet.hasMany(List, { foreignKey: 'project_id', as: 'lists' });
  List.belongsTo(Projet, { foreignKey: 'project_id', as: 'project' });

  List.hasMany(Task, { foreignKey: 'list_id', as: 'tasks' });
  Task.belongsTo(List, { foreignKey: 'list_id', as: 'list' });

  Task.belongsTo(User, { foreignKey: 'assigned_to', as: 'assignee' });
  User.hasMany(Task, { foreignKey: 'assigned_to', as: 'assignedTasks' });

  Task.belongsTo(User, { foreignKey: 'created_by', as: 'creator' });
  User.hasMany(Task, { foreignKey: 'created_by', as: 'createdTasks' });

  Projet.hasMany(Label, { foreignKey: 'project_id', as: 'labels' });
  Label.belongsTo(Projet, { foreignKey: 'project_id', as: 'project' });

  Task.belongsToMany(Label, {
    through: TaskLabel,
    foreignKey: 'task_id',
    otherKey: 'label_id',
    as: 'labels',
  });
  Label.belongsToMany(Task, {
    through: TaskLabel,
    foreignKey: 'label_id',
    otherKey: 'task_id',
    as: 'tasks',
  });
  TaskLabel.belongsTo(Task, { foreignKey: 'task_id', as: 'task' });
  TaskLabel.belongsTo(Label, { foreignKey: 'label_id', as: 'label' });

  Task.hasMany(Comment, { foreignKey: 'task_id', as: 'comments' });
  Comment.belongsTo(Task, { foreignKey: 'task_id', as: 'task' });
  Comment.belongsTo(User, { foreignKey: 'user_id', as: 'user' });
  User.hasMany(Comment, { foreignKey: 'user_id', as: 'comments' });

  Comment.belongsTo(Comment, { foreignKey: 'parent_id', as: 'parent' });
  Comment.hasMany(Comment, { foreignKey: 'parent_id', as: 'replies' });

  Task.hasMany(Attachment, { foreignKey: 'task_id', as: 'attachments' });
  Attachment.belongsTo(Task, { foreignKey: 'task_id', as: 'task' });
  Attachment.belongsTo(User, { foreignKey: 'uploaded_by', as: 'uploader' });
  User.hasMany(Attachment, { foreignKey: 'uploaded_by', as: 'uploads' });

  User.hasMany(Notification, { foreignKey: 'user_id', as: 'notifications' });
  Notification.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

  User.hasMany(DeviceToken, { foreignKey: 'user_id', as: 'deviceTokens' });
  DeviceToken.belongsTo(User, { foreignKey: 'user_id', as: 'user' });
}

export function initModels(instance: Sequelize = sequelize) {
  initUser(instance);
  initProjet(instance);
  initCollaborator(instance);
  initList(instance);
  initTask(instance);
  initLabel(instance);
  initTaskLabel(instance);
  initComment(instance);
  initAttachment(instance);
  initNotification(instance);
  initDeviceToken(instance);

  defineAssociations();

  return {
    User,
    Projet,
    Collaborator,
    List,
    Task,
    Label,
    TaskLabel,
    Comment,
    Attachment,
    Notification,
    DeviceToken,
  };
}

export const models = initModels();

export {
  Attachment,
  Collaborator,
  Comment,
  Label,
  List,
  Notification,
  DeviceToken,
  Projet,
  Task,
  TaskLabel,
  User,
};
