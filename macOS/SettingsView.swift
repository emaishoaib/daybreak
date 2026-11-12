import Observation
import SwiftUI

@MainActor
@Observable
final class SettingsPage {
    static let shared = SettingsPage()

    var isShown = false
}

struct SettingsButton: View {
    var body: some View {
        Button {
            SettingsPage.shared.isShown = true
        } label: {
            Image(systemName: "gearshape")
        }
        .buttonStyle(.borderless)
        .foregroundStyle(.secondary)
        .accessibilityLabel("Settings")
    }
}

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    SettingsPage.shared.isShown = false
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            Form {
                Section("Menu bar") {
                    MenuBarLayoutPicker()
                    MenuBarPartToggles()
                }
                Section("Travel") {
                    SmartSwapToggle()
                }
                Section {
                    VersionRow()
                    LabeledContent("Earth imagery", value: "NASA Earth Observatory")
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Palette.night)
    }
}

private struct MenuBarLayoutPicker: View {
    @AppStorage(MenuBarLayout.key) private var layout = MenuBarLayout.stacked

    var body: some View {
        Picker("Layout", selection: $layout) {
            ForEach(MenuBarLayout.allCases, id: \.self) { option in
                Text(option.name)
                    .tag(option)
            }
        }
        .pickerStyle(.radioGroup)
    }
}

private struct MenuBarPartToggles: View {
    @AppStorage(MenuBarLayout.key) private var layout = MenuBarLayout.stacked

    var body: some View {
        if layout != .calendarPage {
            ForEach(MenuBarPart.allCases, id: \.self) { part in
                MenuBarPartToggle(part: part)
            }
        }
    }
}

private struct MenuBarPartToggle: View {
    let part: MenuBarPart

    @AppStorage private var isShown: Bool

    init(part: MenuBarPart) {
        self.part = part
        _isShown = AppStorage(wrappedValue: true, part.key)
    }

    var body: some View {
        Toggle(part.name, isOn: $isShown)
    }
}

private struct VersionRow: View {
    var body: some View {
        LabeledContent("Version", value: "\(Self.info("CFBundleShortVersionString")) (\(Self.info("CFBundleVersion")))")
    }

    private static func info(_ key: String) -> String {
        Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
    }
}
