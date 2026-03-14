# Event & Reminder App (Offline)

แอปพลิเคชันสำหรับจัดการกิจกรรมและการแจ้งเตือนแบบออฟไลน์ พัฒนาด้วย **Flutter** โดยใช้ **SQLite** สำหรับจัดการฐานข้อมูลแบบ Local และใช้ **Provider** สำหรับจัดการสถานะการทำงาน (State Management) ภายในแอปพลิเคชัน

---

## 🚀 รายการฟีเจอร์ที่ทำได้ (Features)

1. **การจัดการหมวดหมู่ (Category Management)**
   - เพิ่ม แก้ไข และลบประเภทกิจกรรม
   - กำหนดชื่อ สี (Color Hex) และไอคอนประจำหมวดหมู่ได้
   - **Validation:** มีระบบป้องกันการลบหมวดหมู่ หากหมวดหมู่นั้นยังมีกิจกรรมที่กำลังใช้งานอยู่ (Foreign Key Restriction)

2. **การจัดการกิจกรรม (Event Management)**
   - เพิ่ม แก้ไข ลบ และดูรายละเอียดของกิจกรรม
   - ผูกกิจกรรมเข้ากับหมวดหมู่ที่มีอยู่ในระบบ
   - **Validation:** ตรวจสอบความถูกต้องของเวลา (เวลาสิ้นสุด `End Time` ต้องมากกว่าเวลาเริ่ม `Start Time` เสมอ)
   - อัปเดตสถานะของกิจกรรมได้ (Pending, In Progress, Completed, Cancelled)

3. **ระบบค้นหาและตัวกรอง (Search & Filter)**
   - ค้นหากิจกรรมจากชื่อ (Real-time Search)
   - กรองกิจกรรมตาม "วันที่" (เช่น วันนี้, ทั้งหมด)
   - กรองกิจกรรมตาม "ประเภทกิจกรรม"
   - กรองกิจกรรมตาม "สถานะ"

---

## 🗄️ โครงสร้างตารางฐานข้อมูล (Database Structure)

แอปพลิเคชันนี้ใช้ SQLite โดยมีการออกแบบตารางที่มีความสัมพันธ์กัน (Relational Database) ดังนี้:

### 1. Table: `categories` (เก็บข้อมูลประเภทกิจกรรม)
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | INTEGER | Primary Key (Auto Increment) |
| `name` | TEXT | ชื่อประเภทกิจกรรม |
| `color_hex` | TEXT | รหัสสี (เช่น #FF5733) |
| `icon_key` | TEXT | ชื่อคีย์ของไอคอน |
| `created_at` | TEXT | วันเวลาที่สร้างข้อมูล |

### 2. Table: `events` (เก็บข้อมูลกิจกรรม)
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | INTEGER | Primary Key (Auto Increment) |
| `title` | TEXT | ชื่อกิจกรรม |
| `description` | TEXT | รายละเอียดกิจกรรม |
| `category_id` | INTEGER | **Foreign Key** อ้างอิงตาราง `categories` |
| `event_date` | TEXT | วันที่จัดกิจกรรม (YYYY-MM-DD) |
| `start_time` | TEXT | เวลาเริ่ม (HH:mm) |
| `end_time` | TEXT | เวลาสิ้นสุด (HH:mm) |
| `status` | TEXT | สถานะ (Pending, In Progress, Completed, Cancelled) |
| `priority` | INTEGER | ระดับความสำคัญ (1-3) |

### 3. Table: `reminders` (เก็บข้อมูลการแจ้งเตือน)
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | INTEGER | Primary Key (Auto Increment) |
| `event_id` | INTEGER | **Foreign Key** อ้างอิงตาราง `events` (ON DELETE CASCADE) |
| `minutes_before` | INTEGER | แจ้งเตือนล่วงหน้ากี่นาที |
| `remind_at` | TEXT | เวลาที่ต้องแจ้งเตือนจริง (คำนวณจาก Start Time) |
| `is_enabled` | INTEGER | สถานะเปิด/ปิดแจ้งเตือน (1=เปิด, 0=ปิด) |

---
## รููปภาพ
<img width="474" height="1008" alt="Image" src="https://github.com/user-attachments/assets/ee13415d-8b4b-469b-a232-1ec93f7bab0d" />
<img width="480" height="1007" alt="Image" src="https://github.com/user-attachments/assets/37a3c2e4-52e9-46dc-b877-3d174d95daa8" />
<img width="483" height="1012" alt="Image" src="https://github.com/user-attachments/assets/9eb38a0a-7372-44b4-a9ae-47365f32f7a4" />
## 💻 วิธีรันโปรเจกต์ (How to Run)

1. ตรวจสอบให้แน่ใจว่าติดตั้ง Flutter SDK และตั้งค่า Emulator หรือเสียบสายเชื่อมต่อกับสมาร์ทโฟนเรียบร้อยแล้ว
2. เปิด Terminal แล้วเข้าไปที่โฟลเดอร์โปรเจกต์ รันคำสั่งต่อไปนี้เพื่อดาวน์โหลดแพ็กเกจที่จำเป็น:
   ```bash
   flutter pub get
