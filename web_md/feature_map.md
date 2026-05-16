# FEATURE MAP — ViecNow Admin Web

> **AI:** Kiểm tra file này trước khi code một tính năng mới để tránh làm trùng hoặc sai phạm vi.
> Sau khi hoàn thành một feature, cập nhật status tại đây VÀ tóm tắt vào `MEMORY.md`.

## Trạng thái ký hiệu
- `✅` Done — Đã hoàn thành, có thể tham chiếu
- `🔄` In Progress — Đang làm
- `❌` Not Started — Chưa làm
- `⚠️` Needs Fix — Có vấn đề cần sửa

---

## LAYOUT & SHELL

| # | Tính năng | File chính | Status | Ghi chú |
|---|---|---|---|---|
| L1 | MainScreen (shell có SideMenu + content) | `views/dashboard/main_screen.dart` | ✅ | Row: SideMenu flex 1 + content flex 5 |
| L2 | SideMenu (navigation trái) | `views/dashboard/components/side_menu.dart` | ✅ | Navigate: dashboard, jobs; logout có dialog; các mục khác chưa wire |
| L3 | Header (thanh tiêu đề + search + avatar) | `views/dashboard/components/header.dart` | ✅ | Cần kết nối search và profile |
| L4 | Responsive layout (Desktop/Tablet/Mobile) | `responsive.dart` | ✅ | Breakpoints: 1100, 650 |
| L5 | Đăng nhập Admin | `views/auth/login_page.dart` | ✅ | Username/Password, SharedPreferences |
| L6 | Routing theo trạng thái login | `main.dart` | ⚠️ | Chưa check Firebase Auth — đang dùng SharedPreferences hardcode |
| L7 | Navigation giữa các trang (SideMenu → content) | `controllers/menu_app_controller.dart` | ✅ | `currentPage`: `dashboard` \| `jobs`; mở rộng thêm page khi có màn mới |

---

## DASHBOARD TỔNG QUAN

| # | Tính năng | File chính | Status | Ghi chú |
|---|---|---|---|---|
| D1 | Summary cards (4 chỉ số) | `views/dashboard/components/summary_cards.dart` | ✅ | Tổng user, job mở, ứng tuyển, công ty |
| D2 | Biểu đồ đường (lượt ứng tuyển theo tuần) | `views/dashboard/components/chart_section.dart` | ✅ | fl_chart LineChart |
| D3 | Biểu đồ tròn (trạng thái ứng tuyển) | `views/dashboard/components/chart_section.dart` | ✅ | PieChart: hired/pending/interview/rejected |
| D4 | DashboardController (fetch Firestore) | `controllers/dashboard_controller.dart` | ✅ | Fetch users, jobs, applications, companies |
| D5 | Biểu đồ cột (job mới theo tháng) | Chưa có | ❌ | BarChart theo 12 tháng |
| D6 | Biểu đồ doanh thu theo thời gian | Chưa có | ❌ | Filter: Tuần / Tháng / Năm |
| D7 | Feed hoạt động gần đây (recent activity) | Chưa có | ❌ | 10 hành động gần nhất: user mới, job mới, giao dịch |

---

## QUẢN LÝ NGƯỜI DÙNG

| # | Tính năng | File chính | Status | Ghi chú |
|---|---|---|---|---|
| U1 | Danh sách người dùng (table) | `views/users/user_list_screen.dart` | ❌ | Phân trang, lọc theo role |
| U2 | Tìm kiếm người dùng | `views/users/user_list_screen.dart` | ❌ | Tìm theo email, tên, username |
| U3 | Xem chi tiết người dùng | `views/users/user_detail_screen.dart` | ❌ | Thông tin đầy đủ + lịch sử hoạt động |
| U4 | Khoá / Mở khoá tài khoản | `controllers/user_management_controller.dart` | ❌ | UPDATE `isActive` trong Firestore |
| U5 | Xác thực tài khoản thủ công | `controllers/user_management_controller.dart` | ❌ | UPDATE `isVerified = true` |
| U6 | Danh sách Employer | `views/users/employer_list_screen.dart` | ❌ | Lọc `role == "employer"`, hiện số dư ví |
| U7 | Danh sách Candidate | `views/users/candidate_list_screen.dart` | ❌ | Lọc `role == "candidate"`, hiện rating |
| U8 | Export danh sách người dùng (CSV) | - | ❌ | Tương lai |

---

## DUYỆT TIN TUYỂN DỤNG

| # | Tính năng | File chính | Status | Ghi chú |
|---|---|---|---|---|
| J1 | Danh sách tin chờ duyệt | `views/post/job_posts_screen.dart` | ✅ | Lọc chip `pending`; gộp trong màn danh sách chung |
| J2 | Xem chi tiết tin tuyển dụng | `views/post/` (chưa có) | ❌ | Cần `job_detail_screen.dart` hoặc dialog |
| J3 | Duyệt tin | `controllers/job_post_controller.dart` | ✅ | `JobPostService.updateJobStatus` → `approved` |
| J4 | Từ chối tin (kèm lý do) | `controllers/job_post_controller.dart` | ✅ | → `rejected` + `rejectionReason` (tùy chọn) |
| J5 | Danh sách tất cả tin (filter theo status) | `views/post/job_posts_screen.dart` | ✅ | Chip: all / draft / pending / approved / active / closed / rejected |
| J6 | Tìm kiếm tin tuyển dụng | `views/post/job_posts_screen.dart` | ✅ | Client-side: tiêu đề, danh mục, địa điểm, employerId |
| J7 | Đóng tin tuyển dụng (admin force close) | — | ❌ | UPDATE `status = "closed"` + lý do |

---

## XỬ LÝ TRANH CHẤP

| # | Tính năng | File chính | Status | Ghi chú |
|---|---|---|---|---|
| DI1 | Danh sách tranh chấp đang mở | `views/disputes/dispute_list_screen.dart` | ❌ | Lọc `status == "open"` |
| DI2 | Xem chi tiết tranh chấp + bằng chứng | `views/disputes/dispute_detail_screen.dart` | ❌ | Hiện evidence (ảnh/video) |
| DI3 | Phân xử tranh chấp (ghi resolution) | `controllers/dispute_controller.dart` | ❌ | UPDATE `status = "resolved"` + `resolution` |
| DI4 | Bác bỏ tranh chấp | `controllers/dispute_controller.dart` | ❌ | UPDATE `status = "dismissed"` |
| DI5 | Lịch sử tranh chấp đã xử lý | `views/disputes/dispute_history_screen.dart` | ❌ | Lọc `status == "resolved" / "dismissed"` |

---

## BÁO CÁO DOANH THU

| # | Tính năng | File chính | Status | Ghi chú |
|---|---|---|---|---|
| R1 | Tổng quan doanh thu (summary cards) | `views/revenue/revenue_screen.dart` | ❌ | Tổng giao dịch, tổng nạp tiền, tổng phí nền tảng |
| R2 | Biểu đồ doanh thu theo thời gian | `views/revenue/revenue_screen.dart` | ❌ | LineChart + BarChart, filter tháng/năm |
| R3 | Bảng lịch sử giao dịch | `views/revenue/transaction_list_screen.dart` | ❌ | Phân trang, lọc theo loại giao dịch |
| R4 | Xem chi tiết giao dịch | `views/revenue/transaction_detail_screen.dart` | ❌ | |
| R5 | Export báo cáo CSV/PDF | - | ❌ | Tương lai |

---

## QUẢN LÝ DANH MỤC NGHỀ NGHIỆP

| # | Tính năng | File chính | Status | Ghi chú |
|---|---|---|---|---|
| C1 | Danh sách danh mục | `views/categories/category_list_screen.dart` | ❌ | Từ collection `jobCategories` |
| C2 | Thêm danh mục mới | `views/categories/category_form_screen.dart` | ❌ | Check duplicate `key` trước khi tạo |
| C3 | Sửa danh mục | `views/categories/category_form_screen.dart` | ❌ | Tái sử dụng form |
| C4 | Ẩn/Hiện danh mục | `controllers/category_controller.dart` | ❌ | UPDATE `isActive` |
| C5 | Sắp xếp thứ tự danh mục | `controllers/category_controller.dart` | ❌ | Drag-and-drop hoặc order input |

---

## CÀI ĐẶT HỆ THỐNG

| # | Tính năng | File chính | Status | Ghi chú |
|---|---|---|---|---|
| S1 | Xem cấu hình hiện tại | `views/settings/settings_screen.dart` | ❌ | Đọc từ `systemConfig/general` |
| S2 | Cập nhật % phí nền tảng | `controllers/settings_controller.dart` | ❌ | Validate: 0.0 → 30.0 |
| S3 | Cài đặt số tiền nạp/rút tối thiểu | `controllers/settings_controller.dart` | ❌ | |
| S4 | Bật/tắt chế độ bảo trì | `controllers/settings_controller.dart` | ❌ | UPDATE `maintenanceMode` |

---

## AUTH & SESSION

| # | Tính năng | File chính | Status | Ghi chú |
|---|---|---|---|---|
| A1 | Trang đăng nhập | `views/auth/login_page.dart` | ✅ | Hardcode user/pass tạm |
| A2 | Đăng nhập bằng Firebase Auth | `data/services/auth_service.dart` | ⚠️ | Đang dùng SharedPreferences giả — cần đổi sang Firebase Auth |
| A3 | Kiểm tra role == "admin" sau login | `data/services/auth_service.dart` | ❌ | Sau khi login Firebase, query `users/{uid}.role` để xác nhận |
| A4 | Đăng xuất | `auth_controller.dart` + `side_menu.dart` | ✅ | Dialog xác nhận; clear SharedPreferences; `AuthWrapper` → LoginPage |
| A5 | Auto redirect về login nếu chưa đăng nhập | `main.dart` | ✅ | `AuthWrapper` + `AuthController.checkLogin()` khi khởi động |

---

## FILE/FOLDER CẦN TẠO (dự kiến)
```
lib/
├── views/
│   ├── auth/
│   │   └── login_page.dart          ✅
│   ├── dashboard/
│   │   ├── dashboard_screen.dart    ✅
│   │   ├── main_screen.dart         ✅
│   │   └── components/              ✅
│   ├── users/
│   │   ├── user_list_screen.dart    ❌ (U1-U5)
│   │   ├── user_detail_screen.dart  ❌ (U3)
│   │   ├── employer_list_screen.dart ❌ (U6)
│   │   └── candidate_list_screen.dart ❌ (U7)
│   ├── post/                        ✅ (J1,J3-J6) — dùng thư mục này, không tạo views/jobs/
│   │   ├── job_posts_screen.dart    ✅
│   │   ├── job_detail_screen.dart   ❌ (J2) — tạo trong post/ khi làm
│   │   └── components/              ✅ job_post_table, job_status_chip, job_status_filter_chip
│   ├── disputes/
│   │   ├── dispute_list_screen.dart ❌ (DI1)
│   │   ├── dispute_detail_screen.dart ❌ (DI2-DI4)
│   │   └── dispute_history_screen.dart ❌ (DI5)
│   ├── revenue/
│   │   ├── revenue_screen.dart      ❌ (R1-R2)
│   │   └── transaction_list_screen.dart ❌ (R3-R4)
│   ├── categories/
│   │   ├── category_list_screen.dart ❌ (C1)
│   │   └── category_form_screen.dart ❌ (C2-C3)
│   └── settings/
│       └── settings_screen.dart     ❌ (S1-S4)
├── controllers/
│   ├── auth_controller.dart         ✅ (cần refactor)
│   ├── dashboard_controller.dart    ✅
│   ├── menu_app_controller.dart     ✅ currentPage + navigateTo
│   ├── job_post_controller.dart     ✅ duyệt/từ chối + filter
│   ├── user_management_controller.dart ❌
│   ├── dispute_controller.dart      ❌
│   ├── revenue_controller.dart      ❌
│   ├── category_controller.dart     ❌
│   └── settings_controller.dart     ❌
└── data/
    ├── models/
    │   └── job_post_model.dart      ✅
    └── services/
        ├── auth_service.dart        ✅ (cần refactor sang Firebase Auth)
        ├── job_post_service.dart    ✅ fetch + update status jobPosts
        ├── user_service.dart        ❌
        ├── dispute_service.dart     ❌
        ├── transaction_service.dart ❌
        ├── category_service.dart    ❌
        └── settings_service.dart   ❌
```
