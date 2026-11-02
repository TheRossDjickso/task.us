'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('device_token', {
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
      token: {
        type: Sequelize.STRING(512),
        allowNull: false,
        unique: true,
      },
      platform: {
        type: Sequelize.STRING(50),
        allowNull: false,
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

    await queryInterface.addIndex('device_token', ['user_id'], {
      name: 'idx_device_token_user_id',
    });
    await queryInterface.addIndex('device_token', ['token'], {
      name: 'idx_device_token_token',
      unique: true,
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('device_token');
  },
};
