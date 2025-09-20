# 🚗 Carpooling App

Carpooling App is a **Flutter-based mobile application** that connects drivers and passengers to share rides easily and efficiently.  
It helps reduce travel costs, minimize traffic, and promote eco-friendly transportation by enabling ride-sharing in real time.

---

## ✨ Features

- 🔐 **Authentication**
  - Firebase Authentication (Email/Password, Phone Number, Google Sign-in)
- 🧑‍🤝‍🧑 **User Roles**
  - Driver: Create and manage trips
  - Passenger: Browse and join trips
- 📍 **Live Location**
  - Track driver and passenger location on Google Maps
- 📅 **Trip Management**
  - Drivers can create, update, and delete trips
  - Passengers can request to join trips
- 🔔 **Push Notifications**
  - Powered by Firebase Cloud Messaging (FCM)
- 🎨 **Modern UI**
  - Light/Dark mode support
  - Custom themes
- ⚡ **Real-time Updates**
  - Integrated with Firebase Firestore for instant data sync

---

## 🛠️ Tech Stack

- **Frontend:** [Flutter](https://flutter.dev/) (Dart)
- **Backend:** [Firebase](https://firebase.google.com/)  
  - Authentication  
  - Firestore Database  
  - Firebase Cloud Messaging  
- **Maps:** Google Maps SDK
- **State Management:** Cubit (Bloc)

---

## 📱 Screenshots

> Add your app screenshots here for better presentation.  
Example:

| Home Screen | Trip Details | Requests |
|-------------|--------------|----------|
| ![Home](docs/screenshots/home.png) | ![Trip](docs/screenshots/trip.png) | ![Requests](docs/screenshots/requests.png) |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Firebase project setup (with Firestore & FCM enabled)
- Google Maps API key

### Installation

1. Clone the repo:
   ```bash
   git clone https://github.com/hamedrefaat1/carpooling_app.git
   cd carpooling_app
