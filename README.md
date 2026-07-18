# Flutter Palindrome Checker & User List App

A Flutter application built with **Clean Architecture** and **Bloc** state management. It features a Palindrome Checker utility and an API-driven User List with pagination, pull-to-refresh, and comprehensive state handling.

## 🚀 Tech Stack
- **Framework**: Flutter SDK 3.32+
- **State Management**: `flutter_bloc`
- **Architecture**: Clean Architecture (Feature-Based)
- **Dependency Injection**: `get_it`
- **Network**: `http`
- **Image Caching**: `cached_network_image`
- **Testing**: `bloc_test`, `mocktail`

## 🛠️ How to Run the Project

This project uses `--dart-define` to securely pass the API Key (`x-api-key`) without hardcoding it into the source code.

### Option 1: Running WITHOUT an API Key (Recommended for Testing)
Since the `reqres.in` API is fully public and does not actually require an API Key, you can run the app naturally without any extra arguments. The app is smart enough to handle empty API Keys and will skip sending the custom header (preventing `401 Unauthorized` errors).

```bash
flutter run
```

### Option 2: Running WITH an API Key
If you want to simulate sending an API Key (or if you are connecting to an endpoint that strictly demands it), you must inject it using `--dart-define`.

```bash
flutter run --dart-define=REQRES_API_KEY=your_actual_key_here
```

**For VSCode Users (`launch.json`):**
If you prefer hitting `F5` to debug, add this configuration to your `.vscode/launch.json`:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Flutter",
            "request": "launch",
            "type": "dart",
            "args": [
                "--dart-define",
                "REQRES_API_KEY=your_actual_key_here"
            ]
        }
    ]
}
```

## ✨ Features
1. **Screen 1 (Home)**: 
   - Palindrome Checker with validation.
   - Takes User's Name and passes it to the next screen via `SessionBloc`.
2. **Screen 2 (Welcome)**: 
   - Displays the user's name.
   - Reactively listens to changes and displays the "Selected User Name" using `SessionBloc`.
3. **Screen 3 (User List)**: 
   - Displays an infinite scrolling list of users fetched from `reqres.in`.
   - Built with `UserListBloc`.
   - Features pull-to-refresh, loading states, empty states, and error handling.
   - Tapping a user passes their name back to Screen 2.

## 📂 Folder Structure (Clean Architecture)
```text
lib/
├── core/
│   ├── constants/ (API Config)
│   ├── theme/ (Colors, Styles)
│   └── utils/ (Palindrome checker logic)
├── features/
│   ├── session/ (Handles User Name & Selected User State)
│   │   └── presentation/
│   │       ├── bloc/
│   │       └── pages/ (HomeScreen, WelcomeScreen)
│   └── users/ (Handles reqres.in Data Fetching)
│       ├── domain/ (Entities, UseCases, Repositories Interfaces)
│       ├── data/ (Models, DataSources, Repositories Impl)
│       └── presentation/
│           ├── bloc/
│           └── pages/ (UserListScreen)
├── shared/
│   └── widgets/ (Loading, Empty, Error states)
├── injection_container.dart (GetIt Setup)
├── app/
│   └── app.dart (MaterialApp & Routes)
└── main.dart (Entry point)
```

## 🧪 Testing
The project includes unit tests for `UserListBloc` and `isPalindrome`, as well as widget tests for `HomeScreen`. Run the tests via:
```bash
flutter test
```
