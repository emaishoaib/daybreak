import AppKit
import Observation
import SwiftUI

@MainActor
final class StatusItemController: NSObject {
    private static let gap: CGFloat = 6
    private static let screenMargin: CGFloat = 8
    private static let reopenGuard: TimeInterval = 0.3
    private static let resizeDuration: TimeInterval = 0.3

    private let zones = ZoneList()
    private let moment = ChosenMoment()
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let panel = PopUpPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: true)
    private var content: NSHostingController<PopUpContent>?
    private var clickMonitor: Any?
    private var hiddenAt = Date.distantPast

    override init() {
        super.init()

        let content = NSHostingController(rootView: PopUpContent(zones: zones, moment: moment))
        content.sizingOptions = []
        let container = NSView()
        content.view.frame = container.bounds
        content.view.autoresizingMask = [.width, .height]
        container.addSubview(content.view)
        panel.contentView = container
        self.content = content
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
        updateImage()
        observeLayout()
        observeHere()
        Here.shared.onTravel = { [weak self] left, arrived in
            guard UserDefaults.standard.bool(forKey: SmartSwapSetting.key) else { return }
            self?.zones.travel(leaving: left, arrivingIn: arrived.identifier)
        }
        Task { await Here.shared.refresh() }
        for name in [UserDefaults.didChangeNotification, .NSCalendarDayChanged, .NSSystemTimeZoneDidChange] {
            NotificationCenter.default.addObserver(self, selector: #selector(scheduleImageUpdate), name: name, object: nil)
        }
    }

    @objc private func scheduleImageUpdate() {
        Task { @MainActor [weak self] in
            self?.updateImage()
        }
    }

    private func updateImage() {
        statusItem.button?.image = MenuBarLabel.image(on: .now)
    }

    private var iconFrame: NSRect {
        guard let button = statusItem.button, let window = button.window else { return .zero }
        return window.convertToScreen(button.convert(button.bounds, to: nil))
    }

    private func frame() -> NSRect {
        let icon = iconFrame
        let width = PopUpContent.width
        var x = icon.midX - width / 2
        var height = PopUpContent.height
        if let screen = statusItem.button?.window?.screen?.visibleFrame {
            x = min(max(x, screen.minX + Self.screenMargin), screen.maxX - width - Self.screenMargin)
            height = min(height, icon.minY - Self.gap - screen.minY - Self.screenMargin)
        }
        return NSRect(x: x, y: icon.minY - Self.gap - height, width: width, height: height)
    }

    private func observeHere() {
        withObservationTracking {
            _ = Here.shared.timeZone
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.updateImage()
                self?.observeHere()
            }
        }
    }

    private func observeLayout() {
        withObservationTracking {
            _ = PopUpLayout.shared.contentHeight
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.resize()
                self?.observeLayout()
            }
        }
    }

    private func resize() {
        let frame = frame()
        guard panel.isVisible, panel.frame != frame else { return }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Self.resizeDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            panel.animator().setFrame(frame, display: true)
        }
    }

    private func show() {
        SettingsPage.shared.isShown = false
        moment.returnToNow()
        Task { await Here.shared.refresh() }
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
