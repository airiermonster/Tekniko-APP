# Tekniko

<p align="center">
  <img src="assets/images/logo.png" alt="Tekniko Logo" width="200">
</p>

<p align="center">
  <b>Offline Student Information App for Arusha Technical College</b>
</p>

<p align="center">
  <b>Developed by Maximillian Urio</b>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#project-structure">Project Structure</a> •
  <a href="#json-structure">JSON Structure</a> •
  <a href="#technologies-used">Technologies Used</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#license">License</a>
</p>

## Features

- **Offline Data Management**: Access and manage student information without an internet connection
- **Fast Search**: Quickly find students by name, admission number, or phone number
- **Clean UI/UX**: Modern interface with animations and intuitive navigation
- **Responsive Design**: Works on various screen sizes and orientations
- **Multi-format Image Support**: Handles SVG and other image formats with automatic fallback
- **Dark/Light Theme Support**: Adapts to system theme or manual selection

## Installation

### Prerequisites

- Flutter SDK (version 3.7.0 or higher)
- Android Studio or VS Code with Flutter extensions

### Getting Started

1. Clone this repository:
   ```bash
   git clone https://github.com/airiermonster/tekniko-app.git
   ```
   
2. Navigate to the project directory:
   ```bash
   cd tekniko-app
   ```
   
3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Add the students.json file:
   - Create a file at `assets/data/students.json`
   - Follow the JSON structure specified in the [JSON Structure](#json-structure) section
   
5. Run the app:
   ```bash
   flutter run
   ```

## Usage

The app provides a simple interface to:

1. **Browse Students**: Scroll through the list of all registered students
2. **Search**: Use the search field to find specific students
3. **Filter**: Filter search results by name, admission number, or phone number
4. **View Details**: Tap on a student card to view comprehensive information
5. **Settings**: Customize app appearance and behavior
6. **About**: View information about the app and privacy policy

## Architecture

The project follows a clean architecture approach with:

- **Domain Layer**: Contains business logic and entities
- **Data Layer**: Handles data access and repository implementations
- **Presentation Layer**: Contains UI components and state management

The app uses the Provider pattern for state management and follows SOLID principles for clean, maintainable code.

## Project Structure

```
tekniko/
├── android/                    # Android-specific files
├── assets/
│   ├── data/                  # JSON data files
│   ├── fonts/                 # Custom fonts
│   └── images/                # App images and icons
├── ios/                       # iOS-specific files
├── lib/
│   ├── core/                  # Core functionality
│   │   ├── constants/         # App constants
│   │   ├── theme/            # App theming
│   │   └── utils/            # Utility functions
│   ├── data/
│   │   ├── models/           # Data models
│   │   └── repositories/     # Data repositories
│   ├── domain/
│   │   ├── entities/         # Business entities
│   │   └── services/         # Business logic
│   └── presentation/
│       ├── providers/        # State management
│       ├── screens/          # App screens
│       └── widgets/          # Reusable widgets
├── test/                      # Test files
└── pubspec.yaml              # Project configuration
```

## JSON Structure

The app requires a specific JSON structure for the student data. Create a file at `assets/data/students.json` with the following structure:

```json
{
  "students": [
    {
      "id": "string",
      "admissionNumber": "string",
      "firstName": "string",
      "middleName": "string",
      "lastName": "string",
      "phoneNumber": "string",
      "email": "string",
      "course": "string",
      "department": "string",
      "yearOfStudy": "string",
      "registrationDate": "YYYY-MM-DD"
    }
  ]
}
```

**Note**: The original JSON file has been removed for security and privacy purposes. You need to create your own JSON file following this structure.

## Technologies Used

- **Flutter**: UI framework
- **Dart**: Programming language
- **SQLite**: Local database for offline storage
- **Provider**: State management
- **Flutter SVG**: SVG rendering support
- **Path Provider**: File system access
- **Shared Preferences**: Local preferences storage

## Contributing

Contributions are welcome! If you'd like to contribute:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Commit your changes (`git commit -m 'Add some amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

For major changes, please open an issue first to discuss what you would like to change.

## Contact

- **Developer**: Maximillian Urio
- **Email**: airiermonster@gmail.com
- **GitHub**: [https://github.com/airiermonster](https://github.com/airiermonster)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ in Flutter
</p>
