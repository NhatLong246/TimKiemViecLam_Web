# Ke hoach trien khai luong khieu nai giai ngan

## Muc tieu

Dong bo trang web Admin voi luong giai ngan dang co tren app mobile:

1. NTD bam giai ngan va chon co/khong khieu nai.
2. Neu co khieu nai, app luu danh sach ung vien bi khieu nai trong
   `disbursementNotices/{noticeId}`.
3. Admin xem, duyet hoac tu choi tung khieu nai.
4. Khi tat ca khieu nai cua mot yeu cau da duoc xu ly, document chuyen sang
   `complaints_reviewed`.
5. App NTD hien nut giai ngan sau khieu nai va thuc hien buoc giai ngan.

## Hien trang va van de

- App mobile da luu khieu nai giai ngan trong `disbursementNotices` qua cac field:
  `complainedCandidates`, `complaintReasons`, `complaintEvidence`,
  `complaintResults`, `deductions`, `adminFinalDeductions`, `adminNote`.
- Web Admin hien tai chi doc `jobComplaints`, vi vay khong thay cac khieu nai
  phat sinh tu man hinh giai ngan cua NTD.
- Web Admin hien tai co thao tac phat/boi thuong truc tiep vao vi. Cach nay
  khong phu hop voi luong moi va co nguy co sua so du sai.

## Kien truc chon

### Nguon du lieu

- Khieu nai trong luong giai ngan: `disbursementNotices`.
- `jobComplaints` tiep tuc danh cho khieu nai doc lap/sau giai tan nhom, khong
  dung de duyet khieu nai giai ngan.

### Anh xa danh sach Admin

Moi candidate trong `complainedCandidates` duoc hien thanh mot dong:

- Khoa dong: `noticeId + candidateId`.
- Noi dung: cong viec, NTD, ung vien, ly do, bang chung, muc boi thuong NTD de
  xuat, ket qua Admin, muc boi thuong Admin chot.
- Trang thai dong:
  - `pending`: chua co trong `complaintResults`.
  - `approved`: Admin chap nhan.
  - `rejected`: Admin tu choi.

### Xu ly quyet dinh Admin

Admin cap nhat bang Firestore transaction:

- Duyet:
  - `complaintResults.{candidateId} = approved`
  - `adminFinalDeductions.{candidateId} = finalCompensation`
  - `adminNotes.{candidateId} = note`
- Tu choi:
  - `complaintResults.{candidateId} = rejected`
  - `adminFinalDeductions.{candidateId} = 0`
  - `adminNotes.{candidateId} = note`
- Neu tat ca `complainedCandidates` da co ket qua:
  - `status = complaints_reviewed`
  - `complaintsReviewedAt = serverTimestamp`

Sau transaction, Admin tao notification cho NTD. Viec thong bao khong duoc lam
hong quyet dinh da luu neu notification gap loi.

## Pham vi code Admin

### Tao moi

- `lib/data/models/disbursement_complaint_model.dart`
  - Anh xa mot candidate complaint tu mot `disbursementNotices`.
- `lib/data/services/disbursement_complaint_service.dart`
  - Doc notice, lay ten user, duyet/tu choi bang transaction, gui notification.
- `test/data/models/disbursement_complaint_model_test.dart`
  - Kiem thu anh xa, trang thai va tinh tien hien thi.

### Sua

- `lib/controllers/complaint_controller.dart`
  - Quan ly danh sach khieu nai giai ngan, loc, tim kiem, duyet/tu choi.
- `lib/views/complaints/complaint_screen.dart`
  - Hien thi danh sach khieu nai giai ngan.
- `lib/views/complaints/components/complaint_detail_dialog.dart`
  - Hien thi bang chung, muc de xuat; form duyet/tu choi va muc boi thuong chot.
- `web_md/database_schema.md`
  - Bo sung schema luong khieu nai trong `disbursementNotices`.
- `web_md/feature_map.md`, `web_md/MEMORY.md`
  - Ghi nhan tinh nang da dong bo.

## Quy tac nghiep vu Admin

- Chi cho xu ly dong dang `pending`.
- Duyet bat buoc so tien boi thuong cuoi cung lon hon hoac bang 0.
- Tu choi bat buoc ghi ly do.
- Khong sua vi, khong giai ngan va khong xoa nhom tu web Admin.
- Khong cho phep quyet dinh lan hai ghi de quyet dinh da co.

## Phan backend/mobile can lam tiep

Luong tru tien, hoan tien, ghi no va khoa tai khoan 48 gio hien dang nam trong
client mobile. De an toan tai chinh, can chuyen sang Cloud Functions transaction
co idempotency key theo `noticeId`.

Cloud Function dinh ky can:

- Kiem tra `userDebts.deadline` sau 48 gio.
- Khoa tai khoan khi no chua thanh toan.
- Thu so du hien co, ghi transaction ledger.
- Ghi nhan phan nen tang bu vao neu user khong du tien.

Phan nay khong nam trong lan code Admin nay vi project mobile/functions nam ngoai
workspace duoc phep ghi.

## Kiem thu va xac minh

1. Chay test model, xac nhan test that bai truoc khi tao model.
2. Chay `flutter test`.
3. Chay `flutter analyze`.
4. Chay `flutter build web`.

## Ket qua trien khai Admin

- Da tao model anh xa tung ung vien bi khieu nai tu `disbursementNotices`.
- Da tao service doc danh sach, duyet/tu choi bang Firestore transaction.
- Da tu dong chuyen notice sang `complaints_reviewed` khi tat ca khieu nai da co
  ket qua.
- Da gui notification cho NTD sau quyet dinh.
- Da thay giao dien khieu nai Admin bang danh sach va dialog xu ly luong moi.
- Da loai bo thao tac sua vi/phat tien truc tiep khoi man khieu nai Admin.
