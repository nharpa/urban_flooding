# Urban Flooding Digital Twin App

A Flutter mobile application that provides a comprehensive digital twin approach to reducing the impacts of urban flooding. This app combines real-time data, mapping, and educational resources to help communities prepare for and respond to flood events.

## Features

### Core Functionality

- **Interactive Flood Mapping**: Google Maps integration showing flood-prone areas and real-time flood conditions
- **Weather Forecasting**: Current weather conditions and forecasts to help predict flood risks
- **Risk Calculator**: Tools to assess flood risk based on location and conditions
- **Flood Warnings**: Real-time alerts and notifications about flood conditions
- **Incident Reporting**: Community-driven reporting system for flood incidents

### Educational Resources

- **Flood Preparation Guide**: Comprehensive preparation checklists and safety tips
- **Emergency Kit Recommendations**: Essential items for flood emergency preparedness
- **Pet and Livestock Safety**: Guidelines for protecting animals during floods

### User Management

- **Firebase Authentication**: Secure user registration and login
- **Password Reset**: Easy account recovery system
- **User Profiles**: Personalized flood risk information

## Technologies Used

- **Flutter**: Cross-platform mobile app development
- **Firebase**: Authentication and backend services
- **Google Maps**: Interactive mapping and location services
- **Geolocator**: GPS positioning and location permissions
- **HTTP**: API integration for weather and flood data
- **FL Chart**: Data visualization for risk assessment
- **Provider**: State management

## Getting Started

### Prerequisites

- Flutter SDK (^3.8.0)
- Dart SDK
- Android Studio or VS Code
- Firebase project setup
- Google Maps API key

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/nharpa/urban_flooding.git
   cd urban_flooding_frontend
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   Create a `.env` file in the root directory and add your API keys:

   ```env
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   WEATHER_API_KEY=your_weather_api_key
   ```

4. **Configure Firebase**

   - Create a new Firebase project
   - Add your Android/iOS app to the project
   - Download and place the configuration files:
     - `android/app/google-services.json` (Android)
     - `ios/Runner/GoogleService-Info.plist` (iOS)

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── assets/                   # Static assets
├── data/
│   ├── api_fetch_services.dart    # API data fetching
│   ├── api_post_services.dart     # API data posting
│   ├── education.json             # Educational content
│   └── mapping/                   # Map-related data
├── pages/
│   ├── auth/                      # Authentication pages
│   │   ├── login.dart
│   │   ├── signup.dart
│   │   └── reset_password.dart
│   ├── report/                    # Incident reporting
│   │   ├── report_issue_page.dart
│   │   └── report_confirmation_page.dart
│   ├── floodpreparation.dart      # Preparation guides
│   ├── hazardmap.dart             # Hazard mapping
│   ├── homepage.dart              # Main dashboard
│   ├── riskcalculatorpage.dart    # Risk assessment
│   ├── warnings.dart              # Flood warnings
│   └── weatherforcast.dart        # Weather information
├── theme/
│   └── theme.dart                 # App theming
└── widgets/                       # Reusable UI components
```

## Configuration

### Google Maps Setup

1. Enable Google Maps SDK for Android/iOS in Google Cloud Console
2. Create API credentials and restrict them appropriately
3. Add your API key to the `.env` file

### Firebase Setup

1. Create a Firebase project
2. Enable Authentication and configure sign-in methods
3. Set up Firestore Database for user data
4. Configure Firebase for your platform (Android/iOS)

## API Integration

The app integrates with various APIs for:

- Weather data and forecasting
- Flood monitoring and alerts
- Geographic and mapping services
- Real-time incident reporting

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Testing

- Run all tests with: `flutter test`
- Unit tests focus on API service logic using mocked HTTP clients, so they do not require network access or device plugins.
- If dependencies are missing, run `flutter pub get` before testing.
