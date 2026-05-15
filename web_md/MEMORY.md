# MEMORY — ViecNow Admin Web Project State

> **AI: Đọc file này + `project_overview.md` trước khi bắt đầu session mới.**
> Sau khi hoàn thành feature, cập nhật section "Completed Features" và "Known Issues".

---

## Thông tin project
- **Package:** `web_viecnow` | **Stack:** Flutter Web · Provider · Firebase Auth · Cloud Firestore · fl_chart · SharedPreferences
- **State management:** Provider (`ChangeNotifier` + `notifyListeners`)
- **Controllers đã đăng ký trong main.dart:** `MenuAppController`, `DashboardController`, `AuthController`
- **Firebase:** Dùng chung với app mobile ViecNow (cùng project Firebase)
- **Entry point layout:** `views/dashboard/main_screen.dart` → `MainScreen`

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
| L1 | MainScreen shell | `views/dashboard/main_screen.dart` | Row: SideMenu + content |
| L2 | SideMenu | `views/dashboard/components/side_menu.dart` | Navigation trái, có DrawerListTile |
| L3 | Header | `views/dashboard/components/header.dart` | Thanh tiêu đề trên cùng |
| L4 | Responsive | `responsive.dart` | Breakpoints: 1100, 650 |
| L5 | Trang đăng nhập | `views/auth/login_page.dart` | Gradient login form |
| D1 | Summary Cards | `views/dashboard/components/summary_cards.dart` | 4 cards: user, job, apply, company |
| D2 | LineChart ứng tuyển theo tuần | `views/dashboard/components/chart_section.dart` | fl_chart LineChart |
| D3 | PieChart trạng thái ứng tuyển | `views/dashboard/components/chart_section.dart` | fl_chart PieChart |
| D4 | DashboardController | `controllers/dashboard_controller.dart` | Fetch Firestore: users, jobs, applications, companies |
| A1 | Login page UI | `views/auth/login_page.dart` | |
| A4 | Logout | `controllers/auth_controller.dart` | Dùng SharedPreferences |

---

## Known Issues ⚠️
| Issue | File | Mức độ | Ghi chú |
|---|---|---|---|
| Auth dùng SharedPreferences hardcode | `data/services/auth_service.dart` | High | Cần đổi sang Firebase Auth + kiểm tra `role == "admin"` |
| SideMenu không navigate thực sự | `views/dashboard/components/side_menu.dart` | High | Các `press: () {}` chưa gọi navigate — cần thêm `currentPage` state vào MenuAppController |
| Không có auto-redirect về Login | `main.dart` | Medium | Chưa check auth state khi khởi động |
| DashboardController query sai collection | `controllers/dashboard_controller.dart` | Medium | Query `jobs` và `companies` nhưng app mobile dùng `jobPosts` và không có `companies` — cần đổi |
| `applications` status values chưa đồng bộ | `controllers/dashboard_controller.dart` | Low | Đang query `"hired"`, `"interviewing"` — app mobile dùng `"accepted"` — cần đồng bộ với `database_schema.md` |

---

## Session Log (cập nhật mỗi lần hoàn thành feature)
| Ngày | Feature hoàn thành | Thay đổi chính |
|---|---|---|
| 2026-05-15 | Setup ban đầu | Tạo project web_viecnow. Có: MainScreen, SideMenu, Header, SummaryCards, ChartSection, DashboardController, AuthController. Stack: Provider + Firebase. |

---

## Ghi chú kiến trúc quan trọng
- **Collection đúng của app mobile:** `jobPosts` (không phải `jobs`), `users` (không có `companies`)
- **Role admin:** Lưu trong `users/{uid}.role == "admin"`
- **Auth flow đúng:** Firebase Auth → query `users/{uid}` → kiểm tra `role == "admin"` → cho vào dashboard
- **Pagination:** Mọi query danh sách phải có `.limit(20)` + cursor-based pagination
