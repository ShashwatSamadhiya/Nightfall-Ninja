---
description: How to run the Flutter app and login for testing
---

# Run & Test Workflow

This workflow documents how to launch the Setu Care App and authenticate for testing.

> **💡 Best Practice**: Use the `local-runner` skill for detailed instructions.

## 1. Launch the App

```bash
cd /Users/abhi/farmsetu/setu-care-app
flutter run -d chrome --web-port=8080
```

**App URL:** `http://localhost:8080`

Wait for the app to compile and launch in Chrome.

## 2. Login Credentials

**Test Account:**
- **Username:** `9638306280`
- **Password:** `fsvi6280`

> ⚠️ **IMPORTANT**: These are test credentials only. Never commit production credentials.

## 3. Post-Login Navigation

After logging in, you'll land on the Dashboard. From there you can navigate to:
- Orders
- Customers
- Stocks
- Production
- Settings

## 4. Common Test Scenarios

| Feature | URL Path | Notes |
|---------|----------|-------|
| Dashboard | `/dashboard` | Main landing page |
| Orders | `/orders` | Order management |
| Customers | `/customers` | Customer list |

## 5. Troubleshooting

- **Port already in use**: Kill the existing process or use `flutter run -d chrome --web-port=8080`
- **Login fails**: Check network connectivity and API server status
- **White screen**: Clear browser cache and hot restart (`r` in terminal)
