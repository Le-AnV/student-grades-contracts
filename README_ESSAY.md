# README_ESSAY.md

## Mục lục

- [CHƯƠNG 1. PHẦN MỞ ĐẦU](#chương-1-phần-mở-đầu)
- [CHƯƠNG 2. TỔNG QUAN HỆ THỐNG](#chương-2-tổng-quan-hệ-thống)
- [CHƯƠNG 3. THIẾT KẾ SMART CONTRACT](#chương-3-thiết-kế-smart-contract)
- [CHƯƠNG 4. THIẾT KẾ FRONTEND VÀ LUỒNG NGƯỜI DÙNG](#chương-4-thiết-kế-frontend-và-luồng-người-dùng)
- [CHƯƠNG 5. KIỂM THỬ, TRIỂN KHAI VÀ VẬN HÀNH](#chương-5-kiểm-thử-triển-khai-và-vận-hành)
- [CHƯƠNG 6. KẾT LUẬN](#chương-6-kết-luận)

## CHƯƠNG 1. PHẦN MỞ ĐẦU

### 1.1 Giới thiệu đề tài

- Trình bày bài toán quản lý điểm sinh viên bằng smart contract trên blockchain.
- Nêu bối cảnh: quản lý phân quyền, lưu điểm minh bạch, hạn chế sửa sai trái phép.
- Mô tả ngắn gọn hệ thống gồm Hardhat, Solidity, Next.js, MetaMask.

### 1.2 Lý do chọn đề tài

- Giải thích nhu cầu số hóa việc nhập và tra cứu điểm trong môi trường học tập.
- Nhấn mạnh lợi ích của blockchain: minh bạch, truy vết, kiểm soát quyền truy cập.
- Có thể bổ sung ví dụ thực tế về sai sót khi quản lý điểm theo cách thủ công.

### 1.3 Mục tiêu và phạm vi

- Nêu mục tiêu xây dựng DApp có phân quyền Admin, Teacher, Student.
- Mô tả phạm vi chức năng: thêm sinh viên, nhập điểm, xem điểm, tự động nhận diện role.
- Chưa triển khai mở rộng như thống kê nâng cao hay lịch sử chỉnh sửa đầy đủ; đề xuất trình bày là hướng phát triển.

### 1.4 Công nghệ sử dụng

- Liệt kê Solidity, Hardhat, OpenZeppelin, Ethers.js, Next.js, React, TypeScript, Tailwind CSS.
- Nêu vai trò từng công nghệ trong hệ thống: contract, test, frontend, kết nối ví.
- (Cần hình: sơ đồ stack công nghệ của dự án.)

## CHƯƠNG 2. TỔNG QUAN HỆ THỐNG

### 2.1 Bài toán và tác nhân hệ thống

- Mô tả các vai trò chính: Admin, Teacher, Student, Outsider.
- Trình bày quyền hạn cơ bản của từng vai trò theo đúng logic trong contract và frontend.
- Nên nhấn mạnh mối quan hệ giữa người dùng, ví MetaMask và smart contract.

### 2.2 Kiến trúc tổng thể của dự án

- Mô tả luồng tổng quát: MetaMask -> WalletContext -> detect role -> dashboard -> panel tương ứng.
- Nêu hai lớp chính của hệ thống: `hardhat/` cho blockchain và `frontend/` cho giao diện.
- (Cần hình: sơ đồ kiến trúc tổng thể end-to-end.)

### 2.3 Luồng dữ liệu và điều hướng theo role

- Trình bày cách frontend đọc role on-chain và tự điều hướng sang `/admin`, `/teacher`, `/student`.
- Mô tả cơ chế bảo vệ giao diện: sai role thì bị chuyển về `/dashboard`.
- Nên ghi rõ đây là lớp bảo vệ UI, còn kiểm soát cuối cùng vẫn nằm ở smart contract.

### 2.4 Nguồn dữ liệu và cách thu thập dữ liệu

- Nêu dữ liệu đầu vào chính là địa chỉ ví, role on-chain, studentId, tên sinh viên, subject, score.
- Mô tả dữ liệu được lấy trực tiếp từ blockchain thông qua ethers.js và hợp đồng thông minh.
- Chưa có pipeline thu thập dữ liệu ngoài chuỗi; đề xuất trình bày là nguồn dữ liệu được nhập thủ công qua form.

### 2.5 Mô hình triển khai cục bộ

- Mô tả cách chạy local bằng Hardhat node, deploy contract, rồi chạy frontend.
- Nêu mục đích môi trường local: phát triển, demo, kiểm thử nhanh.
- (Cần hình: sơ đồ quy trình chạy local 3 terminal.)

## CHƯƠNG 3. THIẾT KẾ SMART CONTRACT

### 3.1 Tổng quan lớp hợp đồng và phân quyền

- Giới thiệu `AccessControlManager` là lớp nền quản lý role.
- Mô tả `StudentManager` quản lý hồ sơ sinh viên và `ScoreManager` quản lý điểm.
- Nêu ý nghĩa việc tách contract: giảm phụ thuộc, rõ trách nhiệm từng module.

### 3.2 Thiết kế AccessControlManager

- Trình bày các role chính: `DEFAULT_ADMIN_ROLE`, `TEACHER_ROLE`, `STUDENT_ROLE`.
- Mô tả các hàm thêm/xóa role và modifier kiểm tra quyền.
- (Cần hình: sơ đồ phân quyền role hoặc bảng quyền hạn.)

### 3.3 Thiết kế StudentManager

- Mô tả cấu trúc lưu hồ sơ sinh viên theo wallet và theo studentId.
- Trình bày các hàm `addStudent`, `deactivateStudent`, `getStudent`, `getStudentById`.
- Nên nhấn mạnh cơ chế auto-grant `STUDENT_ROLE` khi thêm sinh viên mới.

### 3.4 Thiết kế ScoreManager

- Mô tả cách lưu điểm theo cặp `studentWallet + subject`.
- Trình bày quy tắc nhập điểm lần đầu, sửa điểm trong `EDIT_WINDOW = 10 minutes`, và điều kiện từ chối khi hết hạn.
- Nên nêu các hàm `setScore`, `getScore`, `getMyScore`.

### 3.5 Ràng buộc nghiệp vụ và sự kiện

- Liệt kê các điều kiện kiểm tra: student phải tồn tại, đang active, đúng role, không được truy cập trái phép.
- Mô tả các event như `StudentAdded`, `StudentDeactivated`, `ScoreCreated`, `ScoreUpdated`.
- (Cần hình: sơ đồ sequence cho thao tác thêm sinh viên hoặc nhập điểm.)

### 3.6 Hạn chế hiện tại của phần smart contract

- Chưa thấy cơ chế giới hạn điểm hợp lệ theo thang 0-100; có thể đề xuất bổ sung.
- Chưa có whitelist môn học hay lịch sử chỉnh sửa chi tiết ở mức báo cáo.
- Chưa triển khai monitoring on-chain; đề xuất trình bày theo hướng mở rộng hệ thống.

## CHƯƠNG 4. THIẾT KẾ FRONTEND VÀ LUỒNG NGƯỜI DÙNG

### 4.1 Cấu trúc frontend và các trang chính

- Trình bày App Router với các trang `/`, `/dashboard`, `/admin`, `/teacher`, `/student`.
- Mô tả vai trò của `layout.tsx`, `Navbar`, `ConnectWallet`, và các panel theo role.
- (Cần hình: sơ đồ cây trang hoặc sơ đồ điều hướng giao diện.)

### 4.2 WalletContext và kết nối MetaMask

- Mô tả cách app kiểm tra ví, kết nối tài khoản, lấy chainId và signer.
- Nêu cơ chế lắng nghe `accountsChanged` và `chainChanged` để đồng bộ trạng thái.
- Nên trình bày đây là trung tâm quản lý trạng thái ví của toàn bộ frontend.

### 4.3 Nhận diện role và điều hướng giao diện

- Trình bày cách frontend gọi contract để xác định admin, teacher, student hoặc outsider.
- Mô tả logic redirect tự động từ dashboard sang trang tương ứng.
- Chưa có role ngoài 3 nhóm chính; nếu cần mở rộng thì đề xuất thêm lớp phân quyền khác.

### 4.4 Thiết kế các panel theo vai trò

- AdminPanel: mô tả các chức năng quản trị teacher, student và điểm.
- TeacherPanel: mô tả thêm sinh viên, nhập điểm, tra cứu điểm.
- StudentPanel: mô tả xem profile và xem điểm cá nhân.
- (Cần hình: ảnh chụp màn hình từng panel.)

### 4.5 Thiết kế form và luồng giao dịch UI

- Trình bày mẫu xử lý giao dịch: validate input -> gọi contract -> lấy tx hash -> chờ xác nhận -> hiển thị kết quả.
- Nêu các form chính: AddTeacherForm, AddStudentForm, SetScoreForm, GetScoreForm.
- Nên mô tả `TransactionStatus` và chức năng copy tx hash / copy wallet address.

### 4.6 Xử lý lỗi, trạng thái và trải nghiệm người dùng

- Mô tả cách map lỗi smart contract sang thông báo giao diện bằng hàm xử lý lỗi.
- Nêu các trạng thái cần trình bày: chưa kết nối ví, đang kiểm tra role, đang xử lý giao dịch, thành công, thất bại.
- Chưa thấy logging/monitoring UI riêng; đề xuất trình bày là hệ thống hiện tại mới tập trung vào trạng thái giao dịch cơ bản.

### 4.7 Visualization / dashboard

- Nếu cần viết theo hướng báo cáo, mô tả dashboard ở đây là dashboard điều hướng theo role, không phải dashboard phân tích số liệu.
- Trình bày các khối thông tin tóm tắt: wallet, chainId, role, trạng thái kết nối.
- (Cần hình: screenshot trang home, dashboard, và các panel role.)

## CHƯƠNG 5. KIỂM THỬ, TRIỂN KHAI VÀ VẬN HÀNH

### 5.1 Kiểm thử smart contract

- Trình bày các test hiện có: thêm teacher, thêm student, set score, getMyScore, sửa điểm trong 10 phút, sửa điểm sau 11 phút, chặn student gọi setScore.
- Nêu mục tiêu test là xác minh đúng logic phân quyền và ràng buộc thời gian.
- (Cần hình: ảnh kết quả chạy test hoặc log terminal.)

### 5.2 Triển khai local và cấu hình môi trường

- Mô tả quy trình chạy Hardhat node, compile, deploy, rồi cấu hình frontend bằng địa chỉ contract.
- Nêu vai trò của file cấu hình môi trường và việc khởi động lại frontend sau khi đổi địa chỉ.
- Chưa có triển khai production hoặc CI/CD; đề xuất trình bày theo hướng demo nội bộ/local environment.

### 5.3 Vận hành hệ thống

- Trình bày các tình huống sử dụng thường gặp: sai network, chưa cài MetaMask, sai role, contract address sai.
- Nêu cách người dùng thao tác trên giao diện để giảm lỗi vận hành.
- Có thể thêm hình luồng thao tác người dùng từ kết nối ví đến nhập điểm.

### 5.4 Logging, monitoring, error handling

- Chưa triển khai logging và monitoring chuyên biệt; cần ghi rõ trong báo cáo là phạm vi hiện tại.
- Đề xuất trình bày hướng phát triển: thêm audit log, theo dõi transaction, cảnh báo lỗi giao dịch.
- Nên mô tả cơ chế hiện tại chủ yếu là error handling ở frontend và revert reason từ contract.

## CHƯƠNG 6. KẾT LUẬN

### 6.1 Kết quả đạt được

- Tóm tắt hệ thống đã đáp ứng quản lý điểm sinh viên theo vai trò với smart contract và frontend.
- Nêu các chức năng chính đã hoàn thành: phân quyền, thêm sinh viên, nhập/xem điểm, điều hướng theo role.
- Có thể nhấn mạnh tính minh bạch và kiểm soát truy cập của blockchain.

### 6.2 Hạn chế của hệ thống

- Chưa có dashboard phân tích dữ liệu, thống kê nâng cao hoặc báo cáo trực quan.
- Chưa có monitoring, logging trung tâm, CI/CD, và triển khai production hoàn chỉnh.
- Chưa có các ràng buộc nghiệp vụ mở rộng như giới hạn điểm, whitelist môn học, hay lịch sử chỉnh sửa chi tiết.

### 6.3 Hướng phát triển

- Bổ sung thống kê lịch sử thay đổi điểm, biểu đồ, và báo cáo cho giảng viên/quản trị.
- Hoàn thiện validation nghiệp vụ, audit trail, và cảnh báo lỗi tự động.
- Có thể mở rộng thêm module quản trị tập trung hoặc tách riêng hệ thống role management nếu quy mô lớn hơn.
