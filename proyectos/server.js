const express = require('express');
const app = express();

app.use(express.json());

// Ruta raíz de bienvenida
app.get('/', (req, res) => {
  res.json({ message: 'API AdventureWorks funcionando' });
});

// Rutas de personas
app.use('/api/persons', require('./routes/persons'));

// Arrancar servidor
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`API en http://localhost:${PORT}`);
});
