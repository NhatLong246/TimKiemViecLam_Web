const express = require('express');
const router = express.Router();
const { db } = require('../firebase');
const authenticateToken = require('../middleware/auth');
const admin = require('firebase-admin');

/**
 * @swagger
 * /jobs:
 *   get:
 *     summary: Lấy danh sách tin tuyển dụng
 *     tags: [Job Posts]
 *     parameters:
 *       - in: query
 *         name: employerId
 *         schema:
 *           type: string
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 20
 *     responses:
 *       200:
 *         description: Danh sách tin tuyển dụng
 */
router.get('/', async (req, res) => {
  try {
    const { employerId, limit = 20 } = req.query;
    let query = db.collection('jobPosts');

    if (employerId) {
      query = query.where('employerId', '==', employerId);
    } else {
      query = query.orderBy('createdAt', 'desc');
    }
    
    query = query.limit(parseInt(limit));
    
    const snapshot = await query.get();
    const jobs = snapshot.docs.map(doc => ({ jobId: doc.id, ...doc.data() }));

    res.status(200).json(jobs);
  } catch (error) {
    console.error('Lỗi khi lấy danh sách việc làm:', error);
    res.status(500).json({ message: 'Lỗi máy chủ nội bộ', error: error.message });
  }
});

/**
 * @swagger
 * /jobs/{id}/status:
 *   patch:
 *     summary: Cập nhật trạng thái duyệt tin tuyển dụng
 *     tags: [Job Posts]
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
 *             required:
 *               - status
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [pending, approved, rejected, closed]
 *               rejectionReason:
 *                 type: string
 *     responses:
 *       200:
 *         description: Đã cập nhật thành công
 */
router.patch('/:id/status', authenticateToken, async (req, res) => {
  try {
    const { status, rejectionReason } = req.body;
    if (!status) {
      return res.status(400).json({ message: 'Thiếu trường status' });
    }

    const docRef = db.collection('jobPosts').doc(req.params.id);
    const doc = await docRef.get();
    if (!doc.exists) {
        return res.status(404).json({ message: 'Không tìm thấy tin tuyển dụng' });
    }

    const updateData = { 
      status,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };
    
    if (rejectionReason) {
      updateData.rejectionReason = rejectionReason;
    }

    await docRef.update(updateData);

    res.status(200).json({ message: 'Cập nhật trạng thái tin tuyển dụng thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi máy chủ nội bộ', error: error.message });
  }
});

/**
 * @swagger
 * /jobs/{id}:
 *   delete:
 *     summary: Xóa tin tuyển dụng
 *     tags: [Job Posts]
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
 *         description: Đã xóa thành công
 */
router.delete('/:id', authenticateToken, async (req, res) => {
    try {
        await db.collection('jobPosts').doc(req.params.id).delete();
        res.status(200).json({ message: 'Xóa tin tuyển dụng thành công' });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi máy chủ nội bộ', error: error.message });
    }
});

module.exports = router;
