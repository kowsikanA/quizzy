
# Quizzy  

## Description  
Quizzy is a Flutter-based quiz application designed to provide an interactive and engaging classroom experience. The app allows students and teachers to log in, participate in quiz sessions, and receive notifications.  

## Features  
- **Student and Teacher Login**  
- **Firebase Integration** for real-time data storage  
- **Push Notifications** using `flutter_local_notifications`  
- **Modern UI with Material 3**  

## Installation  

1. **Clone the Repository**  
   ```sh
   git clone <repository-url>
   cd quizzy
   ```

2. **Install Dependencies**  
   ```sh
   flutter pub get
   ```

3. **Set Up Firebase**  
   - Create a Firebase project  
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)  
   - Place them in the respective platform directories (`android/app/` and `ios/Runner/`)  

4. **Run the App**  
   ```sh
   flutter run
   ```

## Project Structure  
```sh
lib/
│── main.dart                # Main entry point  
│── studentlogin.dart        # Student login screen  
│── teacherlogin.dart        # Teacher login screen  
│── firebase_options.dart    # Firebase configuration  
```

## Dependencies  
- `flutter_local_notifications`  
- `firebase_core`  
- `firebase_auth` (if authentication is implemented)  
- `flutter/material.dart`  

## Screenshots  
(Add images of your app here)  

## License  
This project is licensed under the MIT License.  
```

