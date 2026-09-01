---
name: figma-extractor
description: |
  Use this skill to extract Figma design tokens into a standardized, code-free design report.
  Triggers on: "analyze figma", "extract design", "create design report", "figma analysis", "design specs".
  Context: Use this whenever the user provides Figma HTML/CSS or screenshots and asks for design specifications.
---

# Figma Extractor Skill

**Purpose:** Transform raw Figma data (HTML/CSS extraction) into a "Gold Standard" implementation report that strictly uses the project's theme tokens.

## When to Use This Skill
Activate when the user:
- Provides an HTML snippet from Figma (via "Copy as CSS" or similar).
- Asks to "extract design" or "analyze design" for a component.
- Needs a precise specification of Colors, Typography, and Spacing before coding.

## When NOT to Use This Skill
- Do NOT use if the user asks for *actual Flutter code* (Widgets, build methods). This skill is for **Analysis & Reporting** only.
- Do NOT use for general Flutter questions unrelated to design extraction.

## Prerequisites
- Knowledge of `WebColors` and `WebTextStyles` (found in `lib/src/presentation/theme/`).
- Knowledge of `paddingX` constants (found in `fs_ui_kit/lib/src/atoms/padding.dart` or similar).

---

## Instructions

### Step 1: Senior Expert Analysis & Structure Decoding
**Goal:** Understand the "What", "Why", and "How it is Structured" WITHOUT MISSING ANYTHING.

1.  **Unique Variant Discovery (Deep Scan Protocol):**
    - You MUST scan the **entire input HTML/Description**, not just the first few lines or the first table row.
    - **Iterate** through every repeating element.
    - **Superset Extraction:** Your report must include the *Superset* of all found variants.

2.  **Structural Breakdown & Column Association (The "Index" Rule):**
    - **Problem:** HTML often visually separates Headers from Data rows (they are siblings).
    - **Solution:** You MUST use **Index-Based Matching**.
        - If "Status" is the **4th element** in the Header Row...
        - Then the **4th element** in *every Data Row* is a "Status Value".
    - **Semantic Verification:**
        - Verify your match: Does the text ("Pending") make sense for the column ("Status")?
        - If yes, record "Pending" as a variant of the "Status" column.

3.  **Extraction:**
    - Extract ALL raw values: Hex, Fonts, Spacing, Shadows, Border Radius, Opacity.

4.  **Icon & Asset Analysis (Decision Protocol):**
    - Identify all icons (look for `<svg>` tags, layer names like `icon`, `vector`, `glyph`).
    - **Scenario A (Re-used):** Does it match an existing asset in `SetuCareAssets` (e.g., `edit`, `delete`) or a standard Material Icon?
    - **Scenario B (New):** If no match, it must be exported as a new SVG.

### Step 2: Token Mapping (CRITICAL)
You **MUST** map raw values to project tokens.

**A. Colors (`context.colors`)**
- Refer to `WebColors` and `AppColorsExtension`.
- Example: `#005777` -> `context.colors.primary`
- Example: `#E6EEF1` -> `context.colors.primaryContainer`

**B. Typography (`context.textStyles`)**
- Map to `WebTextStyles`.
    - `10px` -> `labelSmall`
    - `12px` -> `bodySmall`
    - `14px` -> `bodyMedium`
    - `16px` -> `titleMedium`
    - `20px` -> `titleLarge`
- **Modifiers:** `.bold`, `.semiBold`, `.medium`.

**C. Spacing (`paddingX`)**
- Map raw pixels to closest `paddingX` constant (e.g., `8px` -> `padding8`).

**D. Icons & Assets (The 2-Flow Rule)**
- **Flow 1 (Re-used):** Map to `SetuCareAssets.[name]` or `Icons.[name]`.
- **Flow 2 (New):**
    - Create a subdirectory: `design_specs/assets/[report_name]/`.
    - Extract the SVG content from the HTML.
    - Save it as `design_specs/assets/[report_name]/[name].svg`.
    - Reference this path in the report.

### Step 3: Report Generation (Workspace Integration)
You **MUST** create a new `.md` file in the user's workspace, specifically in the `design_specs/` directory.

1.  **Define Path:** `design_specs/[component_name]_specs.md` (e.g., `design_specs/order_table_specs.md`).
2.  **Create Directory:** If `design_specs/` does not exist, you must create it.
3.  **Write Content:** Write the full report to this file using the `write_to_file` tool.
4.  **Confirm:** Tell the user specifically where the file is located (e.g., "Report saved to `design_specs/order_table_specs.md`").

**Structure:**
1.  **Overview & Breakdown:** What is it? How is it structured?
2.  **Table/Grid System:** Detailed column config.
3.  **Exhaustive Variants & States:** The result of your "Deep Scan".
4.  **Detailed Specs:** Nested sections (Container -> Header -> Body).
    - **Every Pixel Rule:** detailed borders, shadows, divider lines.

---

## Report Template (Strictly Follow This)

```markdown
# Figma Analysis: [Component Name]

## 1. Design Overview
**Component:** [Name]
**Purpose:** [Brief specific description]

### Structural Breakdown
- **Layout Model:** [e.g. Table with 12 Columns]
- **Key Regions:** [Header, Body, Footer]

### Discovered Content Variants (Deep Scan Results)
*List all unique permutations found in the data.*
- **Status Types Found:** [Active, Pending, Delivered, Cancelled]
- **Action Types Found:** [Edit Button, View Icon, Toggle Switch]
- **Text Variations:** [Normal, Bold ID, Italic Note]

## 2. Layout & Grid Configuration (For Tables/Grids)
*Map the exact column structure.*

| Column/Region | Sizing | Alignment | Notes |
| :--- | :--- | :--- | :--- |
| **Action** | Fixed (105px) | Center | |
| **Order No** | Flex (1) | Left | |

## 3. High-Level Variants & States (Senior POV)
*Map EVERY logical state found or implied.*

| State/Variant | Background Token | Text Token | Notes |
| :--- | :--- | :--- | :--- |
| **Active** | `context.colors.primary` | `context.colors.onPrimary` | Found in Row 1 (Col 4) |
| **Pending** | `context.colors.warning20` | `context.colors.warning` | Found in Row 4 (Col 4) |

## 4. Detailed Specifications

### A. Container / Wrapper
| Property | Value | Implementation |
| :--- | :--- | :--- |
| **Background** | [Color Description] | `context.colors.[token]` |
| **Border Radius** | [Pixels] | `BorderRadius.circular([n])` |
| **Border** | [Color/Width] | `Border.all(color: context.colors.[token])` |

### B. Header / Top Section
| Property | Value | Implementation |
| :--- | :--- | :--- |
| **Height** | [Pixels] | `height: [n]` |
| **Padding** | [Pixels] | `padding[n]` |

**Typography:**
- **Title:** `context.textStyles.[token].[modifier]` (Color: `[token]`)

### C. [Next Section]
...
### C. [Next Section]
...

## 5. Assets & Icons

## 5. Assets & Icons

| Icon Name (Figma) | Scenario | Where it is used? | Implementation Code | Source Path (New) |
| :--- | :--- | :--- | :--- | :--- |
| **Download** | ✅ Re-used | Header / Action Row | `SetuCareAssets.downloadIcon` | N/A |
| **Chevron Down** | 🆕 New | Product Card / Expand | `SvgPicture.asset('...')` | `assets/[report]/chevron_down.svg` |
```

---

## Constraints

- **ALWAYS** save the report to `design_specs/` in the workspace root.
- **NEVER** save only to the internal `brain/` directory.
- **NEVER** include "Smart Code Snippets".
- **NEVER** miss a variant. Scan the whole input.
- **NEVER** use hardcoded Hex colors. ALWAYS use `context.colors`.
- **ALWAYS** check for `paddingX` constants.

## Quality Checklist
- [ ] Did you use Index-Based Matching for columns?
- [ ] Is the file path in `design_specs/`?
- [ ] Did you scan the ENTIRE input for unique variants?
- [ ] Are ALL found Status types listed in the Variants table?
- [ ] Is every single pixel (shadows, borders) accounted for?
