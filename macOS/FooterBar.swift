import AppKit
import SwiftUI

struct FooterBar: View {
    var body: some View {
        HStack {
            Spacer()
            Button("Quit Daybreak") { NSApplication.shared.terminate(nil) }
                .keyboardShortcut("q")
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
