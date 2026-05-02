# SaveScoreStudent

DApp quan ly diem sinh vien theo vai tro (Admin, Teacher, Student), gom:

- Smart contracts (Hardhat + Solidity)
- Frontend (Next.js + Tailwind + ethers.js + MetaMask)

## 1) Features

- Phan quyen theo role:
  - `DEFAULT_ADMIN_ROLE` (Admin)
  - `TEACHER_ROLE` (Teacher)
  - `STUDENT_ROLE` (Student)
- Teacher/Admin co the:
  - them sinh vien
  - nhap/cap nhat diem
- Student chi duoc xem diem cua chinh minh
- Cua so sua diem gioi han:
  - `EDIT_WINDOW = 10 minutes` trong `hardhat/contracts/ScoreManager.sol`
- Frontend tu nhan role on-chain va dieu huong:
  - `/admin`, `/teacher`, `/student`
- UI co:
  - transaction status
  - copy tx hash
  - copy wallet address

## 2) Tech Stack

### Smart Contract / Blockchain

- Solidity `^0.8.28`
- Hardhat `^3.x`
- OpenZeppelin Contracts
- Ethers.js `v6`
- Mocha + Chai

### Frontend

- Next.js `14.2.35` (App Router)
- React `18.3.1`
- TypeScript
- Tailwind CSS `v4`
- Ethers.js `v6`
- MetaMask (injected provider)

## 3) Project Structure

```text
SaveScoreStudent/
├─ frontend/
│  ├─ src/
│  │  ├─ app/
│  │  │  ├─ page.tsx
│  │  │  ├─ layout.tsx
│  │  │  ├─ dashboard/
│  │  │  ├─ admin/
│  │  │  ├─ teacher/
│  │  │  └─ student/
│  │  ├─ components/
│  │  │  ├─ forms/
│  │  │  ├─ Navbar.tsx
│  │  │  ├─ ConnectWallet.tsx
│  │  │  ├─ TransactionStatus.tsx
│  │  │  ├─ AdminPanel.tsx
│  │  │  ├─ TeacherPanel.tsx
│  │  │  └─ StudentPanel.tsx
│  │  ├─ context/
│  │  │  └─ WalletContext.tsx
│  │  ├─ services/
│  │  │  ├─ provider.ts
│  │  │  ├─ contracts.ts
│  │  │  └─ contractAddresses.ts
│  │  ├─ lib/
│  │  │  ├─ errors.ts
│  │  │  └─ format.ts
│  │  └─ types/
│  │     └─ ethereum.d.ts
│  ├─ .env.local.example
│  ├─ next.config.mjs
│  └─ package.json
│
└─ hardhat/
   ├─ contracts/
   │  ├─ AccessControlManager.sol
   │  ├─ StudentManager.sol
   │  └─ ScoreManager.sol
   ├─ scripts/
   │  └─ deploy.ts
   ├─ test/
   │  └─ student-score.test.ts
   ├─ hardhat.config.ts
   └─ package.json
```

## 4) Requirements

- Node.js `>= 18` (khuyen nghi Node 20+)
- npm
- MetaMask extension

## 5) Installation

### 5.1 Install smart contract dependencies

```bash
cd hardhat
npm install
```

### 5.2 Install frontend dependencies

```bash
cd ../frontend
npm install
```

## 6) Run Local Demo

Dung 3 terminal.

### Terminal 1: Start local blockchain

```bash
cd hardhat
npx hardhat node
```

### Terminal 2: Compile and deploy contracts

```bash
cd hardhat
npx hardhat compile
npx hardhat run scripts/deploy.ts --network localhost
```

Sau khi deploy, ban se thay 2 dia chi contract:

- `StudentManager`
- `ScoreManager`

### Terminal 3: Start frontend

```bash
cd frontend
npm run dev
```

Open: `http://localhost:3000`

## 7) Environment Variables (Frontend)

Tao file `frontend/.env.local` tu `frontend/.env.local.example` va cap nhat dia chi contract:

```env
NEXT_PUBLIC_ACCESS_CONTROL_ADDRESS=0x...
NEXT_PUBLIC_STUDENT_MANAGER_ADDRESS=0x...
NEXT_PUBLIC_SCORE_MANAGER_ADDRESS=0x...
```

Ghi chu:

- Neu dung `StudentManager` lam access control chung thi `ACCESS_CONTROL_ADDRESS` co the trung `STUDENT_MANAGER_ADDRESS`.

## 8) Test Smart Contracts

```bash
cd hardhat
npx hardhat test
```

Cac test chinh:

- admin add teacher
- teacher add student
- teacher set score
- student getMyScore
- sua score trong 10 phut: pass
- sua score sau 11 phut: fail voi `Edit window expired`
- student khong duoc setScore

## 9) Build Frontend (Production)

```bash
cd frontend
npm run build
npm run start
```

## 10) Core Contracts

### `AccessControlManager.sol`

- Khai bao va quan ly role:
  - `TEACHER_ROLE`
  - `STUDENT_ROLE`
- Ham:
  - `addTeacher`, `removeTeacher`
  - `addStudentRole`, `removeStudentRole`

### `StudentManager.sol`

- Quan ly ho so sinh vien
- Ham:
  - `addStudent(studentId, wallet, name)`
  - `deactivateStudent(wallet)`
  - `getStudent(wallet)`
  - `isStudentRegistered(wallet)`
  - `isStudentActive(wallet)`

### `ScoreManager.sol`

- Quan ly diem theo `studentWallet + subject`
- Gioi han sua diem:
  - `EDIT_WINDOW = 10 minutes`
- Ham:
  - `setScore(studentWallet, subject, value)`
  - `getScore(studentWallet, subject)`
  - `getMyScore(subject)`

## 11) Role Flow on Frontend

- Connect MetaMask
- Frontend doc role on-chain
- Tu dong redirect:
  - Admin -> `/admin`
  - Teacher -> `/teacher`
  - Student -> `/student`
  - Outsider -> chan thao tac quan tri

## 12) Common Issues

- MetaMask not installed
  - Cai MetaMask extension
- Wrong chain/network
  - Chuyen sang local Hardhat network (chain id `31337`)
- Wrong contract addresses
  - Kiem tra `frontend/.env.local`, sau do restart frontend
- `Edit window expired`
  - Qua cua so 10 phut cho phep sua diem
- `Not allowed` / `Only teacher/admin`
  - Vi hien tai khong co role phu hop

## 13) Next Improvements

- Thong ke lich su thay doi diem theo events
- Gioi han diem hop le (vi du 0-100)
- Danh sach subject hop le (whitelist)
- Tach rieng module role management neu can mo rong
