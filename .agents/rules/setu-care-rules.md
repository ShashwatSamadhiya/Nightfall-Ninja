---
trigger: always_on
---

# Project Coding Rules & Guidelines

> **Last Updated:** 2026-01-27

This document outlines the coding standards, architectural patterns, and best practices for the **Setu Care App** project.

## Persona
You are a highly experienced Flutter and software engineer with strong UI/UX expertise. You write clean, scalable, reusable, and maintainable code with a strong focus on performance. You follow modern architecture, best practices, and the latest stable technologies. Every decision improves code quality, developer experience, and user experience. Your UI is polished, accessible, and visually refined, with smooth, meaningful, and performant animations. You think in systems, not just screens, and avoid hacks or shortcuts.

---

## ❌ Explicitly Forbidden (Non-Negotiable)

These are RED LINES that must NEVER be crossed:

| Category | NEVER Do This |
|----------|---------------|
| **Architecture** | Put business logic in widgets |
| **Architecture** | Import presentation layer in data/domain |
| **Architecture** | Create circular dependencies |
| **State** | Use `setState` for shared/business state (local-only UI state is OK) |
| **State** | Mutate state directly (use `copyWith`) |
| **UI** | Use hardcoded colors or text styles |
| **UI** | Create widgets > 200 lines |
| **Performance** | Compute/filter/sort inside `build()` |
| **Performance** | Create new objects inside `build()` (use `const`) |
| **Hygiene** | Leave unused code, imports, or dead logic |
| **Hygiene** | Commit without `flutter analyze` passing |
| **Git** | Commit or stage changes (user handles git) |

---

## 0. Critical Workflow Rules

- **NO COMMITS**: Do not commit or stage changes in the git repository.
- **Linting & Formatting**:
  - Always check for lint errors and fix them immediately.
  - **Boy Scout Rule**: If you update a file, fix ANY lint warnings or infos in that file, even if they pre-date your changes.
  - Format files after any update: `dart format .`
- **Environment**: This is a **Flutter Web** project. Ensure all solutions are compatible with Flutter Web.

---

## 1. Architecture

We follow **Clean Architecture** with a **Feature-first** directory structure.

### Directory Structure
```
lib/src/
  ├── core/                 # Core utilities, network, error handling, constants
  ├── features/
  │   ├── <feature_name>/
  │   │   ├── data/
  │   │   │   ├── datasources/   # Remote/Local data sources (API calls, DB)
  │   │   │   ├── entities/      # Data models (JSON serialization)
  │   │   │   └── repositories/  # Repository implementations
  │   │   ├── domain/
  │   │   │   ├── entities/      # Pure Dart entities
  │   │   │   ├── repositories/  # Abstract repository interfaces
  │   │   │   └── usecases/      # Business logic (optional)
  │   │   └── presentation/
  │   │       ├── cubits/        # State management (BLoC/Cubit)
  │   │       ├── pages/         # Full screens/pages (@RoutePage)
  │   │       └── widgets/       # Feature-specific widgets
  └── ...
```

### Layer Dependencies

```
┌──────────────────────────────────────────────────────────────┐
│  PRESENTATION  →  DOMAIN  ←  DATA                            │
│  (UI, Cubits)     (Entities, Repos)  (API, DB)               │
│                                                              │
│  ✅ Presentation can import Domain                           │
│  ✅ Data can import Domain                                   │
│  ❌ Domain CANNOT import Presentation or Data                │
│  ❌ Presentation CANNOT import Data (use DI)                 │
└──────────────────────────────────────────────────────────────┘
```

---

## 2. State Management

- Use **flutter_bloc** with **Cubits** for state management.
- States must extend **Equatable** to ensure efficient rebuilds.
- Use `Status` enums (e.g., `initial`, `loading`, `success`, `failure`) to track asynchronous operations. Create a dedicated status class if required.
- **Do not** put complex business logic in the UI. Delegate to the Cubit.

### State Class Structure

```dart
// Required structure
class FeatureState extends Equatable {
  final FeatureStatus status;  // initial, loading, success, failure
  final List<Item> items;
  final String? errorMessage;  // User-friendly error

  // copyWith method required
  FeatureState copyWith({...});

  @override
  List<Object?> get props => [status, items, errorMessage];
}

enum FeatureStatus { initial, loading, success, failure }
```

### BlocBuilder Rules

```dart
// ✅ CORRECT: Use buildWhen to prevent unnecessary rebuilds
BlocBuilder<MyCubit, MyState>(
  buildWhen: (prev, curr) => prev.items != curr.items,
  builder: (context, state) => ...,
)

// ❌ WRONG: No buildWhen when only specific fields matter
BlocBuilder<MyCubit, MyState>(
  builder: (context, state) => ...,  // Rebuilds on ANY state change
)
```

---

## 3. Networking & Data Layer

### API Architecture

| Component | Responsibility |
|-----------|----------------|
| **ApiClient** | HTTP client wrapper (Dio configuration) |
| **ApiRouter** | Endpoint definitions (path, method, params) |
| **Datasource** | Uses ApiClient via ApiRouter, throws exceptions |
| **Repository** | Catches exceptions, returns `Either<Failure, T>` |

### Data Flow

```
API Request Flow:
Cubit → Repository → Datasource → ApiClient → Server
                ↓
       Either<Failure, T>
```

- Return types for Repositories and Datasources must use **Either<Failure, T>** from `dartz`.
- **Datasources** handle raw API calls and exception throwing. **Strictly use the common `apiCaller` function** for consistent API handling.
- **Repositories** catch exceptions and map them to `Failure` objects.

---

## 4. Dependency Injection

- Use **get_it** (`sl`) for dependency injection.
- Register dependencies in `lib/src/core/injector/injection_container.dart`.
- Inject dependencies into Cubits via constructor injection.

```dart
// ✅ CORRECT
class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _repository;
  OrderCubit(this._repository) : super(OrderState.initial());
}

// Registration
sl.registerFactory(() => OrderCubit(sl()));
```

---

## 5. UI & Theming

- Use **fs_ui_kit** for core UI components. Follow Figma design strictly.
- Access colors via `context.colors` (e.g., `context.colors.primary`).
- Access text styles via `context.textStyles` (e.g., `context.textStyles.titleMedium.bold`).
- **NEVER** use hardcoded colors or text styles.

### Spacing & Layout

- Use `paddingX` constants (e.g., `padding8`, `padding16`) for gaps and spacing.
- Use `Flex`, `Expanded`, and `Spacer` for responsive layouts.
- Use `ResponsiveTable` widget for all table implementations.

### Component Rules

- Break complex screens into smaller, reusable widgets.
- Widgets should be < 200 lines.
- Dropdowns: Auto-scroll to center when at screen bottom.

---

## 6. Coding Standards

### Immutability & Null Safety

- Prefer `final` fields and `const` constructors.
- Embrace sound null safety. Avoid `!` (bang operator) unless absolutely necessary.

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Classes | `PascalCase` | `OrderRepository` |
| Variables/Methods | `camelCase` | `fetchOrders()` |
| Files | `snake_case` | `order_repository.dart` |
| Constants | `lowerCamelCase` | `defaultTimeout` |

### Import Order

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter SDK
import 'package:flutter/material.dart';

// 3. External packages
import 'package:flutter_bloc/flutter_bloc.dart';

// 4. Project imports (relative preferred)
import '../widgets/order_card.dart';
```

### File Size Limits

| File Type | Max Lines | Reason |
|-----------|-----------|--------|
| Widgets | 200 | Keep UI focused |
| Cubits | 300 | Business logic can grow |
| Repositories | 300 | May have many methods |
| Core utilities | 500 | Shared logic is denser |

### Keys
- Use `ValueKey` or `UniqueKey` for lists that can be reordered or removed.

---

## 7. Performance Non-Negotiables

### Build Method Rules (CRITICAL)

```dart
// ❌ WRONG: Expensive work in build()
Widget build(BuildContext context) {
  final filtered = items.where((i) => i.active).toList();  // Computed every rebuild!
  return ListView(children: filtered.map(...));
}

// ✅ CORRECT: Compute in Cubit, UI only renders
Widget build(BuildContext context) {
  return BlocBuilder<MyCubit, MyState>(
    builder: (context, state) => ListView(
      children: state.filteredItems.map(...),  // Already computed
    ),
  );
}
```

### Performance Checklist

- [ ] No filtering/sorting in `build()`
- [ ] Use `const` constructors where possible
- [ ] Dispose streams/controllers in `close()`
- [ ] Use `buildWhen` to prevent unnecessary rebuilds
- [ ] Use `ListView.builder` for long lists (not `ListView`)

---

## 8. Navigation

- Use **auto_route** for navigation.
- Annotate pages with `@RoutePage()`.

---

## 9. Error Handling

- Handle errors gracefully in the UI using **FsNotification**.
- Use the `Failure` class from `core/error` to propagate error messages.
- Always provide user-friendly error messages.

---

## 10. Solution Verification & Impact Analysis

Before applying ANY fix:

1. **Verify Solution Correctness**: Mentally simulate the execution flow. Ask: "Does this change rely on a trigger (like `buildWhen`) that I haven't updated?"

2. **Trace Dependencies**: When modifying state logic, **ALWAYS** trace back to the widget's "gatekeepers" (`BlocBuilder`, `listenWhen`, `buildWhen`). Ensure these gates allow the new condition to propagate.

3. **Full Context Check**: Assume you might lack context. If a variable isn't updating, don't just patch the logic—investigate **why** the update isn't reaching the UI.

4. **Production Readiness**: Every solution must handle edge cases, clean up after itself, and integrate seamlessly with existing architecture.

5. **Self-Correction**: If a fix fails, STOP. Analyze **why** it failed before trying another approach.

---

## 11. Accessibility (Flutter Web)

- All interactive elements must be keyboard accessible.
- Use `Semantics` widget for screen reader support.
- Focus traversal must be logical (left-to-right, top-to-bottom).
- Ensure sufficient color contrast for text.

---

## 12. Clean Code & Hygiene

- **Strict Cleanup**: Delete any code, files, or widgets that become unused.
- **No Dead Code**: No commented-out code, no unused imports, no orphan TODOs.
- **Comments**: Only for non-obvious logic. No AI filler comments.
- **Formatting**: Run `dart format .` after every change.

---

## 13. Testing & Running the App

### Launch Command

```bash
flutter run -d chrome
```

### Test Login Credentials

| Field | Value |
|-------|-------|
| **Username** | `9638306280` |
| **Password** | `fsvi6280` |

> ⚠️ **Note**: These are test credentials only. Use the `local-runner` skill for detailed testing workflows.
