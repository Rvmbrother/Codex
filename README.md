# Codex

## Build Instructions
### Xcode
1. Open **Codex.xcodeproj** in Xcode 16.
2. Select the *Codex* scheme.
3. Build or Run with `⌘B` or `⌘R`. The project has no external dependencies and should compile cleanly.

### Swift Package Manager
Run `swift build -c release` from the repository root. The package uses Swift 6.1 and targets macOS 15.5 or later.

## Using the App

- The menu-bar icon shows your task list. Press **⇧⌘E** to toggle the window from anywhere.
- When the window opens you see a list of Markdown files in `~/Documents/tasks`. Pick one to view its tasks.
 - The window can be resized like a normal macOS window and floats above full-screen apps so it's always accessible.
- Lines containing `[ ]` or `[x]` become interactive checkboxes. Checking or unchecking immediately writes the change back to the selected file.

- Append a duration in curly braces, e.g. `{15m}`, `{1h30m}` or `{2d}`, to display the allocated time for a task. The value appears beside the task whenever the window opens.
- The list refreshes when the window becomes active so any time changes are shown immediately.


 - Lines beginning with a dash (`-`) are displayed without the bullet for a cleaner list.

The pop-up window title now shows the selected list name so you always know which file you're editing. Closing the list sets the title back to **Codex**.

Add or edit `.md` files inside the `tasks` folder with any text editor to manage your lists.

