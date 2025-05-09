# 📝 todo_async App (Flutter + Firebase + Custom Async Queue)

This Flutter app allows users to add tasks locally and upload them to Firebase Firestore **after a delay**, using a **custom-built asynchronous task queue** — without relying on any external queue libraries.

---

## 🚀 Objective

Build a todo_async app where tasks can be queued and uploaded to Firebase asynchronously, simulating delayed sync while maintaining a responsive UI.

---

## 🔑 Key Features

### 1. **Firebase Authentication**
- Email/Password login (no sign-up).
- Once logged in, the user's email is shown on the dashboard.

### 2. **Task Creator Screen**
- Input form for task title and description.
- "Add Task" button:
  - Adds the task to a **local in-memory queue**.
  - Marks it with `Queued` status.

### 3. **Custom Asynchronous Queue Processor**
- Tasks are processed **one by one** with a **delay (5 seconds)**.
- Each task is uploaded to Firebase Firestore under the logged-in user's collection.
- If a Firebase write fails, the task is retried up to **3 times**.
- Success removes it from the local queue and marks it as `Uploaded`.

### 4. **Task Dashboard**
- Shows a **real-time list** of tasks from Firestore.
- Also displays **locally queued tasks** immediately.
- Tasks are labeled as `Queued` (local) or `Uploaded` (cloud).

### 5. **Routing with GoRouter**
| Route        | Screen         |
|--------------|----------------|
| `/login`     | Login Screen   |
| `/dashboard` | Task Dashboard |
| `/add`       | Task Creator   |

---

## 🧠 Queue Logic (Core Flow)

1. User creates a task via `/add`.
2. The task is:
   - Given a unique ID.
   - Marked with `status = queued`.
   - Added to a **custom queue class** (`AsyncTaskQueue`).
   - Stored in a local list (`_localQueuedTasks`) to show in UI immediately.
3. The queue:
   - Waits 5 seconds.
   - Uploads the task to Firebase Firestore.
   - On success: removes task from local queue and marks it as `uploaded`.
   - On failure: retries up to 3 times.

---
## 🧱 Folder Structure

```plaintext

lib/
│
├── bloc/                     # State management using Bloc
│   ├── auth/                 # Auth Bloc files
│   │   ├── auth_bloc.dart
│   │   ├── auth_event.dart
│   │   └── auth_state.dart
│   │
│   └── task/                 # Task Bloc files
│       ├── task_bloc.dart
│       ├── task_event.dart
│       └── task_state.dart
│
├── data/                     # Core logic and repositories
│   ├── async_queue.dart      # Custom async task queue processor
│   ├── auth_repository.dart  # Firebase Auth operations
│   └── task_repository.dart  # Firestore task upload logic
│
├── models/
│   └── task_model.dart       # Task data model
│
├── ui/                       # UI screens
│   ├── add_task_screen.dart
│   ├── dashboard_screen.dart
│   └── login_page.dart
│
├── app_router.dart           # GoRouter setup
├── firebase_options.dart     # Firebase config
└── main.dart                 # App entry point
