# EduTracker Swift Mobile Application

A powerful, modern iOS/macOS application built with SwiftUI for tracking student courses and attendance. This app integrates with the EduTracker Go backend API.

## Features

### 🔐 Secure Authentication
- **Login**: Secure login with JWT token authentication.
- **Persistence**: Remembers your session so you don't have to log in every time.
- **Remember Me**: Option to save credentials for faster access.

### 👨‍🎓 Student Features
- **Course Discovery**: View all available courses.
- **Join Courses**: Easy one-tap enrollment (Joining) for courses.
- **Attendance History**: Track your participation across various courses with precise timestamps and course titles.

### 💂 Admin Features
- **User Management**: Create and manage student and administrator accounts.
- **Course Management**: Create and oversee the curriculum.
- **Attendance Tracking**: Monitor and mark attendance for any student in any course.

## Architecture

- **UI Framework**: SwiftUI
- **Concurrency**: Swift Structured Concurrency (Async/Await)
- **Networking**: URLSession with a customized `APIService` wrapper.
- **Data Persistence**: UserDefaults for session tokens and saved credentials.

## Setup Instructions

1.  **Backend Dependency**: Ensure the [EduTracker Backend](file:///home/adilet/projects/edu/EduTracker) is running locally at `http://localhost:8080`.
2.  **Open Project**: Open `EduTrackerApp.xcodeproj` in Xcode.
3.  **Run**: Select your target device (Simulators or Physical devices) and press `Cmd + R`.

## Implementation Details

- **Models**: Decodable structs mapped to backend GORM models.
- **Views**: Divided into `LoginView`, `StudentDashboard`, `AdminDashboard`, and `ProfileView`.
- **API Service**: Centralized `APIService.shared` singleton for all network requests.

---
Designed for visual excellence and premium user experience.
