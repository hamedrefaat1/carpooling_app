# 🚗 Hopin – Carpooling App  

**Aug 2025 – Sep 2025**

🚦 **A Smart Ride-Sharing Solution for Cairo**

With over **22 million residents** and **25+ million daily trips daily**, Cairo faces severe traffic congestion, rising fuel costs, and environmental challenges.  
Most vehicles carry only one passenger while many others are heading in the same direction.

**Hopin** transforms solo rides into shared journeys — reducing costs, congestion, and emissions through real-time carpooling.

---

## 💡 Real-Life Scenario

Mohamed wants to travel from **Maadi to Cairo University**.  
An Uber would normally cost him **60 EGP**.

At the same time, Ahmed is already driving his car toward the same destination.

Using **Hopin**:

1. Ahmed creates a trip and goes online.
2. Mohamed finds the trip nearby.
3. He sends a join request.
4. Ahmed accepts.

💰 Mohamed pays **30 EGP instead of 60**  
🚗 Ahmed earns extra income on his regular route  
🌱 One car instead of two → less traffic & lower emissions  

That’s the power of smart carpooling.

---

# ✨ Key Features

- 🔐 **Authentication** (Email/Password, Phone, Google Sign-in)
- 🚗 **Trip Management** (Create / Update / Delete Trips)
- 👥 **Ride Requests System**
- 📍 **Live Location Tracking** (Mapbox SDK)
- 🔔 **Push Notifications** (Firebase Cloud Messaging)
- 🎨 **Modern UI** (Light & Dark Mode)
- ⚡ **Real-time Sync** (Firebase Firestore)

---

# 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Auth, Firestore, Cloud Messaging)
- **Maps:** Mapbox API
- **State Management:** Cubit (Bloc)
- **Architecture:** Clean Architecture (Feature-Based Structure)

---

# 📱 App Preview

## 👤 Rider Experience

<p align="center">
  <img src="screenshots/splash.jpg" width="230"/>
  <img src="screenshots/rider_home.jpg" width="230"/>
  <img src="screenshots/rider_requests.jpg" width="230"/>
  <img src="screenshots/rider_profile.jpg" width="230"/>
  <img src="screenshots/rider_can_send_request_join.jpg" width="230"/>
</p>

---

## 🚗 Driver Experience

<p align="center">
  <img src="screenshots/driver_home.jpg" width="230"/>
  <img src="screenshots/driver_trips.jpg" width="230"/>
  <img src="screenshots/driver_active_trip.jpg" width="230"/>
  <img src="screenshots/driver_profile.jpg" width="230"/>
</p>

---

## 💬 Communication & Trip Flow

<p align="center">
  <img src="screenshots/chat.jpg" width="230"/>
  <img src="screenshots/chatII.jpg" width="230"/>
  <img src="screenshots/driver_trip_request_join.jpg" width="230"/>
  <img src="screenshots/line_to_distention.jpg" width="230"/>
  <img src="screenshots/notifications.jpg" width="230"/>
</p>

---

## 📂 More Screens

Additional application screens are available inside the `screenshots` folder.

---

# 🖼️ System Design

## 📌 Data Flow Diagrams

### Level 0
![Context DFD](system_design/DFD/context_dfd.png)

### Level 1
![DFD Level 1](system_design/DFD/dfd_level1.png)

---

## 📌 Use Case Diagram
![Use Case](system_design/Use_Case/use_case_diagram.png)

---

# 🌍 Expected Impact

If only **20% of Cairo’s low-occupancy trips** were shared:

- 🚘 ~950,000 fewer cars daily  
- ⛽ Millions of liters of fuel saved monthly  
- 🌱 Significant reduction in congestion & carbon emissions  

---

# 🚀 Getting Started

## Prerequisites

- Flutter SDK (latest stable)
- Firebase Project (Auth, Firestore, FCM)
- Mapbox API Key

---

## Installation

```bash
git clone https://github.com/hamedrefaat1/carpooling_app.git
cd carpooling_app
flutter pub get
flutter run
