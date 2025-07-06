# UniRateAPI Integration Setup

This document explains how to set up the UniRateAPI integration for real-time currency exchange rates in the Unit Converter app.

## Overview

The app now supports real-time currency exchange rates using the UniRateAPI. When no API key is configured, the app falls back to mock exchange rates for demonstration purposes.

## Setup Instructions

### 1. Get a UniRateAPI Key

1. Visit [UniRateAPI](https://unirate.com) and sign up for an account
2. Navigate to your dashboard and generate an API key
3. Copy the API key for use in the app

### 2. Configure Environment Variables

1. Open the `.env` file in the project root
2. Replace `your_api_key_here` with your actual UniRateAPI key:

```env
# UniRateAPI Configuration
UNIRATE_API_KEY=your_actual_api_key_here
UNIRATE_BASE_URL=https://api.unirate.com/v1
```

### 3. Install Dependencies

Run the following command to install the required dependencies:

```bash
flutter pub get
```

### 4. Test the Integration

1. Run the app: `flutter run`
2. Navigate to the Currency converter
3. Check the info section at the bottom - it should show "Using real-time exchange rates from UniRateAPI"

## Features

### Real-time Exchange Rates
- Fetches current exchange rates from UniRateAPI
- Supports major currencies: USD, EUR, GBP, JPY, CAD, AUD, CHF, CNY, INR, BRL
- Automatic rate caching (1 hour) to reduce API calls

### Fallback Mechanism
- If no API key is configured, uses mock exchange rates
- If API is unavailable, gracefully falls back to mock data
- Network timeout handling (10 seconds)

### Error Handling
- Invalid API key detection
- Network error handling
- Rate limiting protection
- Graceful degradation to mock data

## API Response Format

The service expects the UniRateAPI to return data in one of these formats:

### Format 1: Direct rates
```json
{
  "rates": {
    "USD": 1.0,
    "EUR": 0.85,
    "GBP": 0.73
  }
}
```

### Format 2: Nested data
```json
{
  "data": {
    "rates": {
      "USD": 1.0,
      "EUR": 0.85,
      "GBP": 0.73
    }
  }
}
```

## Testing

Run the tests to verify the integration:

```bash
flutter test test/exchange_rate_service_test.dart
```

## Troubleshooting

### App shows "Using mock exchange rates"
- Check that your API key is correctly set in the `.env` file
- Ensure the API key is valid and active
- Verify network connectivity

### API errors
- Check the console logs for specific error messages
- Verify your API key has the necessary permissions
- Check UniRateAPI status page for service issues

### Network timeouts
- The app will automatically fall back to mock data
- Check your internet connection
- Try again later if the API is experiencing issues

## Security Notes

- Never commit your actual API key to version control
- The `.env` file is already in `.gitignore` to prevent accidental commits
- Consider using different API keys for development and production

## Rate Limits

- UniRateAPI has rate limits based on your plan
- The app implements caching to minimize API calls
- Exchange rates are cached for 1 hour
- Consider upgrading your plan if you hit rate limits frequently 