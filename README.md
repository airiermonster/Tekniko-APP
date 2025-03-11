# Tekniko

<p align="center">
  <img src="assets/images/logo.png" alt="Tekniko Logo" width="200">
</p>

<p align="center">
  <b>Offline Student Information App for Arusha Technical College</b>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#screenshots">Screenshots</a> •
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
   git clone https://github.com/your-username/tekniko.git
   ```
   
2. Navigate to the project directory:
   ```bash
   cd tekniko
   ```
   
3. Install dependencies:
   ```bash
   flutter pub get
   ```
   
4. Run the app:
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

## Screenshots

<p align="center">
  <!-- Replace with actual screenshots -->
  <img src="docs/screenshots/home_screen.png" alt="Home Screen" width="200">
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="docs/screenshots/details_screen.png" alt="Details Screen" width="200">
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="docs/screenshots/about_screen.png" alt="About Screen" width="200">
</p>

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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ in Flutter
</p>
