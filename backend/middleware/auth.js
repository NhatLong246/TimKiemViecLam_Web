const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (token == null) {
    return res.status(401).json({ message: 'Không tìm thấy token xác thực' });
  }

  jwt.verify(token, process.env.JWT_SECRET || 'ViecNow_Super_Secret_Key_2026', (err, user) => {
    if (err) {
      return res.status(403).json({ message: 'Token không hợp lệ hoặc đã hết hạn' });
    }
    req.user = user;
    next();
  });
};

module.exports = authenticateToken;
