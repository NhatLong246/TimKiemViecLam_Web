require('dotenv').config();
const express = require('express');
const cors = require('cors');
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const authRoutes = require('./routes/auth');
const usersRoutes = require('./routes/users');
const jobsRoutes = require('./routes/jobs');

const app = express();
const PORT = process.env.PORT || 8080;

// Middleware
app.use(cors());
app.use(express.json());

// Swagger cấu hình
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'ViecNow API',
      version: '1.0.0',
      description: 'REST API backend cho dự án ViecNow',
    },
    servers: [
      {
        url: `http://localhost:${PORT}/api`,
        description: 'Local server',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
  },
  // Đường dẫn trỏ tới các file có chứa jsdoc chú thích cho Swagger
  apis: ['./routes/*.js'],
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Đăng ký Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/jobs', jobsRoutes);

// Route mặc định kiểm tra server
app.get('/', (req, res) => {
  res.send('ViecNow Backend Server đang chạy. Truy cập /api-docs để xem tài liệu Swagger.');
});

// Khởi chạy server
app.listen(PORT, () => {
  console.log(`Server đang chạy tại http://localhost:${PORT}`);
  console.log(`Xem tài liệu Swagger tại http://localhost:${PORT}/api-docs`);
});
