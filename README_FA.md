<p align="center">
  <a href="README.md">🇺🇸 English</a> |
  <a href="README_FA.md">🇮🇷 فارسی</a>
</p>

<h1 align="center">هم‌نوا 💬</h1>

<p align="center">
یک پیام‌رسان امن، سریع و سبک برای کاربرانی با دسترسی محدود به اینترنت
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue" />
  <img src="https://img.shields.io/badge/Backend-PocketBase-green" />
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture-orange" />
  <img src="https://img.shields.io/badge/State-BLoC-purple" />
</p>

---
## 📖 معرفی
**هم‌نوا (HamNava)** یک اپلیکیشن پیام‌رسان متن‌باز است که به شما اجازه می‌دهد بک‌اند (Backend) خود را در هر محیطی — از یک لپ‌تاپ ساده تا سرورهای ابری قدرتمند — میزبانی کنید (Self-hosted). هدف این پروژه ارائه ارتباطات امن و پایدار با وابستگی صفر به اینترنت جهانی یا سرورهای متمرکز است.

## 🚀 تکنولوژی‌ها
* **Flutter** (رابط کاربری / Frontend)
* **PocketBase** (بک‌اند، دیتابیس و احراز هویت)
* **BLoC** (مدیریت وضعیت / State Management)
* **Clean Architecture** (معماری تمیز / Domain-Driven Design)
* **GetIt & GoRouter** (تزریق وابستگی و مسیریابی)

## 📱 قابلیت‌های کلیدی
* **چت خصوصی و گروهی:** پیام‌رسانی آنی با تحویل فوری.
* **مدیریت دوستان:** جستجو و افزودن دوستان از طریق نام کاربری یا شناسه یکتا (ID).
* **پاکسازی خودکار فایل‌ها:** حذف خودکار فایل‌ها از سرور پس از ۵ دقیقه برای پایین نگه داشتن مصرف فضای ذخیره‌سازی.
* **رابط کاربری مدرن:** طراحی تمیز و مینیمال با پشتیبانی کامل از **حالت تاریک (Dark Mode 🌙)**.

---

## 📸 اسکرین شات
<img width="172" height="360" alt="Screenshot 2026-06-15 020129" src="https://github.com/user-attachments/assets/538ecdaf-eef3-428d-a1e5-2d9a6054a9c7" />
<img width="172" height="360" alt="Screenshot 2026-06-15 020202" src="https://github.com/user-attachments/assets/5fe7d135-8b6d-4b27-bdf5-27a87bd2eabb" />
<img width="172" height="360" alt="Screenshot 2026-06-15 020235" src="https://github.com/user-attachments/assets/f6cb7999-3bf2-4ed7-85a8-5c0c17f6fc3f" />
<img width="172" height="360" alt="Screenshot 2026-06-15 020648" src="https://github.com/user-attachments/assets/467d2956-3900-4322-a655-1ee69805e6ba" />
<img width="172" height="360" alt="Screenshot 2026-06-15 022014" src="https://github.com/user-attachments/assets/7053cea6-5d63-4de2-863d-84b1c567abb8" />
<img width="172" height="360" alt="Screenshot 2026-06-15 020836" src="https://github.com/user-attachments/assets/e0848f69-2204-4cb9-b3a0-a8d9a9249bcc" />
<img width="172" height="360" alt="Screenshot 2026-06-15 020300" src="https://github.com/user-attachments/assets/9c19b039-e673-4b91-9178-294120d08f2f" />
<img width="172" height="360" alt="Screenshot 2026-06-15 020711" src="https://github.com/user-attachments/assets/bc657092-e2b2-4cf9-8d58-db22a2ce6ea4" />
<img width="172" height="360" alt="Screenshot 2026-06-15 020730" src="https://github.com/user-attachments/assets/cb1aa42e-6e14-4dbf-a4a5-023de16ff3d8" />
<img width="172" height="360" alt="Screenshot 2026-06-15 020751" src="https://github.com/user-attachments/assets/4b7bb246-ea46-483a-8b28-6c7c3f127bf7" />
<img width="172" height="360" alt="Screenshot 2026-06-15 020903" src="https://github.com/user-attachments/assets/1657637b-439a-41d3-94c9-2247b526cc6a" />

---

## 🛠️ راهنمای گام‌به‌گام راه‌اندازی سرور

هم‌نوا به یک سرور بک‌اند نیاز دارد. روشی را که با نیازهای شما سازگارتر است انتخاب کنید:

### روش ۱: اجرا روی سیستم شخصی (لوکال - برای تست و شبکه داخلی)
1. آخرین نسخه [PocketBase](https://github.com/pocketbase/pocketbase) را دانلود کنید.
2. ترمینال/CMD خود را در آن پوشه باز کرده و دستور زیر را اجرا کنید:

   ```bash
   .\pocketbase.exe serve --http="0.0.0.0:8090"
اگر هنوز حسابی ندارید، لینکی که در پایین صفحه CMD نمایش داده می‌شود را در مرورگر باز کرده و ثبت‌نام کنید.

برای دسترسی به پنل مدیریت، آدرس http://127.0.0.1:8090/_/ را در مرورگر خود باز کنید.

## روش ۲: سرور مجازی / VPS (برای دسترسی عمومی و پایداری)

یک سرور مجازی لینوکس (Ubuntu 22.04+) آماده کنید.

فایل باینری لینوکس PocketBase را به سرور خود منتقل کنید.

با استفاده از Systemd یک سرویس در پس‌زمینه ایجاد کنید تا سرور همیشه فعال بماند.

امنیت: از Nginx به عنوان Reverse Proxy استفاده کنید و گواهی SSL (HTTPS) را از طریق Certbot نصب کنید تا انتقال امن داده‌ها تضمین شود.

مطمئن شوید پورت‌های 80 و 443 (یا پورت انتخابی شما) در فایروال سرور باز هستند.

## روش ۳: سرویس‌های ابری (لیارا / Docker)

شما میتوانید از طریق سایت لیارا و یا چاباکان از قسمت برنامه های اماده پاکت بیس رو انتخاب کرده و با زدن ساخت سریع به پاکت بیس دسترسی داشته باشید
## ⚙️ پیکربندی دیتابیس (ضروری)

پس از ورود به پنل مدیریت (در هر یک از روش‌های بالا):

ایمپورت ساختار (Schema): به مسیر Settings > Import collections بروید و فایل pb.json موجود در این ریپازیتوری را ایمپورت کنید (گزینه "Merge with existing" را انتخاب کنید).

تنظیمات کالکشن کاربران (Users):

کالکشن users را باز کنید. روی New field کلیک کنید:

فیلد userName (نوع: Text) را اضافه کنید.

فیلد friend (نوع: Relation -> هدف: users) را اضافه کنید.

مهم: در تنظیمات فیلد friend، گزینه "multiple" را انتخاب کنید تا امکان داشتن لیست بی‌نهایت از دوستان فراهم شود.

## پیکربندی قوانین امنیتی (API Rules):

به کالکشن users بروید و روی آیکون قفل (API Rules) کلیک کنید:

قانون List/Search & View را اینگونه تنظیم کنید: @request.auth.id != ""

قانون Create: (خالی بگذارید)

قانون Update را اینگونه تنظیم کنید: id = @request.auth.id

روی Save changes کلیک کنید.

## 🏃 اجرای اپلیکیشن فلاتر

کلون و راه‌اندازی:

   ```bash
git clone [https://github.com/your-username/hamnava.git](https://github.com/your-username/hamnava.git)
cd hamnava
flutter pub get
flutter run
  ```
## اتصال به سرور:


اپلیکیشن را باز کنید. در صفحه ورود (Login)، روی آیکون تنظیمات (چرخ‌دنده) کلیک کنید.

آدرس سرور خود را وارد کنید (مثال: http://192.168.1.5:8090 یا https://api.yourdomain.ir).

روی "Connect" (اتصال) کلیک کنید، ثبت‌نام کنید و لذت ببرید!

## 🤝 مشارکت

مشارکت‌های شما هم‌نوا را بهتر می‌کند. شما می‌توانید:

پروژه را Fork کنید.

یک شاخه (Branch) جدید برای ویژگی مورد نظر بسازید.

یک Pull Request ثبت کنید.


## 📄 لایسنس
MIT LicenseIT License

## ❤️ یادداشت پایانی
هدف هم‌نوا ارائه یک راهکار ارتباطی پایدار و امن در شرایط چالش‌برانگیز شبکه‌ای است.
