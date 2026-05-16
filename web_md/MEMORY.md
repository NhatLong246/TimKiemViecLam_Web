# MEMORY — ViecNow Admin Web Project State

> **AI: Đọc file này + `project_overview.md` trước khi bắt đầu session mới.**
> Sau khi hoàn thành feature, cập nhật section "Completed Features" và "Known Issues".

---

## Thông tin project
- **Package:** `web_viecnow` | **Stack:** Flutter Web · Provider · Firebase Auth · Cloud Firestore · fl_chart · SharedPreferences
- **State management:** Provider (`ChangeNotifier` + `notifyListeners`)
- **Controllers đã đăng ký trong main.dart:** `AuthController`, `MenuAppController`, `DashboardController`, `JobPostController`
- **Firebase:** Dùng chung với app mobile ViecNow (cùng project Firebase)
- **Entry point:** `main.dart` → `AuthWrapper` → `MainScreen` (nếu đã login) hoặc `LoginPage`

---

## Packages hiện tại (pubspec.yaml)
| Package | Version | Mục đích |
|---|---|---|
| `flutter` | sdk | Framework |
| `cupertino_icons` | ^1.0.8 | Icons |
| `shared_preferences` | ^2.5.5 | Lưu trạng thái login (tạm) |
| `provider` | ^6.1.5+1 | State management |
| `firebase_core` | ^4.9.0 | Firebase init |
| `fl_chart` | ^1.2.0 | Biểu đồ |
| `cloud_firestore` | ^6.4.1 | Database |

---

## Completed Features ✅
| Feature ID | Feature | File chính | Ghi chú |
|---|---|---|---|
| L1 | MainScreen shell | `views/dashboard/main_screen.dart` | Row: SideMenu + content; switch theo `currentPage` |
| L2 | SideMenu + navigation | `views/dashboard/components/side_menu.dart` | Dashboard + Tin tuyển dụng; highlight mục active |
| L7 | Navigation state | `controllers/menu_app_controller.dart` | `pageDashboard`, `pageJobs`, `navigateTo()` |
| L3 | Header | `views/dashboard/components/header.dart` | Thanh tiêu đề trên cùng |
| L4 | Responsive | `responsive.dart` | Breakpoints: 1100, 650 |
| L5 | Trang đăng nhập | `views/auth/login_page.dart` | Gradient login form |
| D1 | Summary Cards | `views/dashboard/components/summary_cards.dart` | 4 cards: user, job, apply, company |
| D2 | LineChart ứng tuyển theo tuần | `views/dashboard/components/chart_section.dart` | fl_chart LineChart |
| D3 | PieChart trạng thái ứng tuyển | `views/dashboard/components/chart_section.dart` | fl_chart PieChart |
| D4 | DashboardController | `controllers/dashboard_controller.dart` | Fetch Firestore (cần sửa collection — xem Known Issues) |
| A1 | Login page UI | `views/auth/login_page.dart` | |
| A4 | Đăng xuất + xác nhận | `side_menu.dart` + `auth_controller.dart` | Dialog Huỷ/Có → `AuthWrapper` về LoginPage |
| J5 | Danh sách tin + lọc status | `views/post/job_posts_screen.dart` | Chip lọc, search, bảng DataTable |
| J3 | Duyệt tin | `job_post_controller.dart` + `job_post_service.dart` | `status → "approved"`, dialog xác nhận |
| J4 | Từ chối tin | (cùng controller/service) | `status → "rejected"` + `rejectionReason` tùy chọn |
| J6 | Tìm kiếm tin | `job_posts_screen.dart` | Theo tiêu đề, danh mục, địa điểm, employerId |

---

## Known Issues ⚠️
| Issue | File | Mức độ | Ghi chú |
|---|---|---|---|
| Auth dùng SharedPreferences hardcode | `data/services/auth_service.dart` | High | Cần Firebase Auth + `users/{uid}.role == "admin"` |
| SideMenu: các mục chưa có trang | `side_menu.dart` | Medium | Chỉ `dashboard` và `jobs` hoạt động; users/employers/CV/categories/settings còn `press: () {}` |
| DashboardController query sai collection | `dashboard_controller.dart` | Medium | Đang query `jobs`, `companies` — mobile dùng `jobPosts`, không có `companies` |
| `applications` status chưa đồng bộ | `dashboard_controller.dart` | Low | Mobile dùng `"accepted"` thay vì `"hired"` / `"interviewing"` |
| Chưa có chi tiết tin (J2) | — | Low | Bảng chỉ list; chưa màn `job_detail` |
| Chưa phân trang jobPosts | `job_post_service.dart` | Low | Chỉ `.limit(20)`; chưa cursor pagination |
| Admin đóng tin (J7) | — | Low | Chưa có `status → "closed"` |

---

## Session Log (cập nhật mỗi lần hoàn thành feature)
| Ngày | Feature hoàn thành | Thay đổi chính |
|---|---|---|
| 2026-05-15 | Setup ban đầu | MainScreen, SideMenu, Header, SummaryCards, ChartSection, DashboardController, AuthController. Provider + Firebase. |
| 2026-05-16 | Auth logout | Dialog xác nhận đăng xuất trong `side_menu.dart`. |
| 2026-05-16 | Tin tuyển dụng | `views/post/`, `JobPostModel`, `JobPostService`, `JobPostController`. Navigation `MenuAppController`. Duyệt/từ chối pending & draft. |

---

## Ghi chú kiến trúc quan trọng

### Cấu trúc thư mục thực tế (ưu tiên khi code tiếp)
```
lib/
├── data/
│   ├── models/
│   │   └── job_post_model.dart      ← Model đồng bộ app mobile
│   └── services/
│       ├── auth_service.dart
│       └── job_post_service.dart    ← collection jobPosts
├── controllers/
│   ├── auth_controller.dart
│   ├── menu_app_controller.dart     ← currentPage: dashboard | jobs
│   ├── dashboard_controller.dart
│   └── job_post_controller.dart
└── views/
    ├── auth/login_page.dart
    ├── dashboard/                   ← Shell + dashboard
    └── post/                        ← Tin tuyển dụng (KHÔNG dùng views/jobs/)
        ├── job_posts_screen.dart
        └── components/
            ├── job_post_table.dart
            ├── job_status_chip.dart
            └── job_status_filter_chip.dart
```

> **Lưu ý:** `feature_map.md` còn ghi `views/jobs/` — đó là kế hoạch cũ. Code hiện tại dùng **`views/post/`**.

### Firebase
- **Collection job:** `jobPosts` (không phải `jobs`)
- **Không có** collection `companies`
- **Document ID:** thường trùng `jobId`; service fallback `doc.id` nếu thiếu field `jobId`

### `jobPosts.status` (mobile + web)
| Giá trị | Nhãn UI | Admin thao tác |
|---|---|---|
| `draft` | Nháp | Có nút Duyệt / Từ chối |
| `pending` | Chờ duyệt | Có nút Duyệt / Từ chối |
| `approved` | Đã duyệt | Chỉ xem |
| `active` | Đang tuyển | Chỉ xem |
| `closed` | Đã đóng | Chỉ xem |
| `rejected` | Từ chối | Chỉ xem |

### Navigation (state-based)
```dart
// MenuAppController
MenuAppController.pageDashboard  // 'dashboard' → DashboardScreen
MenuAppController.pageJobs       // 'jobs'       → JobPostsScreen

// MainScreen._buildContent() switch theo currentPage
// SideMenu: context.watch + navigateTo(); đóng drawer trên mobile
```

### UI patterns đã áp dụng
- **Filter trạng thái:** dùng `JobStatusFilterChip` (nền trắng / chọn xanh) — **không** dùng `FilterChip` mặc định (bị theme `canvasColor` tối → chữ không đọc được).
- **Hành động admin:** dialog xác nhận trước khi duyệt; dialog + `TextField` lý do khi từ chối; SnackBar xanh/cam/đỏ.
- **Bảng danh sách:** pattern `DataTable` trong card trắng — xem `frontend_ui_rules.md` §8.

### Thêm trang SideMenu mới (checklist)
1. Thêm hằng `pageXxx` trong `MenuAppController`
2. Case trong `MainScreen._buildContent()`
3. `DrawerListTile` + `navigate(pageXxx)` + `isActive`
4. Tạo `views/<module>/` + Controller + Service
5. Đăng ký Provider trong `main.dart`
6. Cập nhật `feature_map.md` + file MEMORY này

### Role admin
- Lưu trong `users/{uid}.role == "admin"`
- **Auth flow mục tiêu:** Firebase Auth → query `users/{uid}` → chỉ admin vào dashboard

### Pagination
- Mọi query danh sách: `.limit(20)` + cursor (chưa làm cho jobPosts)
