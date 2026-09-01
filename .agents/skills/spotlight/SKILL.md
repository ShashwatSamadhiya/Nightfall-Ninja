---
name: spotlight
description: |
  Use this skill when creating, modifying, or debugging the Spotlight search feature.
  Triggers on: "spotlight", "Cmd+K search", "global search", "spotlight overlay",
  "search customers", "search orders", "search stocks", "search production",
  "spotlight tile", "spotlight cubit", "spotlight repository".
  Context: Flutter Web global search modal with keyboard shortcuts and multi-type search.
---

# Spotlight Feature Skill

A global search overlay (Cmd+K / Ctrl+K) that searches across customers, orders, stocks, and production entities.

---

## When to Use This Skill

Activate when the user wants to:
- Add new search types to Spotlight
- Modify Spotlight overlay behavior
- Create new Spotlight result tiles
- Debug Spotlight search or navigation issues
- Extend Spotlight with new entity types

---

## When NOT to Use This Skill

Do NOT use this skill if:
- Building standalone search within a specific feature page (use feature-specific search)
- Creating filtering/sorting functionality (use table or list patterns)
- Building a simple text input (use form patterns)

---

## Prerequisites

- Understanding of Clean Architecture (data/domain/presentation layers)
- Familiarity with `flutter_bloc` and Cubit pattern
- Knowledge of `dartz` Either pattern for error handling
- Access to existing feature repositories (CustomerTabRepository, OrderRepository, etc.)

---

## Architecture Overview

### Directory Structure

```
lib/src/features/spotlight/
├── data/
│   └── repositories/
│       └── spotlight_repository_impl.dart    # Composes feature repos
├── domain/
│   ├── entities/
│   │   └── spotlight_search_type.dart        # Search type enum
│   └── repositories/
│       └── spotlight_repository.dart         # Abstract interface
├── presentation/
│   ├── cubit/
│   │   ├── spotlight_search_cubit.dart       # State management
│   │   └── spotlight_search_state.dart       # Sealed states
│   └── widgets/
│       ├── customer/                         # Customer tile components
│       ├── order/                            # Order tile components
│       ├── overlay/                          # Overlay UI components
│       ├── production/                       # Production tile components
│       ├── stock_tile/                       # Stock tile components
│       ├── spotlight_customer_tile.dart      # Main customer tile
│       ├── spotlight_order_tile.dart         # Main order tile
│       ├── spotlight_production_tile.dart    # Main production tile
│       ├── spotlight_stock_tile.dart         # Main stock tile
│       ├── spotlight_overlay.dart            # Main overlay widget
│       └── spotlight_search_type_toggle.dart # Type selector
└── spotlight.dart                            # Library exports
```

---

## Key Patterns

### 1. Search Type Enum

Location: `domain/entities/spotlight_search_type.dart`

```dart
enum SpotlightSearchType {
  customer,
  order,
  stock,
  production;

  String get label => switch (this) {
    customer => 'Customers',
    order => 'Orders',
    stock => 'Stock',
    production => 'Production',
  };

  SpotlightSearchType get next {
    final values = SpotlightSearchType.values;
    return values[(index + 1) % values.length];
  }

  IconData get icon => switch (this) {
    customer => Icons.person_search_outlined,
    order => Icons.manage_search_outlined,
    stock => Icons.inventory_2_outlined,
    production => Icons.compost,
  };
}
```

### 2. Sealed State Classes

Location: `presentation/cubit/spotlight_search_state.dart`

```dart
sealed class SpotlightSearchState extends Equatable {
  final SpotlightSearchType searchType;
  final SpotlightSearchData data;

  const SpotlightSearchState({required this.searchType, required this.data});
}

final class SpotlightSearchInitial extends SpotlightSearchState { ... }
final class SpotlightSearchLoading extends SpotlightSearchState { ... }
final class SpotlightSearchLoaded extends SpotlightSearchState { ... }
final class SpotlightSearchError extends SpotlightSearchState { ... }
```

### 3. Repository Composition Pattern

The `SpotlightRepositoryImpl` delegates to existing feature repositories:

```dart
class SpotlightRepositoryImpl implements SpotlightRepository {
  final CustomerTabRepository customerRepository;
  final OrderRepository orderRepository;
  final StockRepository stockRepository;
  final ProductionSearchRepository productionSearchRepository;

  // Each search delegates to the appropriate feature repository
  Future<Either<Failure, PaginatedResponse<CustomerTabSummaryEntity>>>
  searchCustomers(String query) {
    return customerRepository.fetchCustomerTableList(...);
  }
}
```

### 4. Overlay with Keyboard Shortcuts

Location: `presentation/widgets/spotlight_overlay.dart`

```dart
class SpotlightOverlay extends StatefulWidget {
  static void show(BuildContext context, {SpotlightSearchType? initialSearchType}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      barrierDismissible: true,
      builder: (context) => SpotlightOverlay(sidebar: sidebar),
    );
  }
}
```

Key behaviors:
- **Cmd+K / Ctrl+K**: Cycle through search types (when held)
- **Escape**: Close dropdown or overlay
- **Animation**: Scale + fade transition (200ms)
- **Auto-focus**: Search field focused on open

### 5. Result Tile Composition

Each tile is composed of smaller, reusable sub-widgets:

```
SpotlightCustomerTile
├── SpotlightCustomerAvatar
├── SpotlightCustomerInfo
├── SpotlightCustomerActions
└── SpotlightCustomerStats
```

Common tile patterns:
- `MouseRegion` for hover state
- `AnimatedContainer` for hover effects
- `InkWell` with proper splash colors
- Navigation via `onCloseAndThen` callback

---

## Instructions

### Adding a New Search Type

#### Step 1: Add to SpotlightSearchType Enum

```dart
// In domain/entities/spotlight_search_type.dart
enum SpotlightSearchType {
  customer,
  order,
  stock,
  production,
  newType; // Add new type

  String get label => switch (this) {
    // ... existing cases
    newType => 'New Type Label',
  };

  IconData get icon => switch (this) {
    // ... existing cases
    newType => Icons.new_icon,
  };
}
```

#### Step 2: Update SpotlightSearchData

```dart
// In presentation/cubit/spotlight_search_state.dart
class SpotlightSearchData extends Equatable {
  final List? newTypeResults;  // Add field

  // Update constructor, copyWith, and props
}
```

#### Step 3: Add Repository Method

```dart
// In domain/repositories/spotlight_repository.dart
abstract class SpotlightRepository {
  Future<Either<Failure, PaginatedResponse<NewTypeEntity>>> searchNewType(String query);
}

// In data/repositories/spotlight_repository_impl.dart
@override
Future<Either<Failure, PaginatedResponse<NewTypeEntity>>> searchNewType(String query) {
  return newTypeRepository.fetch(...);
}
```

#### Step 4: Update Cubit

```dart
// In presentation/cubit/spotlight_search_cubit.dart
Future<void> _searchNewType(String searchTerm) async {
  final result = await _repository.searchNewType(searchTerm);
  result.fold(
    (failure) => _emitError(searchTerm, failure),
    (response) => emit(SpotlightSearchLoaded(
      searchTerm: searchTerm,
      searchType: SpotlightSearchType.newType,
      data: state.data.copyWith(newTypeResults: response.results),
    )),
  );
}
```

#### Step 5: Create Result Tile

Create a new tile following the composition pattern:

```dart
// In presentation/widgets/spotlight_new_type_tile.dart
class SpotlightNewTypeTile extends StatefulWidget {
  final NewTypeEntity item;
  final void Function(VoidCallback? afterClose) onCloseAndThen;

  // Follow pattern from SpotlightCustomerTile
}
```

#### Step 6: Update Results Wrapper

```dart
// In presentation/widgets/overlay/spotlight_results_wrapper.dart
// Add case for new type in the build method
```

---

## Constraints

- **NEVER** put business logic in tile widgets — delegate to Cubit
- **NEVER** hardcode colors — use `context.colors` extensions
- **NEVER** skip the `onCloseAndThen` pattern for navigation
- **NEVER** ignore keyboard accessibility
- **ALWAYS** use sealed classes for state
- **ALWAYS** use Either pattern for repository returns
- **ALWAYS** cache results per search type in `SpotlightSearchData`

---

## Navigation Pattern

The spotlight uses a callback pattern to ensure proper overlay cleanup before navigation:

```dart
void _navigateToDetails(BuildContext context) {
  final router = context.router;
  widget.onCloseAndThen(() {
    router.push(DetailsRoute(id: widget.item.id));
  });
}
```

This ensures:
1. Overlay animation completes
2. Dialog is properly popped
3. Navigation occurs after cleanup

---

## Theming

Use theme extensions consistently:
- Colors: `context.colors.primary`, `context.colors.surface`, etc.
- Text styles: `context.textStyles.titleMedium`, etc.
- Hover states: Use `withValues(alpha: x)` for opacity

---

## Quality Checklist

Before completing spotlight changes, verify:
- [ ] All search types have consistent tile styling
- [ ] Keyboard shortcuts work (Cmd+K cycling, Escape to close)
- [ ] Navigation works correctly from tiles
- [ ] Loading, error, and empty states are handled
- [ ] Results are cached per search type
- [ ] No direct imports from other feature's presentation layers
- [ ] `flutter analyze` passes with no warnings
