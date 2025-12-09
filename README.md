# Marzban Auxiliary Panel (Marzban Companion)
# پنل کمکی مرزبان (Marzban Companion)

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-1.0.0-green)
![Status](https://img.shields.io/badge/status-Alpha-orange)

An advanced companion panel for Marzban, designed to add **Reseller Management**, **Visual Configuration**, and a **Premium User Portal** to your existing Marzban installation.

این پروژه یک پنل پیشرفته کمکی برای مرزبان است که قابلیت‌هایی نظیر **مدیریت نمایندگان**، **تنظیمات گرافیکی** و **پرتال کاربری حرفه‌ای** را به سرور مرزبان شما اضافه می‌کند.

---

## 🚀 Features / امکانات

### 1. Advanced Reseller System (سیستم نمایندگی پیشرفته)
- 🏢 **Credit/Quota System**: Define traffic limits (e.g., 500GB) for each reseller.
- 🔒 **Ghost Access**: Resellers manage their own users without seeing the main admin panel.
- 📊 **Dedicated Dashboard**: View usage stats and active users.

### 2. Visual Configuration (تنظیمات بصری)
- 🛠 **Graphical Inbound Builder**: Create VLESS/VMess/Trojan inbounds with a wizard UI. No JSON editing required.
- 🌐 **DNS Editor**: Configure Xray DNS settings via simple forms.

### 3. User Experience (تجربه کاربری)
- 📱 **PWA User Portal**: A beautiful Glassmorphism mobile-friendly page for users to see their remaining traffic/days.
- 🔗 **Smart Subscriptions**: Optimized link generation.

---

## 🛠 Tech Stack / تکنولوژی‌ها
- **Backend**: Python (FastAPI), SQLAlchemy, SQLite (V1).
- **Frontend**: Next.js 14, TailwindCSS, Framer Motion.
- **Integration**: Direct REST API Wrapper for Marzban Core.

---

## 📦 Installation / نصب

### Prerequisites (پیش‌نیازها)
- A server with **Marzban** installed and running.
- **Python 3.8+**
- **Node.js 18+**

### Quick Start (Linux)
1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/marzban-companion.git
   cd marzban-companion
   ```

2. **Run Installer:**
   The installer will ask for your Marzban Sudo Token and setup the admin account.
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. **Start Services:**
   ```bash
   chmod +x start.sh
   ./start.sh
   ```
   - **Frontend**: `http://YOUR_SERVER_IP:3000`
   - **Backend**: `http://YOUR_SERVER_IP:7000`

---

## 📂 Project Structure / ساختار پروژه

```
.
├── backend/                 # FastAPI Application
│   ├── app/
│   │   ├── api/             # API Endpoints (Auth, Reseller, Admin)
│   │   ├── core/            # Database & Security Config
│   │   ├── models/          # Database Models (Reseller, UserMap)
│   │   └── services/        # Marzban API Wrapper
│   └── main.py              # Entry Point
├── frontend/                # Next.js Application
│   ├── app/                 # App Router Pages
│   └── components/          # UI Components
├── docs/                    # Documentation
│   ├── API_DOCUMENTATION.md
│   ├── MARZBAN_COMPREHENSIVE_GUIDE.md
│   └── DEVELOPMENT_LOG.md
├── install.sh               # Installation Script
└── start.sh                 # Startup Script
```

---

## 🤝 Contributing / مشارکت
Contributions are welcome! Please read the `docs/DEVELOPMENT_LOG.md` to understand the current progress.

---

## 📄 License
Distributed under the MIT License.
