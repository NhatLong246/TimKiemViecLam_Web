const express = require('express');
const router = express.Router();
const { db } = require('../firebase');
const authenticateToken = require('../middleware/auth');

/**
 * @swagger
 * /users:
 *   get:
 *     summary: Lấy danh sách người dùng
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: role
 *         schema:
 *           type: string
 *         description: Lọc theo vai trò (employer, candidate)
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 100
 *     responses:
 *       200:
 *         description: Danh sách người dùng
 *       401:
 *         description: Chưa xác thực
 */
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { role, limit = 100 } = req.query;
    let query = db.collection('users');

    if (role) {
      // Nếu có query role thì KHÔNG dùng orderBy(createdAt) để tránh lỗi thiếu Composite Index của Firebase
      query = query.where('role', '==', role).limit(parseInt(limit));
    } else {
      // Nếu không lọc theo role thì mới sắp xếp
      query = query.orderBy('createdAt', 'desc').limit(parseInt(limit));
    }
    
    const snapshot = await query.get();
    const users = snapshot.docs.map(doc => ({ uid: doc.id, ...doc.data() }));

    res.status(200).json(users);
  } catch (error) {
    console.error('Lỗi khi lấy danh sách user:', error);
    res.status(500).json({ message: 'Lỗi máy chủ nội bộ', error: error.message });
  }
});

/**
 * @swagger
 * /users/{id}:
 *   get:
 *     summary: Lấy thông tin chi tiết một người dùng
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Thông tin người dùng
 *       404:
 *         description: Không tìm thấy người dùng
 */
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const doc = await db.collection('users').doc(req.params.id).get();
    if (!doc.exists) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng' });
    }
    res.status(200).json({ uid: doc.id, ...doc.data() });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi máy chủ nội bộ', error: error.message });
  }
});

/**
 * @swagger
 * /users/{id}/status:
 *   patch:
 *     summary: Cập nhật trạng thái kích hoạt của người dùng
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               isActive:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Đã cập nhật thành công
 */
router.patch('/:id/status', authenticateToken, async (req, res) => {
  try {
    const { isActive } = req.body;
    if (isActive === undefined) {
      return res.status(400).json({ message: 'Thiếu trường isActive' });
    }

    const docRef = db.collection('users').doc(req.params.id);
    await docRef.update({ isActive });

    res.status(200).json({ message: 'Cập nhật trạng thái thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi máy chủ nội bộ', error: error.message });
  }
});

module.exports = router;
