# 🏠 HostelMate

> **A Complete Hostel Management System built using Flutter and Firebase**  
> Simplifying hostel life for both *students* and *administrators* with smart digital features like gatepass generation, feedback analysis, room vacancy tracking, and QR-based entry/exit.

---

## 🪄 Introduction

**HostelMate** is a modern mobile application designed to digitize and simplify hostel management.  
It provides a seamless platform for **Hostelites** and **Admins** to interact, manage records, handle complaints, monitor feedback, and process gatepasses — all in one place.

With **Flutter** for the frontend and **Firebase** for backend services, the app ensures real-time updates, cloud synchronization, and secure authentication.

---

## 💡 Problem Statement

Managing hostels manually often leads to:

- Inefficient handling of complaints, gatepasses, and feedback.
- Communication gaps between students and wardens.
- No proper record of room vacancies, payments, or daily feedback.
- Lack of automation for parent/admin approvals in gatepass systems.

---

## 🤔 Why This App Is Needed

1. **To streamline hostel operations** by replacing manual record-keeping with an automated digital solution.  
2. **To improve communication and transparency** between hostel management, parents, and students through real-time data, and digital approvals.

---

## 🚀 Features

### 👩‍🎓 For Hostelites
- **Profile Management** – Edit and update personal and academic details.  
- **Gatepass System** – Generate gatepass, send for approval, track status.  
- **Complaint Box** – Register and track complaints.  
- **Daily Feedback** – Submit daily satisfaction ratings or comments.  
- **Group Chat** – Communicate with fellow hostelites and admin.  
- **Payment Status Check** – Track hostel fee payments.  
- **QR Code for Entry/Exit** – Scan QR for secure in/out logging.

### 🧑‍💼 For Admin
- **Hostelite Management** – View, edit, and manage hostelite profiles.  
- **Complaint Resolution** – View, sort, and resolve complaints efficiently.  
- **Gatepass Approvals** – Approve or reject requests with a single click.  
- **Vacancy Analysis** – Check available rooms and bed statuses.  
- **Feedback Analysis** – Monitor daily feedback trends.  
- **Chat Integration** – Communicate with hostelites in real time.  
- **QR Scanner** – Scan student QR codes for entry and exit tracking.

---

## 🧰 Technology Stack

| Layer | Technology |
|--------|-------------|
| **Frontend** | Flutter (Dart) |
| **Backend** | Firebase Firestore |
| **Authentication** | Firebase Auth |
| **Storage** | Firebase Storage |  
| **PDF Generation** | `pdf` and `printing` Flutter packages |
| **QR Code Generation/Scanning** | `qr_flutter`, `qr_code_scanner` |
| **Version Control** | Git & GitHub |
| **Development Tools** | Android Studio |

---

## ⚙️ Installation Guide

### Prerequisites
- Flutter SDK installed  
- Android Studio or VS Code setup  
- Firebase project configured  
- Active internet connection  

### Steps
1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/HostelMate.git
   cd HostelMate
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```
3. **Set up firebase** - Add google-services.json (for Android) inside android/app/. 
4. **Run the app**
      ```bash
   flutter run
   ```
--- 

## 👥 Contributors

This project, **HostelMate**, was collaboratively built by **Vidhi Ladani** and **Harmi Kotak** — hostelites themselves — with the vision of creating a smart digital platform *by the hostelites, for the hostelites*.  
Their combined efforts focused on simplifying hostel life by integrating technology into everyday management tasks, from gatepass generation and payment tracking to feedback and complaint handling.  

---
## 💖 Support

If you like this project, consider giving it a ⭐ on GitHub!
Your support helps improve HostelMate and motivates further development.
