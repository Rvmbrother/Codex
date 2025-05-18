# Codex

## Build Instructions
1. Open **Codex.xcodeproj** in Xcode 16.
2. Select the *Codex* scheme.
3. Build or Run with `⌘B` or `⌘R`. The project has no external dependencies and should compile cleanly.

## Using the App
- The menu-bar icon shows your task list. Press **⌥⌘T** to toggle the window from anywhere.
- Tasks are read from `~/Documents/tasks.md`. Each line formatted as `[ ] Task` or `[x] Task` appears in the list.
- Checking or unchecking a task immediately rewrites `tasks.md`, so external edits are reflected next time the file is loaded.

Edit `tasks.md` with any text editor to manage your list.

