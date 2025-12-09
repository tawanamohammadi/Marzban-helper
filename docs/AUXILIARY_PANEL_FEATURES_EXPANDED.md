# Auxiliary Panel Features & Expansion Strategy (V2)
# ویژگی‌های پنل کمکی و استراتژی توسعه (نسخه ۲)

This document expands on the initial guide, focusing on specific requested features and proposing new advanced capabilities for the Marzban Auxiliary Panel.
این سند گسترشی بر راهنمای اولیه است که بر ویژگی‌های درخواستی خاص تمرکز دارد و قابلیت‌های پیشرفته جدیدی را برای پنل کمکی مرزبان پیشنهاد می‌کند.

---

## 1. Requested Features Detailed Analysis / تحلیل دقیق ویژگی‌های درخواستی

### A. Advanced Reseller System (مدیریت نمایندگی پیشرفته)
*   **Challenge**: Marzban's native admins have broad permissions.
*   **Solution**: A "Credit-Based" Reseller System in the Auxiliary Panel.
*   **Mechanism**:
    1.  **Quota/Wallet**: Assign a specific limit (e.g., 500GB or $50) to a Reseller in the Aux DB.
    2.  **Allocated Users**: When a Reseller creates a user via Aux Panel, the panel validates credit first.
    3.  **Ghost Access**: The Reseller never sees the main Marzban credential. The Aux Panel acts as a middleware, making API calls to Marzban on their behalf.
    4.  **Sub-Admin Bind**: You can bind a Reseller to specific `Inbounds` or `Nodes` so they can only sell servers you allow.

### B. Graphical DNS Server Configuration (تنظیم گرافیکی سرور DNS)
*   **Constraint**: DNS settings in Marzban are part of the Xray Core Config (`config.json`), which is complex JSON.
*   **Implementation**:
    1.  **UI**: A form with fields like "Remote DNS", "Local DNS", "Strategy" (AsIs, UseIP, etc.).
    2.  **Logic**: Fetch current config via `GET /api/core/config`.
    3.  **Parser**: Locate the `"dns"` object in the Xray config.
    4.  **Write**: Update the JSON object and push back via `PUT /api/core/config`.
    5.  **Restart**: Auto-call `POST /api/core/restart` to apply.

### C. Visual Inbound Management (اضافه کردن گرافیکی اینباند)
*   **Goal**: Avoid writing raw JSON for protocols like VLESS, VMESS, Trojan.
*   **Implementation**:
    1.  **Wizard UI**: Select Protocol (e.g., VLESS) -> Select Transport (TCP/WS/GRPC) -> Select Security (Reality/TLS).
    2.  **Validation**: Ensure ports don't overlap with existing Inbounds (checked against `GET /api/inbounds`).
    3.  **Snippet Generation**: The panel generates the correct Xray Inbound JSON block.
    4.  **Injection**: Inject this block into the `inbounds` array in the core config and push update.

### D. Subscription Link Sorting & Optimization (مرتب‌سازی سابسکریپشن)
*   **The Problem**: Marzban returns links in a default order. Users often want the "Best Pings" or "Auto" at the top.
*   **The Fix**: **Proxy Subscription Layer**.
*   **How it works**:
    1.  User is given a link to `https://aux-panel.com/sub/{token}` instead of the direct Marzban link.
    2.  When the User's app fetches this URL:
        *   Aux Panel fetches raw configs from Marzban (`GET /sub/{token}/info`).
        *   **Processor Engine**: Parses the configs, renames them (e.g., adds flags 🇮🇷 🇩🇪), sorts them by priority (e.g., "Auto-Select" first), and removes broken nodes.
        *   Aux Panel returns the *polished* list to the User's app.

### E. Beautiful Subscription Page (Client Portal) / صفحه ساب زیبا
*   **Concept**: A dedicated Web App (PWA) for users to view their status.
*   **Features**:
    *   **Modern UI**: Glassmorphism/Dark Mode (as per your design guidelines).
    *   **QR Codes**: Interactive QR codes for easy scanning.
    *   **Live Charts**: Usage history graphs (using `GET /api/user/{username}/usage`).
    *   **Tutorials**: "How to connect" guides embedded based on User's OS (detected via User-Agent).
    *   **Pay & Renew**: Integrated payment button to extend the plan immediately.

---

## 2. "What Else?" - New Suggestions / پیشنهادات جدید

### F. Smart Routing Generator (Geo-Routing Wizard)
*   **Idea**: Easily split domestic (Iran) vs International traffic.
*   **Feature**: A map-based interface to select countries to "Block" or "Direct".
*   **Tech**: Generates complex `routing` rules in Xray config automatically (e.g., `geoip:ir` -> direct).

### G. Real-time Node Health & Auto-Failover (سلامت‌سنج و انتقال خودکار)
*   **Idea**: Validating nodes is hard for users.
*   **Feature**: The Aux Panel periodically pings all Nodes.
*   **Action**: If "Node A" has >50% packet loss:
    *   Remove "Node A" from the **Proxy Subscription Layer** (User apps stop seeing it on next update).
    *   Send alert to Admin.

### H. Multi-Protocol Conversion (Sing-box/Clash)
*   **Idea**: Marzban supports standard Xray. Many users use Sing-box or Clash.
*   **Feature**: Built-in Converter.
*   **Action**: The Subscription Endpoint detects the client (e.g., `Clash.Meta`) and automatically converts the Xray JSON to Clash YAML format on the fly.

### I. Telegram Bot 2.0 (User Integration)
*   **Idea**: Users live in Telegram.
*   **Feature**: a Bot linked to the Aux Panel.
*   **Capabilities**:
    *   User sends `/status` -> Bot replies with formatting usage image.
    *   User sends `/renew` -> Bot sends Payment Link -> User pays -> Bot calls API to `reset` or `extend` user.

### J. Bulk Port Management (مدیریت پورت گروهی)
*   **Idea**: Managing hundreds of inbounds is messy.
*   **Feature**: Visual Port Map.
*   **UI**: shows a grid of ports (10000-20000). Red = Used, Green = Free. Click to assign to a new Inbound.

---

## 3. Recommended Tech Stack for Aux Panel / تکنولوژی پیشنهادی

Since you need **High Graphics** and **Premium Design**:

*   **Frontend**: Next.js (React) + Framer Motion (Animations) + Glass UI.
*   **Backend**: Python (FastAPI) or Node.js (NestJS). Ideally Python to share logic easily with Marzban clients.
*   **Database**: PostgreSQL (for checking Reseller quotas, transactions, and logs).
*   **Communication**: Rest API (consuming Marzban endpoints).

---

Please confirm which of these new modules (F to J) you would like to prioritize for the Development Roadmap.
لطفاً تأیید کنید کدام یک از این ماژول‌های جدید (F تا J) را می‌خواهید در نقشه راه توسعه اولویت‌بندی کنیم.
