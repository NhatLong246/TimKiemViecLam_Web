# PROJECT OVERVIEW — ViecNow Admin Web

> **AI: ĐỌC FILE NÀY ĐẦU TIÊN trước khi bắt đầu bất kỳ task nào trong project web.**
> Project web và project mobile dùng chung Firebase — tuyệt đối không thay đổi cấu trúc Firestore nếu không tham chiếu `database_schema.md`.

---

## 1. Thông tin cơ bản
- **Tên project:** ViecNow Admin
- **Package name:** `web_viecnow`
- **Mô tả:** Trang web quản trị (Admin Dashboard) cho nền tảng ViecNow. Đây là giao diện dành riêng cho vai trò `"admin"` — cho phép quản lý toàn bộ người dùng, tin tuyển dụng, tranh chấp, doanh thu và các cấu hình hệ thống.
- **Stack:** Flutter Web · Provider (state management) · Firebase Auth · Cloud Firestore · SharedPreferences · fl_chart
- **Platform target:** Web only (chạy trên trình duyệt desktop)
- **Firebase project:** Dùng chung với app mobile ViecNow (cùng Firestore, cùng Auth, cùng Storage)

---

## 2. Kiến trúc tổng thể

```
Web Browser
    └── Flutter Web App (web_viecnow)
            ├── Tầng UI (views/)         → Hiển thị giao diện
            ├── Tầng Controller (controllers/)  → Xử lý state & logic
            └── Tầng Service (data/services/)   → Giao tiếp Firebase/API
                        ↓
                Firebase (Firestore + Auth + Storage)
                        ↓
                App Mobile (ViecNow) — dùng chung data
```

---

## 3. Phân quyền Admin Web
Chỉ user có `role == "admin"` trong Firestore mới được phép đăng nhập và sử dụng web admin.

| Quyền | Mô tả |
|---|---|
| Xem tổng quan hệ thống | Dashboard: tổng user, tổng job, tổng ứng tuyển, doanh thu |
| Quản lý người dùng | Xem, tìm kiếm, khoá/mở khoá tài khoản candidate & employer |
| Duyệt tin tuyển dụng | Duyệt / từ chối các `jobPosts` có `status: "pending"` |
| Xử lý tranh chấp | Xem và phân xử các `disputes` từ app mobile |
| Báo cáo doanh thu | Xem thống kê giao dịch, doanh thu nền tảng |
| Quản lý danh mục | Thêm/sửa/xóa danh mục nghề nghiệp (`jobCategories`) |
| Cài đặt hệ thống | Cấu hình phí nền tảng, chính sách thanh toán |

---

## 4. Layout tổng thể (Web Dashboard Pattern)

```
┌─────────────────────────────────────────────────────────┐
│  SideMenu (trái, fixed)  │  Content Area (phải, scroll) │
│  - Logo VIECNOW ADMIN    │  ┌─────────────────────────┐ │
│  - Dashboard             │  │  Header (tên trang +    │ │
│  - Quản lý người dùng    │  │  search + profile)      │ │
│  - Nhà tuyển dụng        │  ├─────────────────────────┤ │
│  - Tin tuyển dụng        │  │                         │ │
│  - Ứng viên / CV         │  │  Page Content           │ │
│  - Danh mục ngành nghề   │  │  (SummaryCards,         │ │
│  - Tranh chấp            │  │   Charts, Tables...)    │ │
│  - Báo cáo doanh thu     │  │                         │ │
│  - Cài đặt               │  └─────────────────────────┘ │
│  - Đăng xuất             │                               │
└─────────────────────────────────────────────────────────┘
```

### Responsive breakpoints
| Loại màn hình | Điều kiện | Hành vi SideMenu |
|---|---|---|
| Desktop | `width >= 1100` | SideMenu hiển thị cố định bên trái (expanded) |
| Tablet | `width >= 650` | SideMenu ẩn, mở bằng Drawer |
| Mobile | `width < 650` | SideMenu ẩn, mở bằng Drawer |

---

## 5. State Management — Provider pattern

| Controller | Nhiệm vụ | File |
|---|---|---|
| `MenuAppController` | Scaffold drawer + `currentPage` (`dashboard` \| `jobs`) | `controllers/menu_app_controller.dart` |
| `DashboardController` | Fetch và giữ data cho dashboard tổng quan | `controllers/dashboard_controller.dart` |
| `AuthController` | Trạng thái đăng nhập (`AuthWrapper`); SharedPreferences tạm | `controllers/auth_controller.dart` |
| `JobPostController` | Danh sách `jobPosts`, lọc, duyệt/từ chối | `controllers/job_post_controller.dart` |

> **Pattern chuẩn:** Dùng `ChangeNotifier` + `Consumer<T>` hoặc `context.watch<T>()`.
> Không dùng `setState` trong các controller. Chỉ `notifyListeners()`.

---

## 6. Navigation — State-based (MaterialApp)
- `main.dart`: `AuthWrapper` → `LoginPage` hoặc `MainScreen` theo `AuthController.isLoggedIn`.
- `MainScreen`: switch content theo `MenuAppController.currentPage` (không dùng named routes).
- **Đã có:** `dashboard` → `DashboardScreen`, `jobs` → `JobPostsScreen` (`views/post/`).
- **Kế hoạch:** Thêm `pageUsers`, `pageSettings`, … khi có màn; cân nhắc `go_router` khi > 5 trang.

---

## 7. Color Scheme & Branding
| Constant | Giá trị hex | Dùng cho |
|---|---|---|
| `primaryColor` | `#2697FF` | Màu chính, button, icon active |
| `secondaryColor` | `#2A2D3E` | Canvas, nền card dark |
| `bgColor` | `#F4F7FC` | Nền tổng thể (light) |
| `sidebarColor` | `#1E1E2D` | Nền sidebar |

> Định nghĩa tại `lib/constants.dart`. **Không hardcode màu hex trực tiếp trong widget.**

---

## 8. Phân biệt với App Mobile
| Điểm khác biệt | App Mobile (viecnow) | Web Admin (web_viecnow) |
|---|---|---|
| State management | GetX | Provider |
| Navigation | GetX named routes | MaterialApp router / state-based |
| Target platform | Android/iOS | Web (Chrome, trình duyệt) |
| Người dùng | Candidate, Employer | Admin only |
| Firebase Auth | Firebase Auth (email) | Firebase Auth (email, chỉ admin) |
| Layout | Mobile-first | Desktop-first, responsive |
