# Marzban Comprehensive API Guide & Auxiliary Panel Strategy
# راهنمای جامع API مرزبان و استراتژی پنل کمکی

---

## 1. Introduction / مقدمه

**English:**
This document serves as a comprehensive reference for the Marzban API, designed for both **AI Agents** (technical precision, strict schemas) and **Human Developers** (conceptual understanding, actionable insights). It aggregates data extracted directly from the Marzban source code and client libraries.

**فارسی:**
این سند به عنوان یک مرجع کامل برای API مرزبان عمل می‌کند که برای استفاده **ایجنت‌های هوش مصنوعی** (دقت فنی، اسکیم‌های دقیق) و **توسعه‌دهندگان انسانی** (درک مفهومی، بینش‌های اجرایی) طراحی شده است. این اطلاعات مستقیماً از کد منبع مرزبان و کتابخانه‌های کلاینت آن استخراج شده است.

---

## 2. Technical Core / هسته فنی

| Feature | Details |
| :--- | :--- |
| **Protocol** | HTTP/1.1 (RESTful) |
| **Authentication** | OAuth2 Password Bearer (JWT) |
| **Data Format** | JSON (`application/json`) |
| **Default Port** | `8000` |
| **Base Path** | `/api/` |

### Authentication Flow / جریان احراز هویت

**Human Explanation:**
First, you must log in using a superadmin username/password to get a `token`. This token must be sent in the header of all future requests.
**شرح برای انسان:**
ابتدا باید با نام کاربری و رمز عبور مدیر کل لاگین کنید تا یک `token` دریافت کنید. این توکن باید در هدر تمام درخواست‌های بعدی ارسال شود.

**AI Specification:**
- **Endpoint**: `POST /api/admin/token`
- **Header**: `Content-Type: application/x-www-form-urlencoded`
- **Body Schema**:
  ```json
  {
    "username": "str",
    "password": "str",
    "grant_type": "password"
  }
  ```
- **Response**: `{"access_token": "str", "token_type": "bearer"}`
- **Usage**: Add header `Authorization: Bearer <access_token>` to requests.

---

## 3. Categorized API Reference / مرجع دسته‌بندی شده API

### A. User Management / مدیریت کاربران
*Control user accounts, limits, and subscriptions.*

#### 1. Create User (ساخت کاربر)
- **Method**: `POST`
- **Path**: `/api/user`
- **Description (EN)**: Creates a new user with specific traffic/expiry limits.
- **Description (FA)**: کاربر جدیدی با محدودیت‌های ترافیک و زمانی مشخص ایجاد می‌کند.
- **Payload (UserCreate)**:
  ```json
  {
    "username": "str (required)",
    "proxies": { "proxy_type": { "id": "uuid", "flow": "str" } },
    "expire": "int (epoch timestamp, optional)",
    "data_limit": "int (bytes, default 0 for unlimited)",
    "data_limit_reset_strategy": "str (no_reset, day, week, month, year)",
    "status": "active (default) | on_hold",
    "note": "str (optional)",
    "on_hold_timeout": "str (ISO8601, optional)",
    "on_hold_expire_duration": "int (seconds, optional)"
  }
  ```

#### 2. Modify User (ویرایش کاربر)
- **Method**: `PUT`
- **Path**: `/api/user/{username}`
- **Description (EN)**: Updates settings. Only send fields you want to change.
- **Description (FA)**: تنظیمات را به روز می‌کند. تنها فیلدهایی که قصد تغییر دارید ارسال کنید.
- **Payload**: Same as Create User but all fields optional.

#### 3. User Actions (عملیات روی کاربر)
- **Reset Usage / بازنشانی مصرف**: `POST /api/user/{username}/reset`
- **Revoke Subscription / ابطال لینک اشتراک**: `POST /api/user/{username}/revoke_sub`
  - *Generates a new subscription URL/token.*
- **Activate Next Plan / فعال‌سازی پلن بعدی**: `POST /api/user/{username}/active-next`
- **Delete / حذف**: `DELETE /api/user/{username}`

#### 4. Get User Usage (دریافت ریز مصرف)
- **Method**: `GET`
- **Path**: `/api/user/{username}/usage`
- **Params**: `start` (ISO date), `end` (ISO date)

---

### B. Admin Management / مدیریت مدیران
*Manage access for sub-admins or the main panel owner.*

#### 1. Create Admin (ساخت مدیر)
- **Method**: `POST`
- **Path**: `/api/admin`
- **Payload**:
  ```json
  {
    "username": "str",
    "password": "str",
    "is_sudo": "bool (Full access if true)",
    "telegram_id": "int (Optional for bot integration)",
    "discord_webhook": "str (Optional for logs)"
  }
  ```

#### 2. Managerial Actions (عملیات مدیریتی)
- **Disable All Users of Admin**: `POST /api/admin/{username}/users/disable`
- **Activate All Users of Admin**: `POST /api/admin/{username}/users/activate`

---

### C. System & Nodes / سیستم و نودها
*Monitor health and manage multi-server architecture.*

#### 1. System Stats (آمار سیستم)
- **Method**: `GET`
- **Path**: `/api/system`
- **Returns**: Memory usage, CPU usage, Total/Active users, Real-time bandwidth speeds.

#### 2. Node Management (مدیریت نودها)
- **Add Node**: `POST /api/node`
  - Payload:
    ```json
    {
      "name": "str",
      "address": "IP/Domain",
      "port": 62050,
      "api_port": 62051,
      "usage_coefficient": 1.0 (multiplier for traffic counting)
    }
    ```
- **Reconnect Node**: `POST /api/node/{id}/reconnect`

---

## 4. Auxiliary Panel Capability Strategy / استراتژی قابلیت‌های پنل کمکی

We aim to create an "Auxiliary Panel" (Panel-e Komaki). Based on the API analysis, here are the **High-Value Capabilities** we can implement that Marzban core might lack or handle simply.

ما قصد داریم یک "پنل کمکی" بسازیم. بر اساس تحلیل API، این‌ها **قابلیت‌های ارزشمندی** هستند که می‌توانیم پیاده‌سازی کنیم (مواردی که خود مرزبان ممکن است ساده رد شده باشد):

### 1. Advanced Billing & Accounting (سیستم حسابداری پیشرفته)
*   **Gap**: Marzban handles limits (Expire/Data) but not "Money".
*   **Feature**: Include a wallet system. When `POST /api/user` is called, deduct credit from the Admin's wallet.
*   **Implementation**:
    *   Map `data_limit` + `expire` duration to a Price.
    *   Use `note` field in User object to store "Order ID" or "Payment Ref".
    *   API Hook: Create users only after payment verification.

### 2. Smart User Lifecycle Automation (اتوماسیون چرخه کاربران)
*   **Gap**: Marzban has `on_hold` and `expired`, but limited logic for "Reminders".
*   **Feature**: Automated Notifications.
*   **Implementation**:
    *   Poll `GET /api/users` periodically.
    *   Check `data_limit - used_traffic` and `expire - current_time`.
    *   If user < 10% data or < 3 days remaining -> User `telegram_id` (stored in DB map) -> Send Alert via Bot.

### 3. Template-Based Bulk Generation (تولید انبوه با قالب)
*   **Gap**: Creating 100 users requires 100 API calls manually.
*   **Feature**: Bulk Generator UI.
*   **Implementation**:
    *   UI: Select "1 Month, 50GB Template".
    *   Input: "Number to generate: 50".
    *   Loop: Call `POST /api/user` 50 times with incremental usernames (user_01, user_02...).
    *   Output: Export all Subscription Links to Excel/TXT.

### 4. Reseller Sub-System (زیرسیستم نمایندگی)
*   **Gap**: Marzban `Admin` is powerful, but you might want strictly limited resellers (e.g., "Can only sell 500GB total").
*   **Feature**: Quota Management Layer.
*   **Implementation**:
    *   The Auxiliary Panel acts as the "Proxy" to the Marzban API.
    *   Reseller logs into Aux Panel.
    *   Aux Panel checks Reseller's internal quota.
    *   If quota > 0 -> Aux Panel calls Marzban `POST /api/user`.

### 5. Multi-Server Node Balancer / Visualizer (مدیریت بصری نودها)
*   **Gap**: Marzban lists nodes.
*   **Feature**: Visual Health Map.
*   **Implementation**:
    *   Call `GET /api/nodes` and `GET /api/system`.
    *   Calculate "Health Score" based on `uplink`, `downlink`, and connectivity.
    *   Show a map/graph: "Node Germany is congested (High Load), move new users to Node Turkey".

### 6. Client Configuration Converter (مبدل کانفیگ کلاینت)
*   **Gap**: Users often want specific formats (Clash, Surfboard, Sing-box).
*   **Feature**: Universal sub converter.
*   **Implementation**:
    *   Use `GET /sub/{token}/info` to get raw configs.
    *   Process string locally to generate format-specific JSON/YAML for diverse clients if Marzban's native support is insufficient for specific apps.

---

## 5. Agent Instructions / دستورالعمل‌های ایجنت

**To the coding Agent:**
1.  **Strict Typing**: Always enforce the types found in `models.py` (e.g., specific Enum values for `status`). marzban will reject invalid Enums.
2.  **Error Handling**: Marzban returns `HTTPValidationError` (422) often if schemas miss-match. Always wrap API calls in `try/except` blocks parsing the 422 JSON body.
3.  **Token Refresh**: Tokens do not auto-refresh. You likely need to re-login (`POST /api/admin/token`) if you receive a 401 Unauthorized.

**برای ایجنت برنامه‌نویس:**
۱. **تایپ دقیق**: همیشه تایپ‌های یافت شده در `models.py` را رعایت کنید (مانند مقادیر Enum برای `status`). مرزبان مقادیر نامعتبر را رد می‌کند.
۲. **مدیریت خطا**: مرزبان اغلب خطای `HTTPValidationError` (422) را در صورت عدم تطابق اسکیم برمی‌گرداند. همیشه فراخوانی‌های API را در بلوک `try/except` قرار دهید و بدنه JSON خطای 422 را پارس کنید.
۳. **رفرش توکن**: توکن‌ها به خودی خود رفرش نمی‌شوند. اگر خطای 401 دریافت کردید، باید مجدداً لاگین کنید.
