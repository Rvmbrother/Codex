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
 - When the window opens you see a list of Markdown files in `~/Documents/tasks`. Pick one to view its tasks.
 - Lines containing `[ ]` or `[x]` become interactive checkboxes. Checking or unchecking immediately writes the change back to the selected file.

 - Lines beginning with a dash (`-`) are displayed without the bullet for a cleaner list.


Add or edit `.md` files inside the `tasks` folder with any text editor to manage your lists.

