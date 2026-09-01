---
name: Module Analyzer
description: Use this skill to deeply analyze a module, flow, feature, or directory and explain what is going on.
---

# Module Analyzer Skill

This skill analyzes a codebase module, feature, or user flow to produce a detailed report. The report bridges the gap between technical implementation and product intent, making it suitable for both Product Managers (high-level understanding) and Developers (code-level understanding).

## When to Use

Use this skill when the user asks to:
- "Analyze this module"
- "Explain how the [Feature X] flow works"
- "What is going on in [Directory Y]?"
- "Generate a report for [Feature Z]"
- "Understand the [Flow Name] user journey and code"
- "Deep dive into [Module Name]"
- "Audit [Feature] for product and tech review"
- "Explain what is going on in [Directory/File]"
- "Connecting the dots for [Feature]"

## 1. Context & Scope Identification

First, identify what the user wants to analyze and its boundaries.

1.  **Resolve the Path/Scope**:
    - If a specific name is given (e.g., "Order Flow"), use `find_by_name` to locate relevant directories (e.g., `lib/features/orders`).
    - If a path is provided, use that as the anchor.
    - If ambiguous, search for key terms using `find_by_name` or `grep_search`.

2.  **Identify Entry Points**:
    - **Routing**: Search for where this page/module is registered in the routing (e.g., `app_router.dart` or `routes.dart`). This reveals *how* a user gets here.
    - **Usage**: Use `grep_search` to find where the main widget or class is instantiated.

**Tools to use:**
- `find_by_name`: Locate directories/files.
- `grep_search`: Find usages, routing registrations, and dependency injections.
- `list_dir`: Explore the structure.

## 2. Deep Technical Analysis

Perform a multi-layered analysis to understand the "What", "How", and "Why".

### A. Structure & Architecture
- **Layering**: Identify Presentation (UI), Domain (Logic/Entities), and Data (Repos/DTOs) layers.
- **Key Files**: Use `view_file_outline` to scan key files (Pages, Cubits/Blocs, Repositories).
- **Dependencies**: Note what other modules or core services this feature depends on.

### B. Flow Tracing (The "golden path")
Trace the primary user journey through the code:
1.  **UI Interaction**: Identify the interaction in the `build` method of the Page/Widget (e.g., `onPressed`).
2.  **State Handling**: specific `Cubit`/`Bloc` method called.
3.  **Domain Logic**: `UseCase` or logic executed.
4.  **Data Operation**: `Repository` method -> API/DB call.
5.  **State Update**: How the state changes (e.g., `emit(Success state)`).
6.  **UI Reaction**: How the UI updates (e.g., `BlocBuilder` showing a list).

### C. Data Modeling
- Examine `Entity` and `Model` classes to understand the data structure.
- **Tools:** `view_file` on files in `domain/entities` or `data/models`.

### D. "Why" & Business Logic
- **Intent**: Infer the business goal. *Why* does this exist?
- **Edge Cases**: Look for error handling (`catch` blocks, error states), loading states, and empty views.
- **Tests**: Check the `test/` directory for corresponding tests. This often reveals the expected behavior and edge cases.

## 3. Report Generation

Synthesize your findings into a structured Markdown report. The report **MUST** follow the format below.

### Report Format

```markdown
# [Module/Feature Name] Analysis Report

## 1. Executive Summary
**Audience:** Product Managers & Stakeholders
- **What is it?**: A high-level description of the module/flow (1-2 sentences).
- **Primary Goal**: What user problem does it solve?
- **Key Features**: Bullet points of main capabilities.
- **User Impact**: How does this improve the user experience?

## 2. Product Intent & User Flow
**Audience:** Product Managers & UX Designers
- **User Journey**: Step-by-step description of what the user does (e.g., 1. User clicks button, 2. Modal opens...).
- **Edge Cases**: How does it handle errors, empty states, or offline modes? (Inferred from code logic).
- **Key Decisions**: Notable product behaviors implemented in code (e.g., "Validation happens instantly," or "Data is cached offline").

## 3. Technical Implementation
**Audience:** Developers & Architects

### Architectural Overview
- **Pattern**: (e.g., Clean Architecture, MVVM).
- **Tech Stack**: Key libraries used (e.g., `flutter_bloc`, `dio`).
- **State Management**: Specific approach (e.g., "OrderCubit with Equatable states").

### Code Structure
- **Directory Breakdown**:
  - `presentation/`: UI components.
  - `domain/`: Business rules.
  - `data/`: API integration.
- **Key Classes**:
  - `[ClassName]`: Description of responsibility.

### Data Flow & Dependencies
- **Flow Diagram**:
  `UI Event` -> `Cubit` -> `UseCase` -> `Repo` -> `State Change`
- **Dependencies**: Internal (e.g., `AuthRepository`) and External (e.g., `permission_handler`) packages used.
- **Data Model**: Key entities involved.

## 4. "The Why" & Insights
- **Engineering Decisions**: Why is it built this way? (e.g., "Separated for testability").
- **Complexity Hotspots**: Identify complex parts (e.g., "Custom scroll logic").
- **Optimizations**: Performance or DX choices.
- **Possible Improvements**: (Optional) Quick observations on code quality or potential refactors.

## 5. Metadata
- **Location**: `[Path to module]`
- **Tests Found**: `[Yes/No - Path to tests]`
- **Generated**: `[Date]`
```

## Tips for Success

- **Trace, Don't Guess**: Use `grep_search` to verify where methods are called.
- **Find the "Why"**: Look at variable names, comments, and logic structure to understand the intent.
- **Check for Tests**: Existence of tests indicates critical logic.
- **Be Concise**: Summarize code behavior, don't just dump code.
