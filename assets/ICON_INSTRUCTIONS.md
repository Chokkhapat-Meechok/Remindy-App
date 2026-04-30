วิธีใช้ไอคอนใหม่

1) ใส่รูปไอคอนที่คุณให้มาเป็นไฟล์ PNG ลงที่: assets/icon.png
   - แทนที่ไฟล์เดิม หากมีไฟล์ชื่อเดียวกันอยู่

2) ติดตั้ง dependency และสร้างไอคอนสำหรับ Android/iOS โดยรันคำสั่งในโฟลเดอร์โปรเจค (`c:\projects\remindy`):

```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

3) ตรวจสอบผลลัพธ์
   - Android: ไฟล์ launcher icon จะถูกอัพเดตในโฟลเดอร์ `android/app/src/main/res/mipmap-*` และ `mipmap-anydpi-v26`
   - iOS: ไฟล์ไอคอนจะถูกอัพเดตใน `ios/Runner/Assets.xcassets/AppIcon.appiconset`

หมายเหตุ:
- หากคุณต้องการให้ฉันรันคำสั่งสร้างไอคอนให้ (ถ้าระบบมี Flutter ติดตั้ง), บอกฉันได้ ฉันจะรันให้และรายงานผล
- การแทนที่ไอคอนนี้จะช่วยให้ภาพไอคอนในแอปตรงกับภาพที่แสดงใน Store ตามนโยบาย
