import AppKit
import SwiftUI

@MainActor
enum MenuBarLabel {
    static func image(on date: Date) -> NSImage {
        let layout = MenuBarLayout.current
        let parts = MenuBarPart.shown
        guard layout == .calendarPage || !parts.isEmpty, let image = render(label(layout: layout, parts: parts, date: date)) else { return fallback }
        return image
    }

    private static var fallback: NSImage {
        let image = NSImage(systemSymbolName: "sun.horizon", accessibilityDescription: "Daybreak") ?? NSImage()
        image.isTemplate = true
        return image
    }

    private static func render(_ label: some View) -> NSImage? {
        let renderer = ImageRenderer(content: label.foregroundStyle(.black).fixedSize())
        renderer.scale = 2
        let image = renderer.nsImage
        image?.isTemplate = true
        return image
    }

    @ViewBuilder
    private static func label(layout: MenuBarLayout, parts: Set<MenuBarPart>, date: Date) -> some View {
        switch layout {
        case .horizontal:
            Text(date.formatted(style(for: parts)))
                .font(.system(size: 13, weight: .medium))
        case .stacked:
            let lowerParts = parts.subtracting([.weekday])
            StackedLabel(
                top: parts.contains(.weekday) ? date.formatted(style(for: [.weekday])) : nil,
                bottom: lowerParts.isEmpty ? nil : date.formatted(style(for: lowerParts))
            )
        case .calendarPage:
            CalendarPageLabel(date: date)
        }
    }

    private static func style(for parts: Set<MenuBarPart>) -> Date.FormatStyle {
        parts.reduce(Date.FormatStyle()) { style, part in
            switch part {
            case .weekday: style.weekday(.abbreviated)
            case .day: style.day()
            case .month: style.month(.abbreviated)
            }
        }
    }
}

private struct StackedLabel: View {
    let top: String?
    let bottom: String?

    var body: some View {
        VStack(spacing: -2.5) {
            if let top {
                Text(top)
                    .font(.system(size: 11.5, weight: .semibold))
            }
            if let bottom {
                Text(bottom)
                    .font(.system(size: 11.5))
            }
        }
    }
}

private struct CalendarPageLabel: View {
    let date: Date

    var body: some View {
        VStack(spacing: -2.5) {
            Text(date.formatted(.dateTime.month(.abbreviated)).uppercased())
                .font(.system(size: 6, weight: .bold))
            Text(date.formatted(.dateTime.day()))
                .font(.system(size: 10, weight: .semibold))
                .monospacedDigit()
        }
        .frame(width: 21, height: 19)
        .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(lineWidth: 1.2))
    }
}
