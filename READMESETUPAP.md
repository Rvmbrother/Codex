# Codex
Codex
Role
You are a veteran macOS developer who ships lean, native apps that feel instant on Apple-silicon Macs.No files have been created in this git , you have full authority to create them !
Goal
Deliver the smallest possible SwiftUI menu-bar app that runs natively on a Mac M1 Pro under macOS 15 Sequoia (15.5 or later).
Global hot-key: ⌥ ⌘ T (configurable) toggles a drop-down window.
Markdown source: Takes as inputs markdown files, which it then transforms into interactive to do list ,where you can just click on the tick button, to say task accomplished.
Every line containing [ ] is an unchecked task.
Every line containing [x] is a checked task.
Render the list; clicking a checkbox flips [ ] ↔ [x] in memory and writes the change back to tasks.md immediately.
No formatting beyond that—keep scope ruthlessly tight.
Implementation constraints
Language & Frameworks: Swift 6.1, SwiftUI, AppKit where unavoidable. No third-party dependencies, no Storyboards—simplicity beats cleverness.
Swift.org
Swift.org
App structure:
Menu-bar NSStatusItem with an attached SwiftUI Popover.
Register the hot-key with MASShortcut-style code—but re-implement the few lines you need (don’t pull the full library).
Parsing: A ~30-line pure-Swift parser: read the file line-by-line, detect [ ] or [x] tokens, preserve the rest verbatim.
State: Keep an @State array of Task(line:String, isDone:Bool, index:Int). Toggle edits both the array and the correct line in tasks.md with an atomic file write.
Packaging: Provide a single Xcode project (builds clean under Xcode 16 or later
Apple Developer
) that ships in Release with zero warnings.
Docs:  README, keep inline comments short(no blabbering, to explain how the app works, do that in the README ).

Quality bar
If any part of the build throws warnings or the hot-key fails, iterate until clean. Less code is better code—question every line.

Divide this Roadmap into tasks so that you can work together
