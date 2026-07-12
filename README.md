# Cogniq

> **An AI-powered cognitive safety assistant that detects wandering behavior and intelligently assists caregivers.**

## 📖 Overview

Cogniq is an offline-first AI-powered mobile application designed to help people with dementia, Alzheimer's, autism, and other cognitive impairments who are at risk of wandering.

Unlike traditional GPS trackers, Cogniq doesn't just track location—it understands routines, movement patterns, and contextual behavior using AI. When unusual behavior is detected, the app first communicates with the user through voice guidance. If the situation becomes risky, it alerts the designated guardian with contextual information and live location.

---

# ✨ Features

- 🧠 AI-powered wandering detection
- 📍 Live GPS tracking
- 🗺️ Safe Zone Monitoring
- 🤖 Context-aware risk analysis
- 🎙️ Urdu Voice Guidance
- 🔔 Guardian Notifications
- 📱 SMS & Call Fallback
- 🌐 Offline-first Architecture
- 🔒 Privacy-focused Design

---

# 🛠 Tech Stack

## Frontend
- Flutter
- Dart

## AI
- Google Gemma API
- Prompt Engineering

## Backend
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging (FCM)

## Maps & Location
- OpenStreetMap
- flutter_map
- Geolocator

## Local Storage
- Hive

## Voice
- Flutter TTS

## Notifications
- Firebase Push Notifications
- SMS
- Phone Call

---

# 👥 Team Roles

## 👨‍💻 Frontend Developer

Responsible for building the complete mobile application UI.

### Tasks
- Flutter UI
- Navigation
- Dashboard
- Profile
- Monitoring Screen
- Settings
- Reusable Components
- API Integration

---

## 🤖 AI Engineer

Responsible for building the AI reasoning system.

### Tasks
- Gemma API Integration
- Prompt Engineering
- Context Builder
- AI Response Parsing
- Risk Analysis
- Decision Engine

---

## 📍 Location & Maps Engineer

Responsible for movement tracking and location intelligence.

### Tasks
- GPS Tracking
- Background Location
- OpenStreetMap Integration
- Safe Zone Detection
- Movement Analysis
- Route Monitoring

---

## ☁️ Backend Engineer

Responsible for cloud services and communication.

### Tasks
- Firebase Authentication
- Firestore Database
- Hive Models
- Push Notifications
- SMS Fallback
- Guardian Alerts
- API Integration

---

# 🔄 Application Workflow

```
User Opens App
        │
        ▼
GPS collects location
        │
        ▼
Routine + Safe Zones + History
        │
        ▼
Context Builder
        │
        ▼
Gemma AI
        │
        ▼
Risk Analysis
        │
        ▼
Decision Engine
        │
        ├───────────────┐
        │               │
     Low Risk      Medium Risk
        │               │
     Continue      Voice Guidance
        │               │
        └───────────────┘
                │
                ▼
           High Risk
                │
                ▼
         Alert Manager
                │
        ┌───────┴────────┐
        │                │
   Internet          No Internet
        │                │
        ▼                ▼
 Push Notification      SMS
        │                │
        └───────┬────────┘
                ▼
           Phone Call
```

---

# 🚀 Development Workflow

### Phase 1
- Design UI
- Create Database Models
- Setup Firebase
- Define AI Prompts

### Phase 2
- Build UI with Dummy Data
- Implement GPS
- Integrate Gemma
- Build Backend

### Phase 3
- Connect UI with Backend
- Connect AI with GPS
- Connect Alert System

### Phase 4
- Testing
- Bug Fixes
- Final Demo

---

# 📂 Suggested Folder Structure

```
lib/
│
├── models/
├── screens/
├── widgets/
├── services/
│   ├── ai_service.dart
│   ├── location_service.dart
│   ├── notification_service.dart
│   ├── auth_service.dart
│   └── decision_engine.dart
│
├── repositories/
├── utils/
└── main.dart
```

---

# 🎯 Future Improvements

- Offline Gemma Model
- Wearable Device Support
- Fall Detection
- Smartwatch Integration
- Health Sensor Integration
- Multi-language Support
- Battery Optimization

---

# 📄 License

This project was developed for a hackathon and is intended as a proof of concept.

---

**Built with ❤️ using Flutter, Firebase, and Google Gemma .**