'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('user', {
      id: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      full_name: {
        type: Sequelize.STRING(100),
        allowNull: false,
      },
      email: {
        type: Sequelize.STRING(150),
        allowNull: false,
        unique: true,
      },
      password_hash: {
        type: Sequelize.STRING(255),
        allowNull: false,
      },
      avatar_url: {
        type: Sequelize.STRING(255),
        allowNull: true,
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('NOW()'),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('NOW()'),
      },
    });

    await queryInterface.createTable('projet', {
      id: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      title: {
        type: Sequelize.STRING(150),
        allowNull: false,
      },
      description: {
        type: Sequelize.STRING(500),
        allowNull: true,
      },
      background_color: {
        type: Sequelize.STRING(20),
        allowNull: false,
        defaultValue: '#0079BF',
      },
      owner_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'user', key: 'id' },
        onDelete: 'CASCADE',
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('NOW()'),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('NOW()'),
      },
    });

    await queryInterface.createTable('collaborator', {
      id: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      user_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'user', key: 'id' },
        onDelete: 'CASCADE',
      },
      project_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'projet', key: 'id' },
        onDelete: 'CASCADE',
      },
      role: {
        type: Sequelize.STRING(20),
        allowNull: false,
        defaultValue: 'member',
      },
      joined_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('NOW()'),
      },
    });

    await queryInterface.sequelize.query(`
      ALTER TABLE collaborator
      ADD CONSTRAINT collaborator_role_check
      CHECK (role IN ('admin', 'member', 'viewer'));
    `);

    await queryInterface.addIndex('collaborator', ['user_id', 'project_id'], {
      unique: true,
      name: 'collaborator_user_id_project_id_unique',
    });
    await queryInterface.addIndex('collaborator', ['project_id'], {
      name: 'idx_collaborator_project_id',
    });
    await queryInterface.addIndex('collaborator', ['user_id'], {
      name: 'idx_collaborator_user_id',
    });

    await queryInterface.createTable('list', {
      id: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      title: {
        type: Sequelize.STRING(100),
        allowNull: false,
      },
      position: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 0,
      },
      project_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'projet', key: 'id' },
        onDelete: 'CASCADE',
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('NOW()'),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('NOW()'),
      },
    });

    await queryInterface.addIndex('list', ['project_id'], {
      name: 'idx_list_project_id',
    });

    await queryInterface.createTable('task', {
      id: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      title: {
        type: Sequelize.STRING(200),
        allowNull: false,
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      is_done: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
      priority: {
        type: Sequelize.SMALLINT,
        allowNull: false,
        defaultValue: 1,
      },
      due_date: {
        type: Sequelize.DATEONLY,
        allowNull: true,
      },
      list_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'list', key: 'id' },
        onDelete: 'CASCADE',
      },
      assigned_to: {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: { model: 'user', key: 'id' },
        onDelete: 'SET NULL',
      },
      created_by: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'user', key: 'id' },
        onDelete: 'CASCADE',
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('NOW()'),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('NOW()'),
      },
    });

    await queryInterface.sequelize.query(`
      ALTER TABLE task
      ADD CONSTRAINT task_priority_check
      CHECK (priority IN (1, 2, 3));
    `);

    await queryInterface.addIndex('task', ['list_id'], {
      name: 'idx_task_list_id',
    });
    await queryInterface.addIndex('task', ['assigned_to'], {
      name: 'idx_task_assigned_to',
    });

    await queryInterface.createTable('label', {
      id: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      name: {
        type: Sequelize.STRING(50),
        allowNull: false,
      },
      color: {
        type: Sequelize.STRING(20),
        allowNull: false,
        defaultValue: '#61BD4F',
      },
      project_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'projet', key: 'id' },
        onDelete: 'CASCADE',
      },
    });

    await queryInterface.createTable('task_label', {
      task_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        primaryKey: true,
        references: { model: 'task', key: 'id' },
        onDelete: 'CASCADE',
      },
      label_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        primaryKey: true,
        references: { model: 'label', key: 'id' },
        onDelete: 'CASCADE',
      },
    });

    await queryInterface.createTable('comment', {
      id: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      content: {
        type: Sequelize.TEXT,
        allowNull: false,
      },
      user_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'user', key: 'id' },
        onDelete: 'CASCADE',
      },
      task_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'task', key: 'id' },
        onDelete: 'CASCADE',
      },
      parent_id: {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: { model: 'comment', key: 'id' },
        onDelete: 'CASCADE',
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('NOW()'),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('NOW()'),
      },
    });

    await queryInterface.addIndex('comment', ['task_id'], {
      name: 'idx_comment_task_id',
    });

    await queryInterface.createTable('attachment', {
      id: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      filename: {
        type: Sequelize.STRING(255),
        allowNull: false,
      },
      url: {
        type: Sequelize.STRING(500),
        allowNull: false,
      },
      task_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'task', key: 'id' },
        onDelete: 'CASCADE',
      },
      uploaded_by: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'user', key: 'id' },
        onDelete: 'CASCADE',
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('NOW()'),
      },
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('attachment');
    await queryInterface.dropTable('comment');
    await queryInterface.dropTable('task_label');
    await queryInterface.dropTable('label');
    await queryInterface.dropTable('task');
    await queryInterface.dropTable('list');
    await queryInterface.dropTable('collaborator');
    await queryInterface.dropTable('projet');
    await queryInterface.dropTable('user');
  },
};
