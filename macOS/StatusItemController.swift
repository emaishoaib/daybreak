import AppKit
import SwiftUI

@MainActor
final class StatusItemController: NSObject {
    private static let gap: CGFloat = 6
    private static let screenMargin: CGFloat = 8
    private static let reopenGuard: TimeInterval = 0.3

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let panel = PopUpPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: true)
    private var clickMonitor: Any?
    private var hiddenAt = Date.distantPast

    override init() {
        super.init()

        let content = NSHostingController(rootView: PopUpContent())
        content.sizingOptions = []
        panel.contentViewController = content
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.appearance = NSAppearance(named: .darkAqua)
        panel.onCancel = { [weak self] in
            self?.dismiss()
        }

        statusItem.expandedInterfaceDelegate = self
        statusItem.button?.image = Self.placeholderImage
    }

    private static var placeholderImage: NSImage {
        let image = NSImage(systemSymbolName: "sun.horizon", accessibilityDescription: "Daybreak") ?? NSImage()
        image.isTemplate = true
        return image
    }

    private var iconFrame: NSRect {
        guard let button = statusItem.button, let window = button.window else { return .zero }
        return window.convertToScreen(button.convert(button.bounds, to: nil))
    }

    private func frame() -> NSRect {
        let icon = iconFrame
        let size = PopUpContent.size
        var x = icon.midX - size.width / 2
        var height = size.height
        if let screen = statusItem.button?.window?.screen?.visibleFrame {
            x = min(max(x, screen.minX + Self.screenMargin), screen.maxX - size.width - Self.screenMargin)
            height = min(height, icon.minY - Self.gap - screen.minY - Self.screenMargin)
        }
        return NSRect(x: x, y: icon.minY - Self.gap - height, width: size.width, height: height)
    }

    private func show() {
        panel.setFrame(frame(), display: true)
        NSApp.activate()
        panel.makeKeyAndOrderFront(nil)

        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.dismiss()
            }
        }
    }

    private func dismiss() {
        guard let session = statusItem.expandedInterfaceSession else { return hide() }
        session.cancel()
    }

    private func hide() {
        if panel.isVisible {
            hiddenAt = .now
        }
        panel.orderOut(nil)
        if let clickMonitor {
            NSEvent.removeMonitor(clickMonitor)
            self.clickMonitor = nil
        }
    }
}

extension StatusItemController: @MainActor NSStatusItemExpandedInterfaceDelegate {
    func statusItem(_ statusItem: NSStatusItem, didBegin expandedInterfaceSession: NSStatusItemExpandedInterfaceSession) {
        guard Date.now.timeIntervalSince(hiddenAt) > Self.reopenGuard else { return expandedInterfaceSession.cancel() }
        show()
    }

    func statusItemDidEndExpandedInterfaceSession(_ statusItem: NSStatusItem, animated: Bool) {
        hide()
    }
}
