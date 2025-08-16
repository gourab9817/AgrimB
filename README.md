# AgrimSeller - Comprehensive Project Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technical Architecture](#technical-architecture)
3. [Dependencies & Packages](#dependencies--packages)
4. [Project Structure](#project-structure)
5. [Data Models](#data-models)
6. [Services Layer](#services-layer)
7. [Business Logic (ViewModels)](#business-logic-viewmodels)
8. [User Interface (Screens & Widgets)](#user-interface-screens--widgets)
9. [User Flow & Navigation](#user-flow--navigation)
10. [Features & Functionality](#features--functionality)
11. [External Integrations](#external-integrations)
12. [Localization & Theming](#localization--theming)
13. [Firebase Configuration](#firebase-configuration)
14. [Build & Deployment](#build--deployment)
15. [Development Guidelines](#development-guidelines)

---

## View 
### Apps functionality
[![Complete functionalities](https://img.youtube.com/vi/c6D_42jhtY0/0.jpg)](https://youtu.be/c6D_42jhtY0)

### Notification module 
[![Agrimb Notification module](https://img.youtube.com/vi/2BlVJvqhKXg/0.jpg)](https://www.youtube.com/watch?v=2BlVJvqhKXg)

## Project Overview

**AgrimSeller** (internally named "agrimb") is a comprehensive Flutter-based mobile application designed as an agricultural marketplace platform. The app serves as a bridge between farmers and buyers, facilitating crop transactions with advanced features like crop analysis, weather integration, and structured deal management.

### Apps architecture diagram

### Key Information:
- **App Name**: Agrim Buyer
- **Internal Name**: agrimb
- **Version**: 1.0.0+1
- **Flutter SDK**: ^3.6.2
- **Platform Support**: Android, iOS, Web, Windows, macOS, Linux
- **Primary Use Case**: Agricultural marketplace for crop buying/selling

### Core Value Proposition:
The application provides a complete ecosystem for agricultural commerce, featuring:
- Real-time crop listings and marketplace
- AI-powered crop quality analysis
- Weather integration for informed decisions
- Structured visit scheduling and deal management
- Multi-language support (English & Hindi)
- Comprehensive notification system

---

## Technical Architecture

### Architecture Pattern
The application follows a **Clean Architecture** pattern with **MVVM (Model-View-ViewModel)** implementation using the Provider state management pattern.

### Layer Structure:

#### 1. Presentation Layer
- **Views/Screens**: UI components and user interactions
- **ViewModels**: Business logic and state management
- **Widgets**: Reusable UI components

#### 2. Business Logic Layer
- **Repositories**: Data access abstraction
- **Services**: External API integrations and core services

#### 3. Data Layer
- **Models**: Data structures and entities
- **Local Storage**: SharedPreferences for app settings
- **External APIs**: Firebase, Weather API, ML services

### State Management
- **Provider Pattern**: Used for dependency injection and state management
- **ChangeNotifier**: For reactive UI updates
- **MultiProvider**: Manages multiple providers at app level

---

## Dependencies & Packages

### Core Flutter Dependencies
```yaml
cupertino_icons: ^1.0.8        # iOS-style icons
provider: ^6.1.5               # State management
```

### UI & User Experience
```yaml
flutter_svg: ^2.0.7           # SVG support
lottie: ^2.6.0                # Animations
smooth_page_indicator: ^1.2.1  # Page indicators
intl_phone_field: ^3.2.0      # Phone input widget
pin_code_fields: ^8.0.1       # PIN input fields
```

### Utility & Storage
```yaml
shared_preferences: ^2.5.3     # Local storage
intl: ^0.19.0                 # Internationalization
uuid: ^4.0.0                  # UUID generation
path: ^1.8.3                  # Path manipulation
path_provider: ^2.1.1         # Path provider
url_launcher: ^6.1.14         # URL launching
package_info_plus: ^8.3.0     # App info
device_info_plus: ^9.1.0      # Device info
connectivity_plus: ^4.0.2     # Network connectivity
```

### Permissions & Hardware Access
```yaml
permission_handler: ^12.0.1    # Permission management
geolocator: ^10.1.0           # GPS location
geocoding: ^2.1.1             # Address geocoding
camera: ^0.11.1               # Camera access
image_picker: ^1.1.2          # Image selection
```

### Networking & Image Handling
```yaml
http: ^1.4.0                  # HTTP client
cached_network_image: ^3.3.0  # Image caching
flutter_image_compress: ^2.4.0 # Image compression
```

### Firebase Services
```yaml
firebase_core: ^3.14.0              # Firebase core
firebase_auth: ^5.5.2               # Authentication
google_sign_in: ^6.2.1              # Google Sign-in
firebase_app_check: ^0.3.1+7        # App Check security
cloud_firestore: ^5.6.6            # NoSQL database
firebase_storage: ^12.3.7          # File storage
firebase_messaging: ^15.2.7        # Push notifications
flutter_local_notifications: ^19.3.0 # Local notifications
```

### Development Dependencies
```yaml
flutter_lints: ^5.0.0         # Code analysis and linting
```

---

## Project Structure

### Directory Organization
```
lib/
├── core/                      # Core application utilities
│   ├── constants/             # App-wide constants
│   │   ├── app_assets.dart    # Asset paths and references
│   │   ├── app_spacing.dart   # Consistent spacing values
│   │   └── app_text_style.dart # Typography definitions
│   ├── localization/          # Internationalization
│   │   ├── app_localizations.dart
│   │   └── localization_extension.dart
│   ├── theme/                 # App theming
│   │   ├── app_colors.dart    # Color palette
│   │   └── app_theme.dart     # Theme configuration
│   └── utils/                 # Utility functions
├── data/                      # Data layer
│   ├── models/                # Data models and entities
│   ├── repositories/          # Data access layer
│   └── services/              # External service integrations
├── routes/                    # Navigation and routing
├── view/                      # UI layer
│   ├── screens/               # App screens
│   └── widgets/               # Reusable UI components
├── view_model/                # Business logic layer
└── main.dart                  # App entry point
```

### Asset Organization
```
assets/
├── animations/                # Lottie animations
├── fonts/                     # Custom fonts (Satoshi family)
├── icons/                     # App icons
├── images/                    # Static images
│   ├── crops/                 # Crop-related images
│   └── weather/               # Weather condition icons
├── translations/              # Localization files
└── vectors/                   # SVG vector graphics
```

---

## Data Models

### 1. UserModel
**Purpose**: Represents user authentication and profile information
```dart
class UserModel {
  final String uid;              // Firebase UID
  final String email;            // User email
  final String? name;            // User full name
  final String? phoneNumber;     // Contact number
  final String? address;         // User address
  final String? idNumber;        // Government ID number
  final bool isEmailVerified;    // Email verification status
  final String? profilePictureUrl; // Profile image URL
  final bool profileVerified;    // Admin verification status
  final String? fcmToken;        // Firebase messaging token
}
```

**Key Features**:
- Firebase integration for authentication
- Profile verification workflow
- FCM token management for push notifications
- JSON serialization/deserialization

### 2. ListingModel
**Purpose**: Represents crop listings in the marketplace
```dart
class ListingModel {
  final String id;               // Unique listing identifier
  final String farmerId;        // Seller's user ID
  final String name;             // Crop name
  final String imagePath;       // Crop image URL
  final String location;        // Farm/pickup location
  final String quantity;        // Available quantity
  final String price;           // Offered price
  final String qualityIndicator; // Quality rating
  final String listingDate;     // When listed
  final String quality;         // Quality description
  final String description;     // Additional details
}
```

### 3. WeatherModel & ForecastModel
**Purpose**: Weather data integration for agricultural insights
```dart
class WeatherModel {
  final String cityName;        // Location name
  final String stateName;       // State information
  final double temperature;     // Current temperature
  final double tempMin/Max;     // Temperature range
  final double feelsLike;       // Perceived temperature
  final int humidity;           // Humidity percentage
  final double windSpeed;       // Wind speed
  final String weatherMain;     // Weather condition
  final String weatherDescription; // Detailed description
  final DateTime timestamp;     // Data timestamp
}
```

### 4. NotificationModel
**Purpose**: In-app notification system
```dart
enum NotificationType {
  visitScheduled, visitRescheduled, visitCancelled, dealFinalized, general
}

class NotificationModel {
  final String id;              // Notification ID
  final String title;           // Notification title
  final String body;            // Message content
  final NotificationType type;  // Notification category
  final NotificationStatus status; // Read/unread status
  final DateTime createdAt;     // Creation timestamp
  final Map<String, dynamic>? data; // Additional payload
}
```

### 5. CropAnalysisModel
**Purpose**: AI-powered crop quality analysis results
```dart
class CropAnalysisModel {
  final int? totalSeeds;        // Total seeds detected
  final int? healthySeeds;      // Healthy seeds count
  final int? defectiveSeeds;    // Defective seeds count
  final String? error;          // Error message if analysis failed
  final String? errorCode;      // Structured error code
}
```

**Error Code System**:
- `E001`: Model initialization failed
- `E101`: No seeds detected
- `E201`: Objects too small to analyze
- `E202`: Objects too large to analyze
- `E203`: Inconsistent object properties
- `E301`: Too few seeds detected
- `E999`: General processing error

---

## Services Layer

### 1. FirebaseService
**Purpose**: Central Firebase operations management

**Key Methods**:
- `signUpWithEmail()`: User registration with profile data
- `signInWithEmail()`: Authentication and user data retrieval
- `fetchListedCrops()`: Retrieve available crop listings
- `createClaimedListing()`: Create visit scheduling entry
- `updateClaimedVisitStatus()`: Update visit progress
- `uploadProfilePicture()`: Profile image management
- `fetchClaimedCropsForBuyer()`: Get user's claimed crops

**Collections Used**:
- `buyers`: User profiles and authentication data
- `farmers`: Seller information
- `Listed crops`: Available crop listings
- `claimedlist`: Visit scheduling and deal tracking
- `pending_notifications`: Notification queue for backend processing

### 2. WeatherService
**Purpose**: OpenWeatherMap API integration

**Features**:
- Real-time weather data retrieval
- 4-day weather forecasting
- Location-based weather queries
- Automatic location detection via GPS
- Temperature unit conversion (Celsius/Fahrenheit)
- Weather condition mapping for custom icons

**API Integration**:
- **Base URL**: `https://api.openweathermap.org/data/2.5`
- **Endpoints**: `/weather`, `/forecast`, `/forecast/daily`
- **API Key Management**: Embedded in service class

### 3. CropAnalysisService
**Purpose**: Machine learning-powered crop analysis

**Features**:
- Image upload and processing
- Seed count and quality analysis
- Defect detection in agricultural products
- Error handling with user-friendly messages

**API Integration**:
- **Endpoint**: `https://wheat-seed-api-345895348005.us-central1.run.app/analyze-seeds`
- **Method**: POST with multipart file upload
- **Response**: JSON with analysis results

### 4. LocationService
**Purpose**: GPS and location management

**Features**:
- Current location retrieval with permissions
- Address resolution from coordinates
- Location permission management
- Fallback to default location (Vijayawada, Andhra Pradesh)

### 5. NotificationService
**Purpose**: Push notification system

**Features**:
- FCM token management
- Notification sending to farmers
- Local notification scheduling
- Cross-platform notification handling

---

## Business Logic (ViewModels)

### 1. Authentication ViewModels

#### LoginViewModel
- Email/password validation
- Authentication error handling
- Loading state management
- Automatic navigation based on verification status

#### SignupViewModel
- Multi-step registration process
- Profile data validation
- File upload coordination
- Email verification workflow

#### ProfileVerificationViewModel
- Admin approval waiting mechanism
- Periodic status checking
- Profile completion tracking

### 2. Dashboard ViewModels

#### DashboardViewModel
- Weather data coordination
- Best deals aggregation
- User welcome personalization
- Real-time data updates

#### WeatherViewModel
- Location-based weather fetching
- Forecast data management
- Error state handling
- Automatic refresh mechanisms

### 3. Marketplace ViewModels

#### BuyViewModel
- Crop listing retrieval and filtering
- Search functionality
- Visit status tracking
- Claimed crops management

**Key Features**:
- Real-time search with debouncing
- Multi-criteria filtering (type, location)
- Tab-based organization (Listed/Claimed crops)
- Status-based crop categorization

### 4. Deal Management ViewModels

#### VisitScheduleViewModel
- Appointment scheduling
- Farmer contact management
- Location coordination
- Notification integration

#### FinalDealViewModel
- Price negotiation tracking
- Deal term documentation
- Document upload coordination
- Transaction completion

---

## User Interface (Screens & Widgets)

### Core Screens

#### 1. SplashScreen
**Purpose**: App initialization and branding
- Animated logo presentation
- Background image with gradient overlay
- Automatic navigation to language selection
- Custom font implementation (Satoshi)

#### 2. LanguageSelectionScreen
**Purpose**: Internationalization setup
- English/Hindi language selection
- Persistent language preferences
- Cultural adaptation preparation

#### 3. Authentication Screens
- **LoginScreen**: Email/password authentication with validation
- **SignupScreen**: Multi-field registration with image upload
- **ForgotPasswordScreen**: Password reset via email
- **EmailVerificationScreen**: Email confirmation workflow
- **ProfileVerificationScreen**: Admin approval waiting

#### 4. DashboardScreen
**Purpose**: Main app hub with comprehensive overview
**Components**:
- Dynamic weather widget with real-time data
- Featured crop purchase options
- Mandi Bhav (market price) display
- Best deals carousel
- Bottom navigation integration

#### 5. BuyScreen
**Purpose**: Marketplace interface with advanced filtering
**Features**:
- Dual-tab layout (Listed/Claimed crops)
- Advanced search with real-time filtering
- Filter chips for type and location
- Pull-to-refresh functionality
- Status-based crop organization

#### 6. Crop Analysis Screens
- **CaptureProcessScreen**: Camera interface with guidelines
- **CheckYourCrop**: Analysis result display
- **PhotoCaptureController**: Advanced camera controls

#### 7. Deal Management Screens
- **ClaimListingScreen**: Crop details and claiming interface
- **VisitScheduleScreen**: Appointment scheduling
- **VisitSiteScreen**: On-site action management
- **FinalDealScreen**: Deal terms and price finalization
- **UploadVerificationDocumentsScreen**: Document collection
- **DealCompletedSplashScreen**: Success confirmation

### Custom Widgets

#### 1. Navigation Components
- **CustomBottomNavBar**: Persistent bottom navigation
- **DashboardAppBar**: Context-aware app bar with user info

#### 2. Authentication Widgets
- **EmailInput**: Validated email input field
- **PasswordInput**: Secure password input with visibility toggle
- **AppButton**: Standardized button with loading states
- **AuthHeader**: Consistent authentication screen headers
- **ErrorDialog**: User-friendly error display

#### 3. Dashboard Widgets
- **WeatherCard**: Real-time weather display with animations
- **FeatureCard**: Action-oriented feature presentation
- **BestDealsCard**: Deal highlighting with imagery
- **MandiBhavCard**: Market price information display

#### 4. Marketplace Widgets
- **ListingCard**: Comprehensive crop information display
- **FilterChip**: Interactive filter selection
- **SearchBar**: Real-time search interface

---

## User Flow & Navigation

### Primary User Journey

1. **App Launch**
   - Splash screen with branding
   - Language selection (first launch)
   - Authentication check

2. **Authentication Flow**
   - Login/Signup decision
   - Profile creation with verification
   - Email verification process
   - Admin profile verification wait

3. **Main Application Flow**
   - Dashboard overview
   - Crop browsing and filtering
   - Listing claiming process
   - Visit scheduling
   - On-site crop analysis
   - Deal finalization
   - Document upload and completion

### Navigation Architecture
- **Named Routes**: Centralized route management in `app_routes.dart`
- **Route Observer**: Navigation lifecycle tracking
- **Context-Aware Navigation**: Conditional routing based on user state
- **Deep Linking Support**: Direct access to specific screens

### Key Navigation Patterns
- **Bottom Navigation**: Primary app sections (Home, Buy, Calls, Profile)
- **Stack Navigation**: Linear workflow progression
- **Modal Navigation**: Overlay screens for focused tasks
- **Tab Navigation**: Content organization within screens

---

## Features & Functionality

### 1. User Authentication & Management
- **Email/Password Authentication**: Firebase Auth integration
- **Profile Verification**: Two-tier verification system
- **Profile Management**: Image upload and data editing
- **Security Features**: Email verification, secure token management

### 2. Marketplace Features
- **Crop Listings**: Comprehensive product information
- **Advanced Search**: Multi-criteria filtering and search
- **Real-time Updates**: Live data synchronization
- **Claim Management**: Structured purchasing workflow

### 3. AI-Powered Crop Analysis
- **Image Capture**: Camera integration with guidelines
- **Quality Assessment**: ML-based seed analysis
- **Defect Detection**: Automated quality scoring
- **Results Interpretation**: User-friendly analysis presentation

### 4. Weather Integration
- **Real-time Weather**: Current conditions display
- **Weather Forecasting**: 4-day forecast with detailed metrics
- **Location-based Data**: GPS-driven weather information
- **Agricultural Insights**: Weather impact on crop decisions

### 5. Visit & Deal Management
- **Appointment Scheduling**: Calendar integration
- **Location Coordination**: Meeting point management
- **Progress Tracking**: Multi-stage visit workflow
- **Document Management**: Verification document collection

### 6. Notification System
- **Push Notifications**: Firebase Cloud Messaging
- **Local Notifications**: App-based alerts
- **Notification Categories**: Visit, deal, and general notifications
- **Read/Unread Tracking**: Notification status management

### 7. Internationalization
- **Multi-language Support**: English and Hindi
- **Cultural Adaptation**: Region-specific content
- **Dynamic Language Switching**: Runtime language changes
- **Localized Content**: Translated strings and formats

---

## External Integrations

### 1. Firebase Services

#### Firebase Authentication
- **User Management**: Registration, login, password reset
- **Email Verification**: Automated verification workflow
- **Security**: Secure token management and validation

#### Cloud Firestore
- **Collections**:
  - `buyers`: User profiles and authentication data
  - `farmers`: Seller information and contact details
  - `Listed crops`: Available crop listings with metadata
  - `claimedlist`: Visit scheduling and deal tracking
  - `pending_notifications`: Notification queue management

#### Firebase Storage
- **Profile Pictures**: User image storage and retrieval
- **Crop Images**: Product photography storage
- **Document Storage**: Verification document management

#### Firebase Messaging
- **Push Notifications**: Cross-platform notification delivery
- **Token Management**: FCM token lifecycle management
- **Background Processing**: Cloud function integration

### 2. OpenWeatherMap API
- **Current Weather**: Real-time weather condition data
- **Weather Forecasting**: Multi-day forecast information
- **Location Integration**: GPS-based weather queries
- **Data Processing**: Temperature, humidity, wind, and precipitation

### 3. Custom ML API
- **Crop Analysis Service**: `https://wheat-seed-api-345895348005.us-central1.run.app`
- **Image Processing**: Multipart file upload and analysis
- **Quality Assessment**: Seed count and defect detection
- **Error Handling**: Structured error response management

### 4. Google Services
- **Location Services**: GPS and geocoding integration
- **Maps Integration**: Location display and selection
- **Sign-in Services**: Google authentication option

### 5. Device Integration
- **Camera Access**: Image capture with permission management
- **Storage Access**: File system integration
- **Network Monitoring**: Connectivity status tracking
- **Permission Management**: Runtime permission handling

---

## Localization & Theming

### Internationalization Architecture

#### Supported Languages
- **English (en)**: Primary language
- **Hindi (hi)**: Regional language support

#### Translation Management
- **File Structure**: JSON-based translation files
- **Dynamic Loading**: Runtime language switching
- **Fallback Mechanism**: Default to English for missing translations
- **Extension Methods**: Convenient translation access via context

#### Translation Categories
- **Authentication**: Login, signup, verification messages
- **Marketplace**: Crop listings, search, and filtering
- **Weather**: Weather conditions and forecasts
- **Notifications**: Alert messages and updates
- **Error Messages**: User-friendly error communication

### Theme System

#### Color Palette
```dart
class AppColors {
  // Primary Colors
  static const Color orange = Color.fromARGB(255, 242, 128, 53);
  static const Color brown = Color(0xFF4A3C31);
  
  // Secondary Colors
  static const Color lightOrange = Color(0xFFFFE4CC);
  static const Color lightBrown = Color(0xFFE5DFD9);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);
}
```

#### Typography
- **Font Family**: Satoshi (custom font with multiple weights)
- **Font Weights**: Light (300), Regular (400), Medium (500), Bold (600), Black (900)
- **Responsive Typography**: Scalable text sizes based on screen dimensions

#### Design System
- **Consistent Spacing**: Standardized padding and margin values
- **Border Radius**: Consistent corner radius application
- **Shadow System**: Layered shadow definitions for depth
- **Component Styling**: Reusable style definitions

---

## Firebase Configuration

### Project Setup
- **Project ID**: 
- **Support Platforms**: Android, iOS, Web
- **Security**: Firebase App Check integration

### Android Configuration
- **Application ID**:
- **Configuration File**: 
- **Firebase App ID**:

### iOS Configuration
- **Bundle ID**: Configured for iOS deployment
- **Firebase App ID**: 

### Cloud Functions
- **Runtime**: Node.js 20
- **Source Directory**: 
- **Build Command**: `npm run build`
- **Deployment**: Automated via Firebase CLI

### Security Rules
- **Authentication**: User-based access control
- **Data Validation**: Schema validation for Firestore
- **File Upload**: Secure storage rules for user content

---

## Build & Deployment

### Development Environment Setup

#### Prerequisites
- Flutter SDK ^3.6.2
- Dart SDK (included with Flutter)
- Android Studio / Xcode (for mobile development)
- Firebase CLI (for backend deployment)
- Node.js 20+ (for Cloud Functions)

#### Build Commands
```bash
# Get dependencies
flutter pub get

# Run in development
flutter run

# Build for production (Android)
flutter build apk --release
flutter build appbundle --release

# Build for production (iOS)
flutter build ios --release

# Web build
flutter build web
```

#### Environment Configuration
- **API Keys**: Weather API key embedded in service classes
- **Firebase Configuration**: Auto-generated configuration files
- **Build Variants**: Debug, profile, and release configurations

### Deployment Strategy

#### Mobile App Stores
- **Google Play Store**: Android app distribution
- **Apple App Store**: iOS app distribution
- **App Signing**: Proper certificate management

#### Web Deployment
- **Firebase Hosting**: Web app deployment option
- **Static Site Generation**: Optimized web builds

#### Backend Services
- **Cloud Functions**: Automated notification processing
- **Firebase Services**: Managed backend infrastructure

---

## Development Guidelines

### Code Quality Standards

#### Architecture Patterns
- **Clean Architecture**: Separation of concerns
- **MVVM Pattern**: Model-View-ViewModel implementation
- **Provider Pattern**: State management and dependency injection

#### Code Style
- **Flutter Lints**: Enforced code quality rules
- **Naming Conventions**: Consistent variable and method naming
- **Documentation**: Comprehensive code comments
- **Error Handling**: Structured exception management

#### Performance Considerations
- **Image Optimization**: Cached network images
- **Memory Management**: Proper widget disposal
- **Network Efficiency**: Request optimization and caching
- **Background Processing**: Efficient data synchronization

### Testing Strategy
- **Unit Testing**: Business logic validation
- **Widget Testing**: UI component testing
- **Integration Testing**: End-to-end workflow validation
- **Performance Testing**: App performance monitoring

### Security Practices
- **Data Encryption**: Sensitive data protection
- **Authentication Security**: Secure token management
- **API Security**: Secure external service integration
- **Permission Management**: Minimal permission requests

### Maintenance & Updates
- **Version Control**: Git-based source code management
- **Release Management**: Structured release workflow
- **Bug Tracking**: Issue identification and resolution
- **Feature Development**: Agile development practices

---

## Conclusion

AgrimSeller represents a comprehensive agricultural marketplace solution built with modern Flutter architecture and comprehensive external service integration. The application demonstrates enterprise-level development practices with robust error handling, security considerations, and user experience optimization.

### Key Strengths:
1. **Comprehensive Feature Set**: Complete crop trading workflow
2. **Modern Architecture**: Clean, maintainable, and scalable code structure
3. **External Integration**: Effective use of Firebase, weather, and ML services
4. **User Experience**: Intuitive interface with cultural considerations
5. **Technical Excellence**: Proper state management and error handling

### Future Enhancement Opportunities:
1. **Enhanced Analytics**: User behavior tracking and insights
2. **Advanced Filtering**: AI-powered crop recommendations
3. **Social Features**: Community building and farmer networks
4. **Payment Integration**: Integrated payment processing
5. **Logistics Coordination**: Delivery and transportation management

This documentation provides a complete technical reference for the AgrimSeller project, enabling effective development, maintenance, and enhancement of the application.
