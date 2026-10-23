# 🚀 Windows 11 Custom & Debloat NTLite Preset

[![Windows](https://img.shields.io/badge/Windows-11%20Pro%20(24H2%2F25H2)-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/software-download/windows11)
[![NTLite](https://img.shields.io/badge/Tool-NTLite-green?style=for-the-badge)](https://www.ntlite.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

Preset tinh chỉnh cấu hình **NTLite (.xml)** dành cho **Windows 11 (24H2 / 25H2)** giúp bạn tự động loại bỏ ứng dụng rác (bloatware), tắt thu thập dữ liệu (telemetry), tối ưu RAM / CPU và xuất file ISO cài đặt Windows siêu nhẹ, mượt mà và ổn định.

---

## 🌟 Điểm nổi bật của Preset

- 🧹 **Gỡ sạch Bloatware & App rác:** Loại bỏ các ứng dụng mặc định không cần thiết (Clipchamp, Bing Search, Copilot/AI bloatware, quảng cáo gợi ý).
- 🔒 **Tắt theo dõi & Telemetry:** Vô hiệu hóa tính năng gửi dữ liệu chẩn đoán về Microsoft, tăng cường bảo mật riêng tư.
- ⚡ **Tối ưu hiệu năng:** Tắt các dịch vụ chạy ngầm không cần thiết, giúp hệ thống mượt mà hơn khi chơi game và làm việc.
- 🎨 **Giao diện hiện đại:** Kích hoạt sẵn Dark Mode mặc định.
- 📦 **Nén ESD & Tự động tạo ISO:** Tối ưu dung lượng file cài đặt nhỏ gọn nhất có thể.

---

## 📋 Chuẩn bị trước khi làm

1. **Phần mềm NTLite:** Tải phiên bản mới nhất từ trang chủ [NTLite Download](https://www.ntlite.com/download/).
2. **File ISO Windows 11 gốc:** Tải trực tiếp từ Microsoft (khuyến nghị [Media Creation Tool](https://www.microsoft.com/software-download/windows11) hoặc [UUP dump](https://uupdump.net/)).
3. **File Preset XML:** Tải file `.xml` trong repository này về máy tính.
4. **Ổ cứng còn trống:** Tối thiểu 20GB - 30GB dung lượng trống để giải nén và đóng gói ISO.

---

## 🛠️ Hướng dẫn từng bước nạp Preset và tạo ISO bằng NTLite

### Bước 1: Cài đặt NTLite
- Tải bộ cài NTLite và cài đặt bình thường vào máy.
- Mở NTLite (có thể chọn chế độ **Free** nếu dùng bản miễn phí).

### Bước 2: Nạp file ISO gốc vào NTLite
1. Trên thanh công cụ NTLite, bấm vào nút **Add (Thêm)** ở góc trên bên trái -> chọn **Image file (ISO, WIM, ESD)**.
2. Tìm và chọn file ISO Windows 11 gốc của bạn.
3. Chờ NTLite nạp danh sách các phiên bản trong file ISO.
4. Mở rộng cây thư mục phiên bản Windows -> Click chuột phải vào phiên bản bạn muốn tùy biến (ví dụ: **Windows 11 Pro**) -> Chọn **Load (Nạp)**.
5. Chờ vài phút để NTLite giải nén image vào thư mục tạm.

### Bước 3: Nạp Preset (.xml) vào hệ thống
1. Trên thanh công cụ phía trên, bấm vào thẻ hoặc nút **Preset (Thiết lập sẵn)**.
2. Bấm vào nút **Import (Nhập)** -> Trỏ tới file `.xml` bạn đã tải về từ repo này (ví dụ: `Win11_Pro_25H2_Clean_Preset.xml`).
3. Sau khi preset hiện trong danh sách, click chuột phải vào nó -> chọn **Load (Nạp)** hoặc nhấp đúp vào preset đó.
4. NTLite sẽ tự động tích chọn tất cả các thành phần cần gỡ bỏ, tắt dịch vụ và áp dụng các Registry Tweak tương ứng.

> ⚠️ **Lưu ý về Post-Setup (Nếu có):**  
> Vào mục **Post-Setup (Hậu cài đặt)** kiểm tra xem có đường dẫn file script hoặc app nào bị báo đỏ (do đường dẫn khác máy bạn) không. Nếu có, hãy xóa đi hoặc trỏ lại đường dẫn file trên máy của bạn.

### Bước 4: Áp dụng và xuất file ISO tùy biến
1. Ở cột menu bên trái, cuộn xuống dưới cùng và chọn mục **Apply (Áp dụng)**.
2. Tại bảng cấu hình bên phải:
   - **Saving mode:** Chọn *Save the image and trim editions* (Lưu image và loại bỏ các bản không dùng).
   - **Image format:** Khuyên chọn **ESD** (dung lượng nhẹ nhất) hoặc **WIM**.
   - Tích chọn ô **Create ISO (Tạo ISO)**.
   - Chọn đường dẫn lưu file ISO mới và đặt tên (ví dụ: `Windows_11_Pro_Lite.iso`).
3. Bấm nút **Process (Bắt đầu)** ở góc trên bên trái.
4. Đợi quá trình hoàn tất (thường mất từ 5 – 15 phút tùy cấu hình CPU/SSD).

---

## 🚀 Hướng dẫn cài đặt Windows từ file ISO mới

1. Sử dụng [Rufus](https://rufus.ie/) hoặc [Ventoy](https://www.ventoy.net/) để ghi file ISO vừa tạo vào USB.
2. **Khuyến nghị thử nghiệm:** Trước khi cài lên máy tính thật, bạn nên test file ISO trên máy ảo (**VMware Workstation** hoặc **VirtualBox** / **Hyper-V**) để kiểm tra tính ổn định.
3. Khởi động vào Boot Menu của máy và tiến hành cài đặt Windows như bình thường.

---

## ⚠️ Lưu ý & Miễn trừ trách nhiệm (Disclaimer)

- **Bản quyền:** Repo này **chỉ chia sẻ file cấu hình XML**, hoàn toàn **không** chứa file ISO, mã kích hoạt (Product Key) hay bất kỳ phần mềm vi phạm bản quyền nào của Microsoft.
- **Tương thích:** Một số tính năng chuyên sâu trong preset có thể yêu cầu phiên bản NTLite tương ứng (Free hoặc Home/Pro License).
- **Sao lưu:** Hãy luôn sao lưu dữ liệu quan trọng trước khi cài đặt lại hệ điều hành. Tác giả không chịu trách nhiệm đối với bất kỳ sự cố mất mát dữ liệu nào do việc cài đặt Windows gây ra.

---

## 🤝 Đóng góp & Phản hồi

Nếu bạn phát hiện lỗi hoặc muốn đóng góp các tweak tối ưu hơn, hãy mở một **Issue** hoặc gửi **Pull Request**! Đừng quên tặng ⭐️ cho repo nếu thấy hữu ích nhé!
