# Todo App

A simple todo app made with Flutter. You can add, edit and delete todos. Data is saved locally using SQLite database.

## Features

- Add new todos with title, description and date
- Edit existing todos
- Delete todos
- All data is saved in local database (SQLite)
- Uses BLoC for state management
- Nice looking UI with gradients and animations

## Screenshots

*Add screenshots here later*

## How to Install

### Requirements

You need to have Flutter installed on your computer. Download it from https://flutter.dev

### Steps

1. Clone this repository or download the code
```bash
git clone <repo-url>
cd todoAPp
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

For Android, make sure you have an emulator running or device connected.

## Project Structure

```
lib/
├── bloc/              # BLoC files for state management
│   ├── todo_bloc.dart
│   ├── todo_event.dart
│   └── todo_state.dart
├── database.dart      # Database operations
├── main.dart          # Entry point
├── todo_model.dart    # Todo data model
└── todo_ui_screen.dart # Main screen
```

## How It Works

The app uses BLoC pattern for managing state:
- Events are things like AddTodo, DeleteTodo etc
- BLoC handles the events and updates the state
- UI listens to state changes and updates automatically

## Dependencies Used

- flutter_bloc - For state management
- equatable - For comparing states
- sqflite - For local database
- path - For file paths

## How to Use

1. Tap "Add New Todo" to expand the form
2. Fill in title, description and select a date
3. Tap "Add Todo" button
4. Your todo will appear in the list

To edit: Tap the edit icon on any todo card
To delete: Tap the delete icon on any todo card

## Building the App

To build APK for Android:
```bash
flutter build apk
```

The APK will be in `build/app/outputs/flutter-apk/app-release.apk`

## Troubleshooting

If you get errors, try:
```bash
flutter clean
flutter pub get
flutter run
```

## Notes

- Database is created automatically when you first run the app
- All todos are stored locally on your device
- The app works offline

## Future Improvements

Things I want to add later:
- Search todos
- Filter by date
- Mark todos as complete
- Categories or tags
- Dark mode maybe

## License

Free to use

## Author

Made by [Your Name]

---

This is my first Flutter project using BLoC. Feel free to give feedback!
