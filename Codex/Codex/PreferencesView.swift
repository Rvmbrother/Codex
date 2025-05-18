import SwiftUI
import Carbon

struct PreferencesView: View {
    @AppStorage("hotKeyKeyCode") private var keyCode: Int = Int(kVK_ANSI_E)
    @AppStorage("hotKeyModifiers") private var modifiers: Int = Int(cmdKey | shiftKey)

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
        Form {
            Picker("Key", selection: $keyCode) {
                ForEach(keyOptions, id: \.1) { pair in
                    Text(pair.0).tag(Int(pair.1))
                }
            }
            Toggle("Command (⌘)", isOn: modifierBinding(cmdKey))
            Toggle("Option (⌥)", isOn: modifierBinding(optionKey))
            Toggle("Shift (⇧)", isOn: modifierBinding(shiftKey))
            Toggle("Control (⌃)", isOn: modifierBinding(controlKey))
        }
        .padding(20)
        .onChange(of: keyCode) { _ in
            saveAndApply()
        }
        .onChange(of: modifiers) { _ in
            saveAndApply()
        }
        .frame(width: 200)
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
