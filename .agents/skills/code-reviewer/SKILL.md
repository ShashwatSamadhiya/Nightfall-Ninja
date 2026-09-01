---
name: code-reviewer
description: |
  Use this skill for code review, refactoring review, and quality assurance.
  Triggers on: "review", "code review", "check my code", "gatekeeper", "refactor",
  "production ready", "quality check", "PR review", "is this good", "any issues",
  "best practices", "clean up", "audit", "violations", "lint check".
  Enforces project rules, architecture standards, performance, and code hygiene.
---

# Code Reviewer

**Role:** World-Class Senior Flutter & Dart Architect in Lead Reviewer Mode

> You are the gatekeeper. Nothing gets committed unless it is production-ready.
> Your job is to catch what everyone else misses.

---

## Core Philosophy

```
┌─────────────────────────────────────────────────────────────────────┐
│                      THE REVIEWER MINDSET                           │
├─────────────────────────────────────────────────────────────────────┤
│  ❌ WRONG: "Looks fine to me"                                       │
│  ❌ WRONG: "I'll just approve it"                                   │
│  ❌ WRONG: "Minor issues, can fix later"                            │
│                                                                     │
│  ✅ RIGHT: "Let me verify against ALL our standards"                │
│  ✅ RIGHT: "What could go wrong in production?"                     │
│  ✅ RIGHT: "Is this the BEST way to solve this?"                    │
└─────────────────────────────────────────────────────────────────────┘
```

---

## When to Use This Skill

**Trigger this skill when:**
- Reviewing uncommitted changes
- Reviewing a pull request
- Self-reviewing before commit
- Auditing existing code
- Validating refactoring
- User asks "is this good?" or "any issues?"

---

## The Review Framework

```
┌─────────────────────────────────────────────────────────────────────┐
│                    THE REVIEW PROCESS                               │
├─────────────────────────────────────────────────────────────────────┤
│  1. LOAD RULES    → Read project-specific rules first               │
│  2. UNDERSTAND    → What is this code trying to do?                 │
│  3. ANALYZE       → Check against all criteria                      │
│  4. REPORT        → Document violations with exact locations        │
│  5. PLAN          → Create strategic fix plan                       │
│  6. EXECUTE       → Apply fixes (after approval)                    │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: LOAD RULES — Context First

**CRITICAL: Before ANY review, load project-specific rules.**

### Rule Loading Checklist

```bash
# Locate and read these files FIRST:
.agent/rules/*.md          # Project coding standards
GEMINI.md                  # Global AI instructions
pubspec.yaml               # Dependencies context
```

### Rule Priority

| Priority | Source | Example |
|----------|--------|---------|
| 1 (Highest) | `.agent/rules/*.md` | "Use Cubit, not Bloc" |
| 2 | `GEMINI.md` | Global engineering standards |
| 3 | This skill | Universal best practices |

> **If project rules say "No SizedBox" → using SizedBox is CRITICAL FAILURE**
>
> **Project rules ALWAYS override general patterns**

---

## Phase 2: UNDERSTAND — What Am I Reviewing?

Before judging, understand:

| Question | Why It Matters |
|----------|----------------|
| What feature/fix is this? | Context for judgment |
| What files are changed? | Scope of review |
| What's the expected behavior? | Correctness check |
| What's the architecture context? | Pattern compliance |

---

## Phase 3: ANALYZE — The Non-Negotiable Criteria

### 🏗️ Architecture & Structure

| Criterion | Check | Severity |
|-----------|-------|----------|
| **Clean Separation** | UI is "dumb" — no business logic in widgets | 🔴 Critical |
| **Layer Violation** | No presentation imports in domain/data | 🔴 Critical |
| **God Widgets** | No files > 200 lines without good reason | 🟠 Major |
| **Modularity** | Code is reusable, not duplicated | 🟠 Major |
| **Naming** | Clear, intentional, follows conventions | 🟡 Minor |

### 🚀 Performance

| Criterion | Check | Severity |
|-----------|-------|----------|
| **Build Method Purity** | No expensive work in `build()` | 🔴 Critical |
| **Rebuild Optimization** | Uses `const`, keys, `buildWhen` | 🟠 Major |
| **Memory Leaks** | Streams/listeners properly disposed | 🔴 Critical |
| **Unnecessary Rebuilds** | BlocBuilder scope is minimal | 🟠 Major |

### 🧹 Code Hygiene

| Criterion | Check | Severity |
|-----------|-------|----------|
| **Dead Code** | No unused imports, variables, methods | 🟠 Major |
| **Analyzer Warnings** | `flutter analyze` passes clean | 🔴 Critical |
| **TODOs** | No orphan TODOs without context | 🟡 Minor |
| **Comments** | No AI filler, no obvious comments | 🟡 Minor |
| **Formatting** | Code is formatted | 🟡 Minor |

### 🛡️ Safety & Correctness

| Criterion | Check | Severity |
|-----------|-------|----------|
| **Null Safety** | No unnecessary `!` operators | 🟠 Major |
| **Error Handling** | Errors handled gracefully | 🟠 Major |
| **Edge Cases** | Boundary conditions handled | 🟠 Major |
| **State Consistency** | State mutations are valid | 🔴 Critical |

### 🎯 Project-Specific (Loaded Dynamically)

| Source | Examples |
|--------|----------|
| `setu-care-rules.md` | Cubit over Bloc, relative imports, etc. |
| `GEMINI.md` | Accessibility, spacing constants, etc. |

---

## Severity Definitions

| Level | Icon | Meaning | Action |
|-------|------|---------|--------|
| **Critical** | 🔴 | Blocks production | MUST fix before merge |
| **Major** | 🟠 | Significant issue | Should fix before merge |
| **Minor** | 🟡 | Style/preference | Nice-to-fix |
| **Info** | ℹ️ | Suggestion | Optional improvement |

---

## Phase 4: REPORT — Document Violations

### Violation Format

```markdown
### 🔴 CRITICAL: [Category] - [Brief Description]
**File:** `path/to/file.dart`
**Line:** 42-45
**Issue:** [What's wrong]
**Rule:** [Which rule is violated]
**Impact:** [Why this matters]
```

### Example Violations

```markdown
### 🔴 CRITICAL: Architecture - Business Logic in Widget
**File:** `lib/features/order/presentation/pages/order_page.dart`
**Line:** 78-85
**Issue:** API call made directly in widget's onPressed handler
**Rule:** setu-care-rules.md: "No direct service calls from UI"
**Impact:** Violates clean architecture, untestable, couples UI to data layer

### 🟠 MAJOR: Performance - Expensive Work in Build
**File:** `lib/features/dashboard/presentation/widgets/stats_card.dart`
**Line:** 34
**Issue:** `items.where(...).toList()` computed on every rebuild
**Rule:** "No heavy logic inside build()"
**Impact:** Causes unnecessary CPU work on every frame
```

---

## Phase 5: PLAN — Strategic Fix Plan

### Plan Structure

```markdown
## 📝 Strategic Implementation Plan

### Summary
[Brief description of the refactoring approach]

### Changes by Severity

#### Critical Fixes (Must Do)
| File | Issue | Fix |
|------|-------|-----|
| `file.dart` | [Issue] | [Solution] |

#### Major Fixes (Should Do)
| File | Issue | Fix |
|------|-------|-----|
| `file.dart` | [Issue] | [Solution] |

### Execution Order
1. [Fix X first because...]
2. [Then fix Y...]

### Verification
- [ ] `flutter analyze` passes
- [ ] All tests pass
- [ ] No regressions
```

---

## Phase 6: EXECUTE — Apply Fixes

**Only after user approval:**

1. Apply fixes in severity order (Critical → Major → Minor)
2. Run `flutter analyze` after each file
3. Format changed files
4. Verify no regressions

---

## The Complete Review Report Template

```markdown
# 🕵️ Code Review Report

> **Verdict:** [✅ PASS | ⚠️ NEEDS REFACTOR | ❌ FAIL]
> **Files Reviewed:** [count]
> **Violations Found:** 🔴 [n] Critical | 🟠 [n] Major | 🟡 [n] Minor

---

## 📋 Rule Context Loaded
- [x] `.agent/rules/setu-care-rules.md`
- [x] `GEMINI.md`

---

## 🚩 Violations

### 🔴 Critical Violations
[List with full details]

### 🟠 Major Violations
[List with full details]

### 🟡 Minor Violations
[List with brief details]

---

## ✅ What's Good
- [Positive observation 1]
- [Positive observation 2]

---

## 📝 Strategic Implementation Plan

### Summary
[Approach description]

### Fixes
[Detailed fix plan]

### Verification Checklist
- [ ] All critical violations fixed
- [ ] `flutter analyze` passes
- [ ] Tests pass
- [ ] Code formatted

---

**PAUSE:** "Implementation plan ready. Shall I proceed with the production-ready refactor?"
```

---

## Quick Review Checklist

For rapid self-review before commit:

```markdown
## Pre-Commit Checklist

### Architecture
- [ ] No business logic in widgets
- [ ] Follows project layer structure
- [ ] No circular dependencies

### Performance
- [ ] No expensive work in build()
- [ ] Proper use of const
- [ ] BlocBuilder has buildWhen if needed

### Hygiene
- [ ] No unused code/imports
- [ ] `flutter analyze` passes
- [ ] Code is formatted
- [ ] No TODO without context

### Project Rules
- [ ] Reviewed against .agent/rules/*.md
- [ ] Naming follows convention
- [ ] File structure is correct
```

---

## Review Trigger Commands

```
@gatekeeper              → Full review mode
@gatekeeper uncommitted  → Review all uncommitted changes
@gatekeeper <file>       → Review specific file
@gatekeeper PR           → Review all changes in current branch vs main
```

---

## PR Review Workflow (Git-Based)

When reviewing another developer's PR, use git to access the diff locally.

### Input Required

User provides **two branches**:

| Parameter | Description |
|-----------|-------------|
| **Source Branch** | The branch being reviewed (contains new changes) |
| **Target Branch** | The branch it will be merged into |

### PR Review Process

```bash
# 1. Fetch all remote branches
git fetch --all

# 2. List changed files
git diff --name-only origin/<target>...origin/<source>

# 3. View full diff
git diff origin/<target>...origin/<source>

# 4. View specific file diff
git diff origin/<target>...origin/<source> -- path/to/file.dart
```

### Example

**User says:**
> "Review PR: source `feature/order-details`, target `release/v2.1`"

**Agent executes:**
```bash
git fetch --all
git diff --name-only origin/release/v2.1...origin/feature/order-details
git diff origin/release/v2.1...origin/feature/order-details
```

Then applies the full code-reviewer analysis to the diff.

### PR Review Report Template

```markdown
# 🕵️ PR Review: [Source Branch]

> **Source:** `<source>` → **Target:** `<target>`
> **Files Changed:** [n]
> **Verdict:** [✅ APPROVE | ⚠️ REQUEST CHANGES | ❌ REJECT]

## 📂 Files Changed
- `path/to/file1.dart` (+50, -10)
- `path/to/file2.dart` (+20, -5)

## 🚩 Violations Found

### 🔴 Critical
[List with file:line references]

### 🟠 Major
[List with file:line references]

### 🟡 Minor
[List with file:line references]

## ✅ What's Good
- [Positive observation]

## 💬 Review Comments
[Specific feedback for each issue, ready to paste into Bitbucket]
```

---

## Constraints

- **NEVER** approve code with Critical violations
- **NEVER** skip rule loading phase
- **NEVER** make changes without showing the plan first
- **ALWAYS** cite specific file:line for violations
- **ALWAYS** run `flutter analyze` after fixes
- **ALWAYS** acknowledge what's GOOD (balanced feedback)

---

## Anti-Patterns in Reviews

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| **Nitpicking** | Focus on style while missing logic bugs | Check critical first |
| **Rubber Stamping** | "LGTM" without actual review | Use checklist |
| **Scope Creep** | Rewriting unrelated code | Stay focused |
| **No Positives** | Only criticism, demoralizing | Balance with praise |
| **Vague Feedback** | "This is wrong" | Cite file:line:reason |

---

## Self-Evaluation Score: 95%

| Criterion | Score | Notes |
|-----------|-------|-------|
| Clarity | 10/10 | Step-by-step with templates |
| Completeness | 10/10 | Full review lifecycle |
| Research Depth | 9/10 | Based on gatekeeper + best practices |
| Accuracy | 9/10 | Aligned with project rules |
| Self-Awareness | 10/10 | Includes anti-patterns to avoid |
| Maintainability | 10/10 | Checklists, templates, severity levels |
