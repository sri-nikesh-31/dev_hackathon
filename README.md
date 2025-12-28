# 🚨 Rapid Response – Real-Time Incident Reporting Platform

Rapid Response is a **mobile-first, real-time incident reporting application** built during a hackathon.  
It enables citizens to report emergencies quickly and allows responders/admins to monitor, verify, and prioritize incidents efficiently.

---

## 📌 Problem Statement

During emergencies such as:
- Road accidents
- Medical crises
- Fires
- Public safety incidents  

valuable time is lost due to:
- Fragmented reporting systems
- Lack of real-time visibility
- Duplicate or false reports
- Poor coordination between citizens and responders

---

## 💡 Proposed Solution

Rapid Response provides:
- A **single platform** for citizens to report incidents
- **Real-time incident feed** for visibility
- **Community-based verification** using upvotes
- A backend designed for **scalability and live updates**

The goal is to **reduce response time** and **improve coordination** during critical situations.

---

## 🛠️ Technologies Used

### Frontend
- **Flutter** (Android-first, cross-platform)

### Backend
- **Supabase**
  - PostgreSQL (Database)
  - Supabase Realtime (Live updates)
  - Supabase Storage (Image uploads)
  - Supabase Auth (Authentication)

### Other Libraries
- `geolocator` – Location access
- `image_picker` – Camera image capture

---

## ⚙️ Core Features

- 📍 Incident reporting with:
  - Type (Accident, Medical, Fire, etc.)
  - Description
  - Live location
  - Optional image
- 🔄 Live incident feed with real-time updates
- ✅ Community verification via upvotes
- 🚦 Severity indication based on verification
- 🧑‍🚒 Admin/responder moderation capability
- ☁️ Cloud-hosted, publicly accessible backend

---

## 🔐 Authentication Model

- **Anonymous authentication** for citizens  
  (minimizes friction during emergency reporting)
- **Email-based authentication** for admin users

---

## 📧 Email Confirmation (Important)

During **admin registration**, Supabase sends a **confirmation email**.

### Registration flow:
1. Register using email and password
2. A **confirmation link** is sent to the registered email
3. Open the email and **click the confirmation link**
4. Reload the webpage
5. Return to the app
6. **Reload / reopen the app**
7. Proceed with login

⚠️ Login will not succeed until the email is confirmed.

This design ensures:
- Valid email ownership
- Secure admin access
- Prevention of fake admin accounts

---

## 👤 Admin Credentials (For Evaluation)

> **Admin Email:** `ayinalasrinikesh@gmail.com`  
> **Password:** `Srinikesh`

⚠️ These credentials are provided **only for hackathon evaluation**.

If prompted for email verification, please complete the confirmation once and then reload the app.

---

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK
- Android SDK
- A physical Android device or emulator

### Clone the repository
```bash
git clone https://github.com/sri-nikesh-31/dev_hackathon.git
cd dev_hackathon
