# SaveScoreStudent - Logic Flow

Tai lieu nay mo ta luong logic chinh cua du an dua tren code hien tai: smart contract -> frontend -> MetaMask -> chuyen huong theo role.

## 1. Tong quan he thong

Du an gom 2 lop chinh:

1. `hardhat/` chiu trach nhiem luu tru logic nghiep vu tren blockchain.
2. `frontend/` chiu trach nhiem ket noi vi, doc role on-chain, dieu huong trang va goi contract.

Du lieu chinh di theo luong:

`MetaMask` -> `WalletContext` -> `detectUserRole()` -> route theo role -> panel tuong ung -> contract call.

## 2. Lop smart contract

### 2.1 AccessControlManager

Day la lop nen cho phan quyen.

- `DEFAULT_ADMIN_ROLE` la admin goc, duoc cap cho nguoi deploy.
- `TEACHER_ROLE` va `STUDENT_ROLE` duoc dinh nghia bang hash role.
- Admin co the:
  - them/xoa teacher
- Admin hoac teacher co the:
  - them/xoa student role

Day la hop dong tao logic quyen, khong luu diem hay thong tin sinh vien.

### 2.2 StudentManager

Hop dong nay quan ly ho so sinh vien.

- `addStudent(studentId, wallet, name)`
  - chi admin hoac teacher duoc goi
  - kiem tra `wallet` hop le
  - khong cho trung `studentId` va `wallet`
  - luu ho so vao `studentsByWallet`
  - auto cap `STUDENT_ROLE` cho wallet do
- `deactivateStudent(wallet)`
  - chi admin
  - danh dau `active = false`
- `getStudent(wallet)`
  - chi owner, admin, hoac teacher
- `getStudentById(studentId)`
  - tim sinh vien theo hash cua studentId

Y nghia logic:

- Sinh vien khong duoc tao thu cong bang cach tu cap quyen.
- Moi student hop le deu phai duoc tao qua `StudentManager` de co ho so + role.

### 2.3 ScoreManager

Hop dong nay quan ly diem theo cap:

`studentWallet + subject -> Score`

- `setScore(studentWallet, subject, value)`
  - chi admin hoac teacher
  - chi cho student da duoc dang ky va dang active
  - neu la lan dau thi tao score moi
  - neu da co score thi chi duoc sua trong `EDIT_WINDOW = 10 minutes`
- `getScore(studentWallet, subject)`
  - chi owner, admin, hoac teacher
- `getMyScore(subject)`
  - student tu xem diem cua chinh minh

Y nghia logic:

- Lan nhap diem dau tien tao ban ghi.
- Cac lan sua tiep theo bi gioi han boi cua so 10 phut tinh tu `createdAt`.
- Neu qua gioi han, giao dich bi fail voi `Edit window expired`.

## 3. Luong khoi dong frontend

### 3.1 Khoi tao trang

Khi vao app, `frontend/src/app/layout.tsx` boi bao cac trang vao `WalletProvider` va `Navbar`.

`WalletContext` lam 3 viec:

1. Kiem tra co MetaMask hay khong.
2. Kiem tra da ket noi san chua bang `eth_accounts`.
3. Neu co account, dong bo lai:
   - `address`
   - `chainId`
   - `provider`
   - `signer`
   - `role`

### 3.2 Ket noi vi

Ham `connect()` trong `WalletContext`:

1. Goi `eth_requestAccounts`.
2. Tao `BrowserProvider` va lay `signer`.
3. Lay `address` va `chainId`.
4. Goi `detectUserRole()` de doc role on-chain.

Neu nguoi dung doi account hoac doi network, event listener `accountsChanged` va `chainChanged` se dong bo lai trang thai.

## 4. Cach frontend nhan dien role

Ham `detectUserRole()` trong `frontend/src/services/contracts.ts` lam viec truc tiep voi contract access control:

1. Doc `TEACHER_ROLE()` va `STUDENT_ROLE()`.
2. Kiem tra `hasRole(DEFAULT_ADMIN_ROLE, account)`.
3. Neu khong phai admin, kiem tra teacher.
4. Neu khong phai teacher, kiem tra student.
5. Neu khong khop gi ca thi tra ve `outsider`.

Thu tu uu tien:

`admin` > `teacher` > `student` > `outsider`

## 5. Luong dieu huong trang

### 5.1 Dashboard trung tam

Trang `/dashboard` la diem vao logic role.

- Neu chua ready thi hien trang thai dang kiem tra.
- Neu chua connect thi yeu cau ket noi MetaMask.
- Neu da connect:
  - `admin` -> `/admin`
  - `teacher` -> `/teacher`
  - `student` -> `/student`
  - `outsider` -> bao khong co quyen truy cap

### 5.2 Trang admin / teacher / student

Moi trang role deu tu kiem tra quyen trong `useEffect`:

- Sai role -> dieu huong ve `/dashboard`
- Dung role -> hien panel tuong ung

Day la lop bao ve UI, khong phai lop bao ve chinh. Lop bao ve chinh van nam trong smart contract.

## 6. Luong nghiep vu theo role

### 6.1 Admin

Admin co the:

- them / xoa teacher
- them student
- nhap / sua diem
- xem thong tin student va diem cua bat ky sinh vien nao

Trong `AdminPanel`:

- `addTeacher()` goi vao ca `AccessControlManager` va `ScoreManager`
- `removeTeacher()` cung dong bo ca 2 hop dong
- `addStudent()` goi `StudentManager.addStudent()`
- `setScore()` goi `ScoreManager.setScore()`
- `getScore()` goi `ScoreManager.getScore()`

Y nghia cua viec goi 2 contract khi them/xoa teacher:

- `AccessControlManager` quan ly role chung
- `ScoreManager` can co cung bo quyen teacher/admin de cho phep setScore va getScore

### 6.2 Teacher

Teacher co the:

- them student
- nhap diem
- tra cuu diem cua sinh vien

Trong `TeacherPanel`:

- `addStudent()` goi `StudentManager.addStudent()`
- `setScore()` goi `ScoreManager.setScore()`
- `getScore()` goi `ScoreManager.getScore()`

### 6.3 Student

Student chi co the:

- xem profile cua chinh minh
- xem diem cua chinh minh

Trong `StudentPanel`:

- khi mount, frontend goi `StudentManager.getStudent(address)` de doc profile
- `MyScoreView` goi `ScoreManager.getMyScore(subject)` de lay diem cua wallet hien tai

## 7. Luong giao dich UI

Tat ca form giao dich deu di theo mau sau:

1. Validate du lieu dau vao o frontend.
2. Tao contract instance bang `signer`.
3. Goi ham contract.
4. Hien `tx.hash` trong `TransactionStatus`.
5. Cho `tx.wait()` de xac nhan blockchain.
6. Cap nhat trang thai success hoac error.

Mau nay duoc dung trong:

- `AddTeacherForm`
- `AddStudentForm`
- `SetScoreForm`
- `GetScoreForm`

Loi tu smart contract se duoc map sang thong bao UI bang `getErrorMessage()`.

## 8. Tinh trang du lieu va rang buoc quan trong

- `ScoreManager` khong cho nhap diem cho student chua dang ky.
- `ScoreManager` khong cho nhap diem cho student inactive.
- Student khong duoc goi cac ham quan tri.
- UI co the an chan theo role, nhung contract moi la noi quyet dinh cuoi cung.
- `EDIT_WINDOW = 10 minutes` chi anh huong lan sua diem, khong anh huong lan tao diem moi.

## 9. Tom tat end-to-end

1. Nguoi dung mo app va ket noi MetaMask.
2. Frontend doc address + chainId + role tu blockchain.
3. App tu dong chuyen ve trang phu hop voi role.
4. User thao tac tren panel tuong ung.
5. Frontend validate input va goi contract bang signer.
6. Contract kiem tra role, tinh hop le cua data, va ghi state len chain.
7. UI nhan tx hash, cho xac nhan, sau do cap nhat ket qua.

## 10. Dia chi file lien quan

- Smart contract phan quyen: `hardhat/contracts/AccessControlManager.sol`
- Quan ly sinh vien: `hardhat/contracts/StudentManager.sol`
- Quan ly diem: `hardhat/contracts/ScoreManager.sol`
- Ket noi vi: `frontend/src/context/WalletContext.tsx`
- Nhan dien role: `frontend/src/services/contracts.ts`
- Dieu huong theo role: `frontend/src/app/dashboard/page.tsx`
- UI admin: `frontend/src/components/AdminPanel.tsx`
- UI teacher: `frontend/src/components/TeacherPanel.tsx`
- UI student: `frontend/src/components/StudentPanel.tsx`
