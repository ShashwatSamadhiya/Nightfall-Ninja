---
description: How to add a persistent left navbar to any page by leveraging the existing Dashboard shell.
---

# Workflow: Add Persistent Left Navbar

You **MUST** follow this workflow strictly when the user asks to "add a sidebar" or "make the rail navigation persistent" for a specific page.

## Rule 1: Analyze the Architecture
**Context:** The `DashboardPage` acts as the Layout Shell. It provides the `SidebarScaffold`.
**Constraint:** You must **NEVER** wrap a child page in its own `SidebarScaffold` if it is nested under the Dashboard. Two sidebars will cause state conflicts and flickering.

## Rule 2: Route Configuration (Strict)
You **MUST** verify and modify `lib/src/presentation/route/app_router.dart`:

1.  Locate the route for the target page.
2.  **Move** the route to be a `child` of `DashboardRoute` (path: `/`) or one of its intermediate shells (like `MainOrderRoute`).
3.  **Ensure** the path is relative (no leading `/`).

**Example:**
```dart
AutoRoute(
  page: DashboardRoute.page,
  path: '/',
  children: [
    // ✅ CORRECT: Nested route
    AutoRoute(page: YourTargetRoute.page, path: 'target-page'),
  ],
),
```

## Rule 3: Page Implementation (Strict)
You **MUST** verify and modify the page widget file:

1.  **Remove** any `SidebarScaffold` wrapper.
2.  **Remove** any manual `RailNavbar` instantiation or sidebar state logic.
3.  **Use** a standard `Scaffold` (or return the `body` widget directly if a Scaffold is provided by an immediate parent).
    *   *Note:* Using `Scaffold` is generally safe to ensure `AppBar` availability.

**Example:**
```dart
// ❌ REJECT THIS PATTERN
return SidebarScaffold(
  sidebar: RailNavbar(...), // <--- DELETE THIS
  body: ...
);

// ✅ ENFORCE THIS PATTERN
return Scaffold(
  appBar: ...,
  body: ...
);
```

## Rule 4: Drawer Interaction
If the page needs to open a drawer (e.g., right-side filter):
1.  **USE** `SidebarScaffold.of(context)` to find the parent shell.
2.  **DO NOT** create a new GenericDrawer or Overlay manually unless strictly required by a unique design.

```dart
SidebarScaffold.of(context)?.showRightDrawer(...)
```