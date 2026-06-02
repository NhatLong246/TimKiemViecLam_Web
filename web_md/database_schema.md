# DATABASE SCHEMA — ViecNow Admin Web

> **AI: Đọc file này trước khi tạo bất kỳ Service, Controller, hoặc query Firebase nào trong web admin.**
> Web admin và app mobile dùng **chung một Firebase project**. KHÔNG tự ý sửa tên collection hay field.
> File này là bản tóm tắt các collection cần dùng ở web admin. Schema đầy đủ xem tại `app_md/database_schema.md`.

---

## Nguyên tắc chung (web admin)
- Web admin chỉ **đọc và cập nhật** data, **KHÔNG tạo mới** document (trừ collection `systemConfig` và `jobCategories`).
- Mọi field timestamp: dùng `FieldValue.serverTimestamp()` khi write, cast `(map['field'] as Timestamp?)?.toDate()` khi read.
- Double cast: `(map['salary'] as num?)?.toDouble() ?? 0.0`
- Trước khi `update()`: luôn kiểm tra document tồn tại bằng `.get()` → `snapshot.exists`.
- Firebase Auth trên web: Chỉ đăng nhập bằng email/password — user phải có `role == "admin"` trong `users/{uid}`.

---

## COLLECTIONS WEB ADMIN CẦN DÙNG

### 1. `users` — Quản lý người dùng
**Path:** `users/{uid}`
**Web admin dùng để:** Xem danh sách, tìm kiếm, khoá (`isActive = false`) / mở khoá tài khoản.

| Field quan trọng | Kiểu | Mô tả |
|---|---|---|
| `uid` | `String` | Firebase Auth UID |
| `role` | `String` | `"candidate"` \| `"employer"` \| `"admin"` |
| `firstName` | `String` | Họ |
| `lastName` | `String` | Tên |
| `username` | `String` | Tên đăng nhập (unique) |
| `email` | `String` | Email |
| `phone` | `String` | SĐT |
| `avatarUrl` | `String?` | URL ảnh đại diện |
| `isVerified` | `bool` | Email đã xác thực chưa |
| `isActive` | `bool` | Tài khoản đang hoạt động (admin có thể đổi field này) |
| `createdAt` | `Timestamp` | Ngày tạo |
| `companyName` | `String?` | (chỉ employer) Tên công ty |
| `walletBalance` | `double` | (chỉ employer) Số dư ví |

**Thao tác admin được phép:**
- `GET` danh sách / tìm theo email, name, role
- `UPDATE` field `isActive` (khoá/mở khoá tài khoản)
- `UPDATE` field `isVerified` (xác thực thủ công)

---

### 2. `jobPosts` — Duyệt tin tuyển dụng
**Path:** `jobPosts/{jobId}`
**Web admin dùng để:** Xem danh sách tin pending, duyệt / từ chối.

| Field quan trọng | Kiểu | Mô tả |
|---|---|---|
| `jobId` | `String` | Auto-generated ID |
| `employerId` | `String` | UID Employer đăng tin |
| `title` | `String` | Tên công việc |
| `description` | `String` | Mô tả chi tiết |
| `category` | `String` | Danh mục (xem danh sách bên dưới) |
| `jobType` | `String` | `"part_time"` \| `"full_time"` |
| `location` | `Map` | `{address, city, district, lat, lng}` |
| `salary` | `double` | Mức lương |
| `salaryType` | `String` | `"per_day"` \| `"per_hour"` \| `"per_month"` \| `"fixed"` |
| `slots` | `int` | Số lượng cần tuyển |
| `startDate` | `Timestamp` | Ngày bắt đầu |
| `status` | `String` | `"pending"` \| `"approved"` \| `"active"` \| `"closed"` \| `"rejected"` |
| `totalBudget` | `double` | Tổng ngân sách đã khóa |
| `createdAt` | `Timestamp` | Ngày tạo |

**Thao tác admin được phép:**
- `GET` danh sách lọc theo `status`
- `UPDATE` field `status` (duyệt → `"approved"` hoặc từ chối → `"rejected"`)
- `UPDATE` field `rejectionReason` (lý do từ chối, cần thêm field này nếu chưa có)

**Danh mục công việc (`category`):**
`"boc_vac"` | `"lau_don"` | `"bung_be"` | `"phuc_vu"` | `"pha_che"` | `"tiep_thi"` | `"van_chuyen"` | `"bao_ve"` | `"other"`

---

### 3. `applications` — Thống kê ứng tuyển
**Path:** `applications/{appId}`
**Web admin dùng để:** Xem số liệu thống kê, báo cáo.

| Field quan trọng | Kiểu | Mô tả |
|---|---|---|
| `appId` | `String` | ID |
| `jobId` | `String` | Ref đến job |
| `candidateId` | `String` | UID Candidate |
| `employerId` | `String` | UID Employer |
| `status` | `String` | `"pending"` \| `"accepted"` \| `"rejected"` \| `"withdrawn"` |
| `appliedAt` | `Timestamp` | Ngày ứng tuyển |

**Thao tác admin được phép:** `GET` chỉ đọc để thống kê.

---

### 4. `transactions` — Doanh thu & giao dịch
**Path:** `transactions/{txnId}`
**Web admin dùng để:** Xem báo cáo doanh thu, lịch sử giao dịch.

| Field quan trọng | Kiểu | Mô tả |
|---|---|---|
| `txnId` | `String` | ID |
| `userId` | `String` | UID chủ sở hữu |
| `type` | `String` | `"deposit"` \| `"payment"` \| `"withdrawal"` \| `"refund"` \| `"hold"` |
| `amount` | `double` | Số tiền |
| `balanceBefore` | `double` | Số dư trước |
| `balanceAfter` | `double` | Số dư sau |
| `jobId` | `String?` | Ref đến job liên quan |
| `status` | `String` | `"pending"` \| `"completed"` \| `"failed"` |
| `createdAt` | `Timestamp` | Timestamp giao dịch |

**Thao tác admin được phép:** `GET` chỉ đọc để báo cáo.

---

### 5. `jobComplaints` — Khiếu nại công việc
**Path:** `jobComplaints/{complaintId}`
**Web admin dùng để:** Xem và phân xử khiếu nại/sự cố từ app mobile.

| Field | Kiểu | Mô tả |
|---|---|---|
| `complaintId` | `String` | Auto-generated (doc.id) |
| `jobId` | `String` | Job liên quan |
| `groupId` | `String` | Group chat liên quan |
| `employerId` | `String` | UID Employer |
| `candidateId` | `String` | UID Candidate |
| `jobTitle` | `String` | Tên công việc |
| `description` | `String` | Nội dung khiếu nại |
| `imageBase64s` | `List<String>` | Bằng chứng ảnh |
| `status` | `String` | `"pending"` \| `"processing"` \| `"resolved"` \| `"rejected"` |
| `resolution` | `String?` | Kết quả xử lý (admin ghi) |
| `resolvedBy` | `String?` | UID admin xử lý |
| `createdAt` | `Timestamp` | Thời điểm tạo |
| `updatedAt` | `Timestamp` | Lần cập nhật cuối |

**Thao tác admin được phép:**
- `GET` danh sách, lọc theo `status`
- `UPDATE` field `status`, `resolution`, `resolvedBy`

---

### 5.1 `disbursementNotices` — Giải ngân
**Path:** `disbursementNotices/{noticeId}`
**Web admin dùng để:** Duyệt yêu cầu giải ngân từ Employer.

| Field | Kiểu | Mô tả |
|---|---|---|
| `noticeId` | `String` | Auto-generated (doc.id) |
| `jobId` | `String` | Job liên quan |
| `groupId` | `String` | Group chat liên quan |
| `employerId` | `String` | UID Employer |
| `workDate` | `String` | `"YYYY-MM-DD"` |
| `amount` | `double` | Số tiền giải ngân |
| `status` | `String` | `"pending_ack"` \| `"cleared"` \| `"rejected"` |
| `employerAck` | `bool` | NTD đã xác nhận |
| `adminAck` | `bool` | Admin đã xác nhận (Duyệt) |
| `rejectionReason` | `String?` | Lý do từ chối (Admin ghi) |
| `createdAt` | `Timestamp` | Thời điểm tạo |

**Thao tác admin được phép:**
- `GET` danh sách, lọc theo `status`
- `UPDATE` field `adminAck`, `status`, `rejectionReason`

---

### 6. `jobCategories` — Danh mục nghề nghiệp
**Path:** `jobCategories/{categoryId}`
**Web admin dùng để:** Xem, thêm, sửa, xóa danh mục.

| Field | Kiểu | Mô tả |
|---|---|---|
| `categoryId` | `String` | Auto-generated |
| `key` | `String` | Unique key (vd: `"bung_be"`) |
| `label` | `String` | Tên hiển thị (vd: `"Bưng bê"`) |
| `iconUrl` | `String?` | URL icon |
| `isActive` | `bool` | Đang hiển thị trong app không |
| `order` | `int` | Thứ tự hiển thị |
| `createdAt` | `Timestamp` | Server timestamp |

**Duplicate check:** Kiểm tra `key` không trùng trước khi tạo mới.

---

### 7. `systemConfig` — Cấu hình hệ thống
**Path:** `systemConfig/general` (single document)
**Web admin dùng để:** Đọc và cập nhật cấu hình toàn hệ thống.

| Field | Kiểu | Mô tả |
|---|---|---|
| `platformFeePercent` | `double` | % phí nền tảng (mặc định: 5.0) |
| `minDepositAmount` | `double` | Số tiền nạp tối thiểu |
| `minWithdrawalAmount` | `double` | Số tiền rút tối thiểu |
| `maintenanceMode` | `bool` | Bật/tắt bảo trì |
| `updatedAt` | `Timestamp` | Lần cập nhật cuối |
| `updatedBy` | `String` | UID admin cập nhật |

---

## Quy tắc bắt buộc (web admin)
1. **KHÔNG xóa** document user, jobPosts, transactions — chỉ cập nhật trạng thái.
2. **Khi duyệt job:** Chỉ đổi `status` — không sửa bất kỳ field nào khác.
3. **Khi khoá user:** Chỉ đổi `isActive = false` — không xóa document.
4. **Phí tối thiểu:** Khi cập nhật `systemConfig`, luôn validate `platformFeePercent` trong khoảng `0.0 → 30.0`.
5. **Pagination:** Các query danh sách phải dùng `.limit(20)` + `startAfterDocument` — không query toàn bộ collection.
6. **Index:** Các query kết hợp nhiều `where()` cần tạo Composite Index trên Firebase Console.
