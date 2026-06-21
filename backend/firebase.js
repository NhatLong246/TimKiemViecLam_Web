const admin = require('firebase-admin');
let serviceAccount;

try {
  serviceAccount = require('./firebase-key.json');
} catch (e) {
  console.warn('Cảnh báo: Không tìm thấy file firebase-key.json, cấu hình Firebase có thể bị lỗi.');
}

// Khởi tạo Firebase Admin SDK
try {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log("Firebase Admin đã kết nối thành công!");
} catch (e) {
  console.error("Lỗi khi kết nối Firebase:", e.message);
}

const db = admin.firestore();

module.exports = { admin, db };
