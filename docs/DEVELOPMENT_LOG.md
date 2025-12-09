# Development Log - Marzban Auxiliary Panel
# لاگ توسعه - پنل کمکی مرزبان

This document records the automated actions and development steps taken by the AI Agent.
این سند اقدامات خودکار و مراحل توسعه انجام شده توسط ایجنت هوش مصنوعی را ثبت می‌کند.

## Session: Project Initialization
**Date**: 2025-12-10

### Actions Taken:
1.  **Documentation Organization**:
    - Created `docs/` directory.
    - Moved all documentation files to `docs/`.

2.  **Project Structure Setup**:
    - Initialized Git repository.
    - Created `backend/` directory (FastAPI).
    - Created `frontend/` directory (Next.js).

3.  **Backend Implementation**:
    - Modeled `Reseller` and `UserMap` in SQLAlchemy.
    - Implemented JWT Authentication (`/api/auth/token`).
    - Implemented Marzban API Wrapper (`services/marzban_api.py`).
    - Implemented Reseller logic (Quota check, User creation).
    - Created `create_admin.py` to seed the first user.

4.  **Frontend Initialization**:
    - Created `package.json` for Next.js 14.
    - Setup Tailwind CSS and Glassmorphism styles (`globals.css`).
    - Created Landing Page.

5.  **Deployment Scripts**:
    - Created `install.sh` (Interactive).
    - Created `start.sh`.

### Current Status
The project V1 foundation is complete. The Backend API is functional (logic-wise), and the Frontend structure is ready for UI component development.

### Next Steps:
- Build the Frontend "Reseller Dashboard" page.
- Build the "Visual Inbound Builder" UI.
- Test endpoint integration.
