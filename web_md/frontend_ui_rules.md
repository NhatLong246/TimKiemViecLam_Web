# FRONTEND & UI ARCHITECTURE — ViecNow Admin Web

> **AI: Đọc file này trước khi tạo bất kỳ màn hình, widget, hay thay đổi giao diện nào.**

---

## 1. Bố cục tổng thể — Desktop-first Layout
Web admin sử dụng layout 2 cột: SideMenu cố định bên trái, content area cuộn bên phải.

```dart
// main_screen.dart — cấu trúc chuẩn
Scaffold(
  key: menuController.scaffoldKey,
  drawer: SideMenu(),            // Drawer cho mobile/tablet
  body: SafeArea(
    child: Row(
      children: [
        if (Responsive.isDesktop(context))
          Expanded(flex: 1, child: SideMenu()),   // Hiển thị cố định trên desktop
        Expanded(flex: 5, child: <CurrentPage>()),  // Content thay đổi theo navigation
      ],
    ),
  ),
)
```

---

## 2. Responsive — 3 Breakpoints

| Class | File | Điều kiện |
|---|---|---|
| `Responsive.isDesktop(context)` | `responsive.dart` | `width >= 1100` |
| `Responsive.isTablet(context)` | `responsive.dart` | `width >= 650` |
| `Responsive.isMobile(context)` | `responsive.dart` | `width < 650` |

**Quy tắc responsive:**
- Luôn dùng `Responsive.isDesktop/isTablet/isMobile` thay vì hardcode pixel
- Trên Mobile/Tablet: SideMenu ẩn → mở bằng hamburger (Drawer)
- Trên Desktop: SideMenu luôn hiển thị cố định
- Grid cross-axis: Desktop = 4 cột, Tablet = 2-4 cột, Mobile = 2 cột

---

## 3. State Management — Provider Pattern

```dart
// Đọc state (không rebuild)
context.read<MenuAppController>().scaffoldKey

// Đọc state + rebuild khi thay đổi
context.watch<DashboardController>().totalUsers

// Consumer widget (preferred cho màn hình lớn)
Consumer<DashboardController>(
  builder: (context, controller, child) {
    if (controller.isLoading) return CircularProgressIndicator();
    return YourWidget(data: controller.data);
  },
)
```

**Controllers hiện có:**
| Controller | Extends | Đăng ký tại | Dùng cho |
|---|---|---|---|
| `MenuAppController` | `ChangeNotifier` | `main.dart` MultiProvider | ScaffoldKey, current page |
| `DashboardController` | `ChangeNotifier` | `main.dart` MultiProvider | Dashboard data |
| `AuthController` | `ChangeNotifier` | `main.dart` MultiProvider | Login state |

**Pattern khi thêm Controller mới:**
1. Tạo `lib/controllers/xxx_controller.dart` extends `ChangeNotifier`
2. Đăng ký trong `main.dart` → `MultiProvider.providers` list
3. `notifyListeners()` sau khi thay đổi state — KHÔNG dùng `setState`

---

## 4. Cấu trúc màn hình chuẩn

```dart
// views/xxx/xxx_screen.dart — chỉ chứa UI
class XxxScreen extends StatelessWidget {
  const XxxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<XxxController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content...
            ],
          ),
        );
      },
    );
  }
}
```

---

## 5. Navigation — State-based (SideMenu switching)

Hiện tại: Mỗi mục SideMenu gọi callback để cập nhật `currentPage` trong `MenuAppController`.
`MainScreen` sẽ render widget tương ứng với `currentPage`.

```dart
// menu_app_controller.dart (cần thêm)
class MenuAppController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentPage = 'dashboard';
  String get currentPage => _currentPage;

  void navigateTo(String page) {
    _currentPage = page;
    notifyListeners();
  }
}

// main_screen.dart — switch theo currentPage
Widget _buildContent(String page) {
  switch (page) {
    case 'dashboard': return DashboardScreen();
    case 'users': return UserListScreen();
    case 'jobs': return JobApprovalScreen();
    // ...
    default: return DashboardScreen();
  }
}
```

**Hằng số tên trang (dùng nhất quán):**
| Hằng số | Trang |
|---|---|
| `'dashboard'` | Dashboard tổng quan |
| `'users'` | Quản lý người dùng |
| `'employers'` | Nhà tuyển dụng |
| `'candidates'` | Ứng viên |
| `'jobs'` | Tin tuyển dụng |
| `'disputes'` | Tranh chấp |
| `'revenue'` | Báo cáo doanh thu |
| `'categories'` | Danh mục nghề nghiệp |
| `'settings'` | Cài đặt hệ thống |

---

## 6. Màu sắc & Typography

### Màu sắc (chỉ dùng từ `lib/constants.dart`)
| Constant | Hex | Dùng cho |
|---|---|---|
| `primaryColor` | `#2697FF` | Button chính, icon active, highlight |
| `secondaryColor` | `#2A2D3E` | Nền card dark, canvas |
| `bgColor` | `#F4F7FC` | Nền tổng thể |
| `sidebarColor` | `#1E1E2D` | Nền sidebar |
| `defaultPadding` | `16.0` | Padding/spacing chuẩn |

> **KHÔNG hardcode màu hex trực tiếp** trong widget. Luôn dùng constant.

### Typography
- Font chính: `Inter` (đã khai báo trong `ThemeData`)
- Dùng `Theme.of(context).textTheme.titleLarge`, `.bodyMedium`, v.v.
- Không hardcode `fontSize` — nếu cần size custom, xem xét thêm vào constants.

---

## 7. Widgets tái sử dụng hiện có

| Widget | File | Mô tả |
|---|---|---|
| `SideMenu` | `views/dashboard/components/side_menu.dart` | Navigation trái, có `DrawerListTile` |
| `Header` | `views/dashboard/components/header.dart` | Thanh trên cùng của content |
| `SummaryCards` | `views/dashboard/components/summary_cards.dart` | Grid 4 card chỉ số |
| `ChartSection` | `views/dashboard/components/chart_section.dart` | LineChart + PieChart |
| `InfoCardGridView` | trong `summary_cards.dart` | Grid layout cho cards |
| `SummaryInfo` | trong `summary_cards.dart` | Data model cho card |
| `DrawerListTile` | trong `side_menu.dart` | Mục trong SideMenu |

> **Trước khi tạo widget mới**, kiểm tra danh sách trên xem có widget nào tái sử dụng được không.

---

## 8. Table/List pattern cho màn hình quản lý

```dart
// Pattern chuẩn cho màn hình danh sách dữ liệu
Container(
  padding: EdgeInsets.all(defaultPadding),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Header + Search row
      Row(
        children: [
          Text("Tiêu đề", style: Theme.of(context).textTheme.titleMedium),
          Spacer(),
          SizedBox(width: 200, child: TextField(...)),  // Search
        ],
      ),
      SizedBox(height: defaultPadding),
      // DataTable
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [...],
          rows: [...],
        ),
      ),
      // Pagination
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(onPressed: previousPage, child: Text("Trước")),
          Text("Trang $currentPage / $totalPages"),
          TextButton(onPressed: nextPage, child: Text("Sau")),
        ],
      ),
    ],
  ),
)
```

---

## 9. Confirmation Dialog pattern

Khi thực hiện hành động quan trọng (duyệt, từ chối, khoá user), luôn show dialog xác nhận:

```dart
Future<bool?> showConfirmDialog(BuildContext context, {
  required String title,
  required String content,
  String confirmText = "Xác nhận",
  Color confirmColor = primaryColor,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Huỷ")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}
```

---

## 10. Loading & Error states

```dart
// Loading
if (controller.isLoading)
  return const Center(child: CircularProgressIndicator());

// Error
if (controller.errorMessage != null)
  return Center(child: Text("Lỗi: ${controller.errorMessage}"));

// Empty
if (controller.items.isEmpty)
  return Center(child: Text("Không có dữ liệu"));
```

> Mọi Controller phải có `bool isLoading` và `String? errorMessage` fields.

---

## 11. SnackBar notification pattern

```dart
// Thành công
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Thao tác thành công!"), backgroundColor: Colors.green),
);

// Thất bại
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Lỗi: $message"), backgroundColor: Colors.red),
);
```
