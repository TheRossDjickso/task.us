'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.addColumn('projet', 'is_archived', {
      type: Sequelize.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    });

    await queryInterface.addColumn('task', 'position', {
      type: Sequelize.INTEGER,
      allowNull: false,
      defaultValue: 0,
    });

    await queryInterface.addColumn('user', 'password_reset_token', {
      type: Sequelize.STRING(255),
      allowNull: true,
    });

    await queryInterface.addColumn('user', 'password_reset_expires', {
      type: Sequelize.DATE,
      allowNull: true,
    });
  },

  async down(queryInterface) {
    await queryInterface.removeColumn('user', 'password_reset_expires');
    await queryInterface.removeColumn('user', 'password_reset_token');
    await queryInterface.removeColumn('task', 'position');
    await queryInterface.removeColumn('projet', 'is_archived');
  },
};
