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
  - Supabase Auth (Anonymous authentication)

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
  (reduces friction during emergencies)
- Admin access for moderation and monitoring

---

## 👤 Admin Credentials (For Evaluation)

> **Admin Email:** `ayinalasrinikesh@gmail.com`  
> **Password:** `Srinikesh`

⚠️ These credentials are provided **only for hackathon evaluation**.

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
