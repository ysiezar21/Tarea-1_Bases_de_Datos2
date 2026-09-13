const express = require('express');
const router = express.Router();
const { sql, config } = require('../db');

// GET /api/persons/all → sp_Person_GetAll
router.get('/all', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().execute('sp_Person_GetAll');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/persons/join → sp_Person_GetWithEmail
router.get('/join', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().execute('sp_Person_GetWithEmail');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/persons/:id → sp_Person_GetById
router.get('/:id', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('BusinessEntityID', sql.Int, parseInt(req.params.id))
      .execute('sp_Person_GetById');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/persons → sp_Person_Insert
router.post('/', async (req, res) => {
  try {
    const { firstName, lastName } = req.body;
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('FirstName', sql.NVarChar(50), firstName)
      .input('LastName',  sql.NVarChar(50), lastName)
      .execute('sp_Person_Insert');
    res.status(201).json({ ok: true, result: result.recordset });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/persons/:id → sp_Person_Update
router.put('/:id', async (req, res) => {
  try {
    const { firstName, lastName } = req.body;
    const pool = await sql.connect(config);
    await pool.request()
      .input('BusinessEntityID', sql.Int, parseInt(req.params.id))
      .input('FirstName', sql.NVarChar(50), firstName)
      .input('LastName',  sql.NVarChar(50), lastName)
      .execute('sp_Person_Update');
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE /api/persons/:id → sp_Person_Delete
router.delete('/:id', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    await pool.request()
      .input('BusinessEntityID', sql.Int, parseInt(req.params.id))
      .execute('sp_Person_Delete');
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
