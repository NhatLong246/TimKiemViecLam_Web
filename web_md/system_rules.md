# SYSTEM RULES & AI BEHAVIOR — ViecNow Admin Web

---

## 0. GIAO THỨC TỰ ĐỘNG — Áp dụng cho MỌI yêu cầu (không cần nhắc lại)

> AI phải tự xác định loại task và đọc đúng file MD tương ứng **trước khi làm bất cứ điều gì**.
> **QUAN TRỌNG:** Web admin và app mobile dùng chung Firebase. Mọi thao tác Firestore phải tham chiếu `web_md/database_schema.md`.

### Bảng tự động chọn file cần đọc theo loại task

| Loại task | Files bắt buộc đọc (theo thứ tự) |
|---|---|
| Bắt đầu session / không rõ context | `MEMORY.md` → `project_overview.md` |
| Tạo màn hình / widget mới | `MEMORY.md` → `project_overview.md` → `feature_map.md` → `frontend_ui_rules.md` |
| Tạo / sửa Controller | `MEMORY.md` → `frontend_ui_rules.md` → file controller liên quan |
| Tạo / sửa Service (Firebase) | `database_schema.md` → file service liên quan |
| Sửa navigation / SideMenu | `project_overview.md` → `frontend_ui_rules.md` → `menu_app_controller.dart` |
| Sửa bug | `MEMORY.md` (xem Known Issues) → file bị lỗi |
| Thêm tính năng mới | `MEMORY.md` → `feature_map.md` → `frontend_ui_rules.md` → `database_schema.md` |
| Hoàn thành 1 feature | Cập nhật `feature_map.md` (đổi ❌ → ✅) + ghi vào `MEMORY.md` Session Log |
| Hỏi kế hoạch / thiết kế | `project_overview.md` → `feature_map.md` |

### Quy tắc tự phân loại task
- Có từ "màn hình", "screen", "UI", "giao diện", "widget", "bảng", "table" → loại **UI**
- Có từ "controller", "service", "firebase", "firestore", "data", "fetch" → loại **Data/Logic**
- Có từ "navigation", "sidebar", "menu", "chuyển trang", "route" → loại **Navigation**
- Có từ "lỗi", "bug", "fix", "sửa", "không chạy", "lỗi build" → loại **Bug**
- Có từ "làm", "tạo", "thêm tính năng" + tên feature → loại **UI + Data** (đọc cả hai)
- Không rõ loại → đọc `MEMORY.md` + `project_overview.md`, rồi hỏi nếu cần

---

## 1. Quy trình làm việc bắt buộc

### Trước khi code
1. **Đọc đúng file MD** theo bảng trên — không đoán mò.
2. **Kiểm tra feature_map.md** xem tính năng đã có chưa (tránh làm trùng).
3. **Trình bày ngắn gọn plan:** "Tôi sẽ tạo/sửa file X để làm Y."

### Khi viết code
- Chỉ output phần code thay đổi. Dùng `// ... existing code ...` cho phần giữ nguyên.
- **TUYỆT ĐỐI KHÔNG** in lại toàn bộ file nếu chỉ sửa vài dòng.
- State management: **Provider + ChangeNotifier** — không dùng GetX, Riverpod, Bloc.
- Luôn dùng `Consumer<T>` hoặc `context.watch<T>()` để lắng nghe state.

### Sau khi hoàn thành
- Cập nhật `feature_map.md`: đổi `❌` → `✅` cho feature vừa làm.
- Ghi vào `MEMORY.md` Session Log: ngày, feature, file đã tạo/sửa.

---

## 2. Giới hạn quyền hạn (Guardrails)

- **KHÔNG tự ý thêm package** vào `pubspec.yaml` nếu chưa hỏi.
- **KHÔNG tự ý xóa code cũ** nếu chưa phân tích và được đồng ý.
- **KHÔNG sửa schema Firestore** (tên collection, field) mà không cập nhật `database_schema.md` trước.
- **KHÔNG dùng GetX** — project web dùng Provider. Nếu nhìn thấy `Get.` trong code, đó là code từ app mobile bị nhầm.
- Chỉ tập trung task hiện tại — không tự ý refactor sang tính năng khác.

---

## 3. Checklist trước khi output code

- [ ] Đã đọc đúng file MD theo bảng phân loại ở Mục 0?
- [ ] Tên field/collection có khớp với `web_md/database_schema.md`?
- [ ] State management dùng Provider (`ChangeNotifier`, `notifyListeners`) chưa?
- [ ] Widget tái sử dụng trong `frontend_ui_rules.md` đã được tận dụng chưa?
- [ ] Màu sắc lấy từ `constants.dart` chưa (không hardcode hex)?
- [ ] Responsive có xử lý 3 breakpoint không?
- [ ] Loading state và error state đã xử lý chưa?
- [ ] Confirmation dialog cho các thao tác quan trọng chưa?

---

## 4. Quy tắc Firebase trên Web Admin

### Chỉ được làm với data (không phá dữ liệu app mobile):
| Hành động | Được phép | Ghi chú |
|---|---|---|
| `GET` đọc collection | ✅ | Luôn dùng `.limit()` cho danh sách |
| `UPDATE` 1 số field cụ thể | ✅ | Chỉ field được liệt kê trong `database_schema.md` |
| `ADD` vào `jobCategories` | ✅ | Check duplicate `key` trước |
| `ADD` vào `systemConfig` | ✅ | Single document `general` |
| `DELETE` document | ❌ | KHÔNG XÓA — chỉ đổi `isActive = false` |
| `OVERWRITE` toàn bộ document | ❌ | Chỉ dùng `update()` có chọn lọc |
| Sửa `salary`, `slots`, `totalBudget` của job | ❌ | Chỉ Employer mới được sửa |

### Query an toàn:
```dart
// Luôn có .limit() khi lấy danh sách
await _db.collection('users').limit(20).get();

// Pagination đúng cách
await _db.collection('users')
    .orderBy('createdAt', descending: true)
    .startAfterDocument(lastDoc)
    .limit(20)
    .get();

// Không lấy toàn bộ collection không giới hạn
// ❌ await _db.collection('users').get();
```

---

## 5. Xử lý lỗi chuẩn trong Service

```dart
// Pattern chuẩn cho mọi Firebase service method
Future<void> doSomething() async {
  try {
    await _db.collection('...').doc('...').update({...});
  } on FirebaseException catch (e) {
    throw Exception('Firebase error: ${e.message}');
  } catch (e) {
    throw Exception('Unexpected error: $e');
  }
}
```

Controller sẽ catch và set `errorMessage`:
```dart
Future<void> loadData() async {
  isLoading = true;
  errorMessage = null;
  notifyListeners();
  try {
    // gọi service
  } catch (e) {
    errorMessage = e.toString();
  } finally {
    isLoading = false;
    notifyListeners();
  }
}
```

---

## 6. Chống "Quên" Code
- Sau mỗi feature hoàn thành: cập nhật `feature_map.md` + ghi vào `MEMORY.md` Session Log.
- Nếu phát hiện bug mới trong quá trình làm: ghi vào `MEMORY.md` phần Known Issues ngay lập tức.
- Nếu thêm package mới vào `pubspec.yaml`: ghi lại vào `MEMORY.md` phần Packages.
