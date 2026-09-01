---
name: Local Runner
description: The authoritative guide for running, testing, and debugging the Setu Care Flutter Web app locally.
triggers:
  - run app
  - start app
  - debug app
  - test app
  - launch
  - flutter run
  - localhost
  - port 8080
  - login credentials
  - browser testing
---

# Local Runner Skill

Use this skill whenever you need to run, test, or debug the application. It enforces strict protocols to ensure consistent behavior across manual usage and agent automation.

## 1. The Golden Rule: Fixed Port & Window

**ALWAYS** follow these two rules for every session:

1.  **Run on Port 8080**:
    ```bash
    flutter run -d chrome --web-port=8080
    ```
    *Why?* Agent scripts depend on `http://localhost:8080`. Random ports break automation.

2.  **Maximize Browser First**:
    *Before doing anything else in the browser*, maximize the window.
    *Why?* Flutter Web is responsive. Small windows change layout (mobile vs desktop), causing "click at wrong place" errors.

---

## 2. Credentials

| Role | Username | Password |
|------|----------|----------|
| **Admin/Test** | `9638306280` | `fsvi6280` |

---

## 3. Browser Automation Directives

When using the `browser_subagent`, you **MUST** include these instructions in your `Task` prompt:

### Standard Launch Prologue
```text
1. Maximize the browser window immediately.
2. Navigate to http://localhost:8080 and wait for the app to load.
```

### Semantic Interaction Policy
Do **NOT** click by pixel coordinates (X, Y) unless absolutely necessary. Screen resolution variances make this brittle.

**PREFERRED**: Use semantic finders (if supported) or relative positioning based on visual anchors.
**FALLBACK**: if you must click by coordinates:
1. Ensure window is maximized.
2. Locate a large, distinct element (like a header) first to calibrate.
3. Use `browser_get_dom` to get real-time element positions *after* resize.

---

## 4. Troubleshooting & Commands

| Action | Command / Fix |
|--------|---------------|
| **Start App** | `flutter run -d chrome --web-port=8080` |
| **Hot Reload** | Press `r` in terminal (UI changes only) |
| **Hot Restart** | Press `R` in terminal (State/Logic changes) |
| **Port Error** | `lsof -i :8080` then `kill -9 <PID>` |
| **Blank Screen** | Hard refresh browser (Cmd+Shift+R) or Hot Restart `R` |

## 5. Navigation Shortcuts

- **Dashboard**: `/dashboard`
- **Orders**: `/orders`
- **Customers**: `/customers`
- **Stocks**: `/stocks`
