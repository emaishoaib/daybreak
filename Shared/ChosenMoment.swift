import Foundation
import Observation

@MainActor
@Observable
final class ChosenMoment {
    private static let glideSeconds: TimeInterval = 0.45
    private static let longestGlideSeconds: TimeInterval = 24 * 60 * 60
    private static let glideFrame: Duration = .milliseconds(16)

    enum State: Equatable {
        case live
        case chosen(Date)
    }

    private(set) var state = State.live

    private var glide: Task<Void, Never>?

    var isLive: Bool {
        state == .live
    }

    func date(at now: Date) -> Date {
        switch state {
        case .live: now
        case .chosen(let date): date
        }
    }

    func minutesIntoDay(at now: Date) -> Double {
        let date = date(at: now)
        return date.timeIntervalSince(Here.shared.calendar.startOfDay(for: date)) / 60
    }

    func choose(minutesIntoDay minutes: Double, at now: Date) {
        let start = Here.shared.calendar.startOfDay(for: date(at: now))
        glide?.cancel()
        state = .chosen(start.addingTimeInterval(minutes * 60))
    }

    func choose(day: Date, at now: Date) {
        let calendar = Here.shared.calendar
        guard !(isLive && calendar.isDate(day, inSameDayAs: now)) else { return }
        let minutes = minutesIntoDay(at: now)
        glide?.cancel()
        state = .chosen(calendar.startOfDay(for: day).addingTimeInterval(minutes * 60))
    }

    func returnToNow() {
        glide?.cancel()
        state = .live
    }

    func glideToNow() {
        guard case .chosen(let from) = state, abs(from.timeIntervalSinceNow) < Self.longestGlideSeconds else { return returnToNow() }
        glide?.cancel()
        let start = Date.now
        glide = Task { [weak self] in
            while !Task.isCancelled {
                let now = Date.now
                let progress = min(now.timeIntervalSince(start) / Self.glideSeconds, 1)
                guard progress < 1 else {
                    self?.state = .live
                    return
                }
                let eased = progress * progress * (3 - 2 * progress)
                self?.state = .chosen(from.addingTimeInterval(now.timeIntervalSince(from) * eased))
                try? await Task.sleep(for: Self.glideFrame)
            }
        }
    }
}
