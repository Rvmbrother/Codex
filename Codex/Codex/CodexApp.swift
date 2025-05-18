import SwiftUI
import AppKit
import Carbon

@main
struct CodexApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            PreferencesView(appDelegate: appDelegate)
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private let popover = NSPopover()
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "checkmark.circle", accessibilityDescription: "Codex")
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
        registerHotKey()
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    private func registerHotKey() {
        let code = UserDefaults.standard.integer(forKey: "hotKeyKeyCode")
        let mods = UserDefaults.standard.integer(forKey: "hotKeyModifiers")
        registerHotKey(keyCode: UInt32(code == 0 ? Int(kVK_ANSI_T) : code), modifiers: UInt32(mods == 0 ? Int(cmdKey | optionKey) : mods))
    }

    private func registerHotKey(keyCode: UInt32, modifiers: UInt32) {
        var hotKeyID = EventHotKeyID(signature: 0x43445831, id: 1)
        let eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, event, userData in
            var hkID = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hkID)
            if hkID.id == 1, let ptr = userData {
                Unmanaged<AppDelegate>.fromOpaque(ptr).takeUnretainedValue().togglePopover()
            }
            return noErr
        }, 1, [eventSpec], UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), &eventHandler)
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }

    func updateHotKey(code: Int, modifiers: Int) {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        registerHotKey(keyCode: UInt32(code), modifiers: UInt32(modifiers))
    }
}
