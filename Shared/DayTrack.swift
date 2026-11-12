import SwiftUI
import WorldTimeKit

struct DayTrack: View {
    private static let minutesPerDay: Double = 24 * 60
    private static let stepMinutes: Double = 15
    private static let handleSize: CGFloat = 22
    private static let labelledHours = [0, 6, 12, 18, 24]

    let dayStart: Date
    let minutes: Double
    let coordinate: Coordinate
    let onChange: (Double) -> Void

    var body: some View {
        VStack(spacing: 2) {
            GeometryReader { geometry in
                let travel = geometry.size.width - Self.handleSize
                ZStack(alignment: .leading) {
                    ForEach(0...24, id: \.self) { hour in
                        HourTick(isLong: hour % 6 == 0, isDaylight: isDaylight(atHour: hour))
                            .offset(x: Self.handleSize / 2 + travel * Double(hour) / 24 - HourTick.width / 2)
                    }
                    DayHandle(isDay: isDaylight(atMinute: minutes))
                        .frame(width: Self.handleSize, height: Self.handleSize)
                        .offset(x: travel * minutes / Self.minutesPerDay)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0).onChanged { value in
                        onChange(Self.snapped((value.location.x - Self.handleSize / 2) / travel * Self.minutesPerDay))
                    }
                )
            }
            .frame(height: Self.handleSize)
            HourLabels(hours: Self.labelledHours, inset: Self.handleSize / 2)
        }
        .accessibilityElement()
        .accessibilityLabel("Time of day")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: onChange(Self.snapped(minutes + Self.stepMinutes))
            case .decrement: onChange(Self.snapped(minutes - Self.stepMinutes))
            @unknown default: break
            }
        }
    }

    private func isDaylight(atHour hour: Int) -> Bool {
        isDaylight(atMinute: Double(hour) * 60)
    }

    private func isDaylight(atMinute minute: Double) -> Bool {
        Daylight(sunElevation: Sun.elevation(at: coordinate, on: dayStart.addingTimeInterval(minute * 60))) == .day
    }

    private static func snapped(_ minutes: Double) -> Double {
        min(max((minutes / stepMinutes).rounded() * stepMinutes, 0), minutesPerDay - stepMinutes)
    }
}

private struct HourTick: View {
    static let width: CGFloat = 1.5

    let isLong: Bool
    let isDaylight: Bool

    var body: some View {
        Capsule()
            .fill(isDaylight ? Color(white: 0.85) : Color(white: 0.32))
            .frame(width: Self.width, height: isLong ? 16 : 8)
    }
}

private struct HourLabels: View {
    let hours: [Int]
    let inset: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let travel = geometry.size.width - inset * 2
            ForEach(hours, id: \.self) { hour in
                Text("\(hour)")
                    .font(.caption2)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .position(x: inset + travel * Double(hour) / 24, y: geometry.size.height / 2)
            }
        }
        .frame(height: 12)
    }
}

private struct DayHandle: View {
    private static let iconSize: CGFloat = 11
    private static let horizonDrop: CGFloat = 16

    let isDay: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(white: 0.95))
            ZStack {
                if isDay {
                    icon("sun.max.fill", colour: .orange)
                        .transition(.asymmetric(insertion: Self.sunrise, removal: Self.sunset))
                } else {
                    icon("moon.fill", colour: .indigo)
                        .transition(.asymmetric(insertion: Self.moonrise, removal: Self.moonset))
                }
            }
            .clipShape(Circle())
        }
        .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
        .animation(.spring(duration: 0.55, bounce: 0.35), value: isDay)
    }

    private func icon(_ name: String, colour: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: Self.iconSize, weight: .semibold))
            .foregroundStyle(colour)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private static var sunrise: AnyTransition {
        .scale(scale: 0.2)
            .combined(with: .offset(y: horizonDrop))
            .combined(with: .modifier(active: Turned(degrees: -90), identity: Turned(degrees: 0)))
    }

    private static var sunset: AnyTransition {
        .scale(scale: 0.3)
            .combined(with: .offset(y: horizonDrop))
            .combined(with: .opacity)
    }

    private static var moonrise: AnyTransition {
        .offset(y: horizonDrop)
            .combined(with: .modifier(active: Turned(degrees: -40), identity: Turned(degrees: 0)))
    }

    private static var moonset: AnyTransition {
        .offset(y: horizonDrop)
            .combined(with: .opacity)
    }
}

private struct Turned: ViewModifier {
    let degrees: Double

    func body(content: Content) -> some View {
        content.rotationEffect(.degrees(degrees))
    }
}
