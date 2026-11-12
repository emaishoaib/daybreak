import Foundation
import Observation

@MainActor
@Observable
final class ChosenMoment {
    enum State: Equatable {
        case live
        case chosen(Date)
    }

    private(set) var state = State.live

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
        return date.timeIntervalSince(Calendar.autoupdatingCurrent.startOfDay(for: date)) / 60
    }

    func choose(minutesIntoDay minutes: Double, at now: Date) {
        let start = Calendar.autoupdatingCurrent.startOfDay(for: date(at: now))
        state = .chosen(start.addingTimeInterval(minutes * 60))
    }

    func returnToNow() {
        state = .live
    }
}
