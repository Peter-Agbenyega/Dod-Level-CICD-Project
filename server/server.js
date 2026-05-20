const app = require('./app');

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`[Reference Server] API running on port ${PORT}`);
  console.log(`[Reference Server] Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`[Reference Server] Health check: http://localhost:${PORT}/api/health`);
});
