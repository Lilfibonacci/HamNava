<p align="center">
  <a href="README.md">🇺🇸 English</a> |
  <a href="README_FA.md">🇮🇷 فارسی</a>
</p>

<h1 align="center">HamNava 💬</h1>

<p align="center">
A secure, fast and lightweight messaging app for users with limited internet access
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue" />
  <img src="https://img.shields.io/badge/Backend-PocketBase-green" />
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture-orange" />
  <img src="https://img.shields.io/badge/State-BLoC-purple" />
</p>

---
## 📖 Overview
**HamNava** is an open-source messaging application that allows you to host your own backend (self-hosted) in any environment—from a simple laptop to powerful cloud servers. This project aims to provide secure, stable communication with zero dependency on global internet or centralized servers.

## 🚀 Tech Stack
* **Flutter** (Frontend/UI)
* **PocketBase** (Backend, Database, & Auth)
* **BLoC** (State Management)
* **Clean Architecture** (Domain-Driven Design)
* **GetIt & GoRouter** (Dependency Injection & Navigation)

## 📱 Key Features
* **Private & Group Chat:** Real-time messaging with instant delivery.
* **Friend Management:** Search and add friends by their Unique ID/Username.
* **Auto-Media Cleanup:** Files are automatically deleted from the server after 5 minutes to keep your storage usage low.
* **Modern UI:** Clean, minimal design with full **Dark Mode 🌙** support.

---

## 🛠️ Step-by-Step Hosting Guide

HamNava requires a backend server. Choose the method that best fits your needs:

### Method 1: Localhost (For Testing & LAN)
1. Download the latest [PocketBase ](https://github.com/pocketbase/pocketbase).
3. Open your terminal/CMD in that folder and run:


   ```bash
   .\pocketbase.exe serve --http="0.0.0.0:8090"

If you don't have an account yet, open the link at the bottom of the cmd page in your browser and register.   
   
Open http://127.0.0.1:8090/_/ in your browser to access the admin panel.

## Method 2: VPS (For Public Access & Stability)
Prepare a Linux VPS (Ubuntu 22.04+).

Transfer the PocketBase Linux binary to your server.

Use Systemd to create a background service so the server stays active.

Security: Use Nginx as a Reverse Proxy and install SSL (HTTPS) via Certbot to ensure secure data transfer.

Ensure ports 80 and 443 (or your chosen port) are open in your server firewall.

## Method 3: Cloud (Liara / Docker)
You can select Pocket Base from the ready-made programs section through Liara or Chabakan sites and access Pocket Base by clicking on Quick Build.

## ⚙️ Database Configuration (Essential)
After accessing your Admin Panel (in any of the methods above):

Import Schema: Go to Settings > Import collections and import the pb.json file provided in this repository (Select "Merge with existing").

Setup Users Collection:

Open the users collection. Click New field:

Add userName (Type: Text).

Add friend (Type: Relation -> target: users).

Important: In friend field settings, select "multiple" to allow an unlimited friend list.

## Configure API Rules:

Go to the users collection and click the Lock icon (API Rules):

List/Search & View rule: @request.auth.id != ""

Create rule: (Leave empty)

Update rule: id = @request.auth.id

Click Save changes.

## 🏃 Running the Flutter App
Clone & Setup:

   ```bash
git clone [https://github.com/your-username/hamnava.git](https://github.com/your-username/hamnava.git)
cd hamnava
flutter pub get
flutter run
Connect to Server:
 ```
Open the app. On the Login screen, tap the Settings icon (gear).

Enter your server address (e.g., http://192.168.1.5:8090 or https://api.yourdomain.ir).

Tap "Connect", sign up, and enjoy!

## 🤝 Contributing
Contributions make HamNava better. Feel free to:

Fork the project.

Create a new feature branch.

Submit a Pull Request.

## 📄 License
MIT License

## ❤️ Final Note

HamNava aims to provide a **reliable and secure communication solution** in challenging network conditions.
