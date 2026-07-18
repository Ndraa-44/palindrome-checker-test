# Palindrome Checker & User List App

A Flutter application built with Provider, implementing a Palindrome Checker and an API-driven User List with pagination.

## Prerequisites
- Flutter SDK 3.32+
- A valid API Key from [reqres.in](https://reqres.in/)

## How to Run

This project uses `--dart-define` to securely pass the API Key without hardcoding it into the source code.

To run the application, use the following command:
```bash
flutter run --dart-define=REQRES_API_KEY=your_actual_key_here
```

To build the APK:
```bash
flutter build apk --dart-define=REQRES_API_KEY=your_actual_key_here
```

## Features
- **Screen 1 (Home)**: Palindrome Checker with validation.
- **Screen 2 (Welcome)**: Shared state displaying the entered name and the selected user.
- **Screen 3 (User List)**: Infinite scrolling list of users fetched from `reqres.in`, pull-to-refresh, empty and error state handling.

## Folder Structure
```
lib/
├── main.dart
├── app/
│   └── app.dart
├── core/
│   ├── constants/
│   │   └── api_constants.dart
│   ├── network/
│   │   └── api_client.dart
│   └── utils/
│       └── palindrome_checker.dart
├── data/
│   ├── models/
│   │   └── user_model.dart
│   └── repositories/
│       └── user_repository.dart
├── presentation/
│   ├── session/
│   │   └── user_session_provider.dart
│   ├── screen1_home/
│   │   └── home_screen.dart
│   ├── screen2_welcome/
│   │   └── welcome_screen.dart
│   └── screen3_userlist/
│       ├── user_list_screen.dart
│       └── user_list_provider.dart
└── shared/
    └── widgets/
        ├── loading_indicator.dart
        ├── empty_state_widget.dart
        └── error_state_widget.dart
```
