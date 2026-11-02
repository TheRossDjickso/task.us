'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.addColumn('collaborator', 'status', {
      type: Sequelize.STRING(20),
      allowNull: false,
      defaultValue: 'accepted',
    });

    await queryInterface.sequelize.query(`
      ALTER TABLE collaborator
      ADD CONSTRAINT collaborator_status_check
      CHECK (status IN ('pending', 'accepted'));
    `);
  },

  async down(queryInterface) {
    await queryInterface.sequelize.query(`
      ALTER TABLE collaborator
      DROP CONSTRAINT collaborator_status_check;
    `);
    await queryInterface.removeColumn('collaborator', 'status');
  },
};
