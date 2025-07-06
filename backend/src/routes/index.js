const express = require('express');
const authRoutes = require('./auth');

const router = express.Router();

// Health check
router.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV 
  });
});

// Rutas de autenticación
router.use('/auth', authRoutes);

module.exports = router; 