const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { PrismaPg } = require('@prisma/adapter-pg');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();

// Konfigurasi Driver Adapter untuk PostgreSQL
const connectionString = "postgresql://postgres:1234@localhost:5432/ecoguard_db?schema=public";
const pool = new Pool({ connectionString });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

app.use(cors({
    origin: '*', // Mengizinkan semua origin termasuk Flutter Web
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

app.get('/', (req, res) => res.send("EcoGuard API Active!"));

app.get('/transactions', async (req, res) => {
  try {
    const data = await prisma.transaction.findMany({ orderBy: { createdAt: 'desc' } });
    res.json(data);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/transactions', async (req, res) => {
  const { title, amount, type, category } = req.body;
  try {
    const result = await prisma.transaction.create({
      data: { title, amount: parseFloat(amount), type, category }
    });
    res.json(result);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// API untuk menghapus transaksi berdasarkan ID
app.delete('/transactions/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await prisma.transaction.delete({
      where: { id: parseInt(id) }
    });
    res.json({ message: "Transaksi berhasil dihapus", result });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.listen(3000, () => console.log("🚀 Server EcoGuard ON di Port 3000"));