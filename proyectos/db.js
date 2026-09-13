const sql = require('mssql');

const config = {
  user: 'sa',
  password: 'Ydsch210306$',
  server: 'localhost',
  database: 'AdventureWorks',
  options: {
    encrypt: false,
    trustServerCertificate: true,
    enableArithAbort: true
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
  }
};

module.exports = { sql, config };
