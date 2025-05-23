import SwiftUI
import Carbon

struct PreferencesView: View {

    @AppStorage("hotKeyKeyCode") private var keyCode: Int = Int(kVK_ANSI_E)
    @AppStorage("hotKeyModifiers") private var modifiers: Int = Int(cmdKey | shiftKey)
    @AppStorage("colorScheme") private var colorScheme: String = "dark"


    var appDelegate: AppDelegate

    private let keyOptions: [(String, UInt32)] = [
        ("A", UInt32(kVK_ANSI_A)),
        ("B", UInt32(kVK_ANSI_B)),
        ("C", UInt32(kVK_ANSI_C)),
        ("D", UInt32(kVK_ANSI_D)),
        ("E", UInt32(kVK_ANSI_E)),
        ("F", UInt32(kVK_ANSI_F)),
        ("G", UInt32(kVK_ANSI_G)),
        ("H", UInt32(kVK_ANSI_H)),
        ("I", UInt32(kVK_ANSI_I)),
        ("J", UInt32(kVK_ANSI_J)),
        ("K", UInt32(kVK_ANSI_K)),
        ("L", UInt32(kVK_ANSI_L)),
        ("M", UInt32(kVK_ANSI_M)),
        ("N", UInt32(kVK_ANSI_N)),
        ("O", UInt32(kVK_ANSI_O)),
        ("P", UInt32(kVK_ANSI_P)),
        ("Q", UInt32(kVK_ANSI_Q)),
        ("R", UInt32(kVK_ANSI_R)),
        ("S", UInt32(kVK_ANSI_S)),
        ("T", UInt32(kVK_ANSI_T)),
        ("U", UInt32(kVK_ANSI_U)),
        ("V", UInt32(kVK_ANSI_V)),
        ("W", UInt32(kVK_ANSI_W)),
        ("X", UInt32(kVK_ANSI_X)),
        ("Y", UInt32(kVK_ANSI_Y)),
        ("Z", UInt32(kVK_ANSI_Z))
    ]

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "gear")
                    .font(.system(size: 24))
                    .foregroundColor(Color.blue.opacity(0.8))
                Text("Preferences")
                    .font(.system(size: 16, weight: .semibold))
            }
            .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 16) {
                // Hotkey section
                VStack(alignment: .leading, spacing: 12) {
                    Label("Keyboard Shortcut", systemImage: "keyboard")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(NSColor.labelColor))
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Key:")
                                .font(.system(size: 12))
                                .foregroundColor(Color(NSColor.secondaryLabelColor))
                                .frame(width: 60, alignment: .leading)
                            
                            Picker("", selection: $keyCode) {
                                ForEach(keyOptions, id: \.1) { pair in
                                    Text(pair.0)
                                        .font(.system(size: 12, weight: .medium))
                                        .tag(Int(pair.1))
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 60)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Modifiers:")
                                .font(.system(size: 12))
                                .foregroundColor(Color(NSColor.secondaryLabelColor))
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Toggle(isOn: modifierBinding(cmdKey)) {
                                    Label("Command ⌘", systemImage: "command")
                                        .font(.system(size: 12))
                                }
                                .toggleStyle(SwitchToggleStyle(tint: Color.blue.opacity(0.8)))
                                
                                Toggle(isOn: modifierBinding(optionKey)) {
                                    Label("Option ⌥", systemImage: "option")
                                        .font(.system(size: 12))
                                }
                                .toggleStyle(SwitchToggleStyle(tint: Color.blue.opacity(0.8)))
                                
                                Toggle(isOn: modifierBinding(shiftKey)) {
                                    Label("Shift ⇧", systemImage: "shift")
                                        .font(.system(size: 12))
                                }
                                .toggleStyle(SwitchToggleStyle(tint: Color.blue.opacity(0.8)))
                                
                                Toggle(isOn: modifierBinding(controlKey)) {
                                    Label("Control ⌃", systemImage: "control")
                                        .font(.system(size: 12))
                                }
                                .toggleStyle(SwitchToggleStyle(tint: Color.blue.opacity(0.8)))
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
                    .cornerRadius(8)
                }
                
                Divider()
                
                // Appearance section
                VStack(alignment: .leading, spacing: 12) {
                    Label("Appearance", systemImage: "paintbrush")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(NSColor.labelColor))
                    
                    Picker("", selection: $colorScheme) {
                        Label("System", systemImage: "laptopcomputer")
                            .font(.system(size: 12))
                            .tag("system")
                        Label("Light", systemImage: "sun.max")
                            .font(.system(size: 12))
                            .tag("light")
                        Label("Dark", systemImage: "moon.fill")
                            .font(.system(size: 12))
                            .tag("dark")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(4)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
                    .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding(20)
        .frame(width: 280, height: 420)
        .background(Color(NSColor.windowBackgroundColor))
        .onChange(of: keyCode) { _ in
            saveAndApply()
        }
        .onChange(of: modifiers) { _ in
            saveAndApply()
        }
        .onChange(of: colorScheme) { newScheme in
            // Update the window appearance
            if let window = NSApp.keyWindow {
                switch newScheme {
                case "dark":
                    window.appearance = NSAppearance(named: .darkAqua)
                case "light":
                    window.appearance = NSAppearance(named: .aqua)
                default:
                    window.appearance = nil
                }
            }
        }
    }

    private func modifierBinding(_ flag: Int) -> Binding<Bool> {
        Binding<Bool>(
            get: { (modifiers & flag) != 0 },
            set: { newValue in
                if newValue {
                    modifiers |= flag
                } else {
                    modifiers &= ~flag
                }
            }
        )
    }

    private func saveAndApply() {
        appDelegate.updateHotKey(code: keyCode, modifiers: modifiers)
    }
}
