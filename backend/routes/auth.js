const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const { db } = require('../firebase');

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Đăng nhập
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - username
 *               - password
 *             properties:
 *               username:
 *                 type: string
 *               password:
 *                 type: string
 *     responses:
 *       200:
 *         description: Đăng nhập thành công, trả về JWT Token
 *       401:
 *         description: Sai thông tin đăng nhập
 */
router.post('/login', async (req, res) => {
  const { username, password } = req.body;

  // Xử lý đăng nhập cứng (Admin) giống như app cũ của bạn
  if (username === 'admin' && password === '123@456') {
    const userPayload = {
      uid: 'admin_uid_123',
      role: 'admin',
      username: 'admin'
    };

    const token = jwt.sign(
      userPayload, 
      process.env.JWT_SECRET || 'ViecNow_Super_Secret_Key_2026', 
      { expiresIn: '24h' }
    );

    return res.status(200).json({
      message: 'Đăng nhập thành công',
      token: token,
      user: userPayload
    });
  }

  // TODO: Tích hợp query Firebase để tìm user và so sánh password nếu có hệ thống user thật
  // Ví dụ:
  // const snapshot = await db.collection('users').where('username', '==', username).get();
  // ... xử lý kiểm tra mật khẩu ...

  return res.status(401).json({ message: 'Tên đăng nhập hoặc mật khẩu không chính xác' });
});

module.exports = router;
