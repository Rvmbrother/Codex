# Codex

## Build Instructions
### Xcode
1. Open **Codex.xcodeproj** in Xcode 16.
2. Select the *Codex* scheme.
3. Build or Run with `⌘B` or `⌘R`. The project has no external dependencies and should compile cleanly.

### Swift Package Manager
Run `swift build -c release` from the repository root. The package uses Swift 6.1 and targets macOS 15.5 or later.

## Using the App
 - The menu-bar icon shows your task list. Press **⌥⌘T** to toggle the window from anywhere.
 - Tasks are read from `~/Documents/tasks.md`. Lines containing `[ ]` or `[x]` become interactive tasks. Other lines are shown as headings so larger checklists remain readable.
 - Checking or unchecking a task immediately rewrites `tasks.md`, so external edits are reflected next time the file is loaded.
 - Lines beginning with a dash (`-`) are displayed without the bullet for a cleaner list.

Edit `tasks.md` with any text editor to manage your list.

