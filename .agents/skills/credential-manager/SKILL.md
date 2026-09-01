---
name: credential-manager
description: |
  Use this skill when you need to authenticate, log in, or retrieve credentials (username/password/API keys) for a service (e.g., Figma, GitHub, Jira).
  Triggers on: "login required", "need password", "credentials missing", "authenticate", "sign in".
---

# Credential Manager

Manage and retrieve login credentials securely. If credentials are not found locally, ask the user and store them for future use.

## When to Use This Skill

Activate when:
- A tool or URL requires authentication (e.g., 401/403 errors).
- You need a username/password to proceed with a task.
- The user explicitly asks you to "login" or "remember my password".

## When NOT to Use This Skill

- Do NOT use for one-time tokens that expire immediately (unless renewable).
- Do NOT use if the system already has a dedicated auth tool (e.g., `gh auth login`).

## Prerequisites

- Read/Write access to `.agent/secrets/credentials.json`.

## Instructions

### Step 1: Check Local Storage
1.  Check if `.agent/secrets/credentials.json` exists.
2.  If it exists, read it and look for the service name (e.g., "figma", "jira").
    *   Key format: `{"service_name": {"username": "...", "password": "..."}}`
3.  If credentials are found, **STOP** and use them.

### Step 2: Request Credentials (If Missing)
1.  If the file doesn't exist or the service is missing:
    *   Call `notify_user` to request credentials.
    *   **Message**: "I need login credentials for [Service Name] to proceed. Please provide the Username and Password."
    *   **BlockedOnUser**: `true`.

### Step 3: Store Credentials
1.  Once the user provides the credentials (in their response):
    *   Read the existing `.agent/secrets/credentials.json` (or create empty dict `{}`).
    *   Update the JSON with the new service credentials.
    *   Write the updated JSON back to `.agent/secrets/credentials.json`.
    *   **Constraint**: Ensure this file is added to `.gitignore` if it's not already (ask user or check).

### Step 4: Verify
1.  Retry the action that required login with the new credentials.

## Constraints

- **SECURITY**: Never output passwords in plain text in the final "Task Summary" or logs unless absolutely necessary for a command (and even then, mask if possible).
- **GIT**: Always check/ensure `.agent/secrets/` is in `.gitignore` to prevent accidental commits.

## Examples

### Example 1: Figma Login
**Input:** "I need to access Figma but it's redirecting to login."
**Action:**
1.  Check `.agent/secrets/credentials.json`.
2.  Not found.
3.  Notify User: "Please provide Figma credentials."
4.  User responds: "User: bob, Pass: secret123".
5.  Write to `credentials.json`: `{"figma": {"username": "bob", "password": "secret123"}}`.
6.  Retry Figma access.
