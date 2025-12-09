# Auxiliary Panel Version 1 (V1) Scope & Deployment Strategy
# محدوده نسخه ۱ پنل کمکی و استراتژی استقرار

## 1. Deployment Questions & Answers / پرسش و پاسخ استقرار

### Q: Can we install this script on the same server as Marzban?
**A: YES.**
- **How**: Marzban usually runs on port `8000` (Backend) and `8080` (Dashboard). Our Auxiliary Panel is a separate application (e.g., a Node.js or Python app). We can run it on a different port, like `3000` or `7000`.
- **Connection**: The Aux Panel will communicate with Marzban via `http://127.0.0.1:8000` (Localhost) internally. It acts as a wrapper.
- **Result**: You will have two panels:
    - Official Marzban Panel: `domain.com:8000` (Hidden/Private for Main Admin)
    - **New Auxiliary Panel**: `domain.com:3000` (Public for Resellers & Users)

**پاسخ:** بله. ما این پنل را روی همان سرور ولی روی یک پورت دیگر (مثلاً ۳۰۰۰) بالا می‌آوریم. این پنل به صورت داخلی با مرزبان صحبت می‌کند.

---

## 2. V1 Feature List / لیست قابلیت‌های نسخه یک

### A. Authentication & Roles (احراز هویت و نقش‌ها)
1.  **Main SuperAdmin**:
    - Full access to all settings, all users, and all resellers.
    - Ability to define/edit Resellers and their limits.
2.  **Reseller (Dedicated Portal)**:
    - **Dedicated Login Page**: Resellers log in via the Aux Panel URL.
    - **Dashboard**: Sees *only* their own users and their remaining credit/quota.
    - **User Management**:
        - Create User (deducts from quota).
        - View User Usage (Live stats).
        - Renew/Delete *their own* users.
    - **Link Generation**: Can generate sub links for their users.
    - **Protection**: Cannot see system configs, nodes, or other resellers' data.

### B. Visual Configuration (تنظیمات گرافیکی)
*Yes, we will implement these graphically to avoid editing JSON files.*

3.  **Graphical DNS Editor**:
    - A simple form to set Remote DNS and Local DNS.
    - Dropdown for Strategy (`UseIP`, `AsIs`).
    - "Save & Apply" button (Triggering Core Restart).
4.  **Visual Inbound Builder**:
    - **Step-by-Step Wizard**:
        - Step 1: Protocol (VMess, VLESS, Trojan).
        - Step 2: Transport (TCP, WS, GRPC).
        - Step 3: Security (TLS, Reality, None).
        - Step 4: Port Selection (Visual grid or Auto-assign).
    - **Validation**: Prevents creating duplicate ports.

### C. Client & Subscription Experience (تجربه کاربر و ساب)
5.  **Beautiful User Portal (PWA)**:
    - A specific URL for end-users (e.g., `/my-subscription/{token}`).
    - **Design**: Glassmorphism, Premium Dark UI.
    - **Stats**: Visual circle charts for "Data Used" and "Days Left".
    - **QR Code**: One-click copy/scan.
    - **Tutorials**: Simple tabs for "Android", "iOS", "Windows" setup.

### D. System Management (مدیریت سیستم)
6.  **Node Health Monitor**: Simple Green/Red status lights for connected nodes.
7.  **Backup/Restore**: One-click download of the Marzban DB.

---

## 3. Technical Architecture for V1 / معماری فنی نسخه یک

-   **Backend**: Python (FastAPI) - Lightweight, fast, and easy to integrate with Marzban's python code if needed.
-   **Frontend**: React (Next.js) - For that "Premium" static site feel and rich animations.
-   **Database**: SQLite (built-in) or PostgreSQL. SQLite is easiest for V1 to manage Reseller Quotas without complex setup.
-   **Integration**: The Aux Panel backend holds the `Sudo Token` for Marzban. When a Reseller acts, the Aux Backend verifies permission, then calls Marzban using the Sudo Token.

## 4. Development Steps / مراحل توسعه
1.  **Setup**: Initialize Repo, React Frontend, Python Backend.
2.  **Auth Module**: Create Reseller DB table and Login Logic.
3.  **Wrapper Module**: Implement the "Bridge" functions to call Marzban API.
4.  **UI Construction**: Build the Glass-morphism Dashboard.
5.  **Visual Config Logic**: Implement the JSON parsers for DNS and Inbounds.
6.  **Testing**: Install on a test server alongside Marzban.
