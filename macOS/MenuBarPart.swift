import Foundation

enum MenuBarPart: String, CaseIterable {
    case weekday
    case day
    case month

    static var shown: Set<MenuBarPart> {
        Set(allCases.filter(\.isShown))
    }

    var key: String {
        "menuBarShows.\(rawValue)"
    }

    var name: String {
        switch self {
        case .weekday: "Weekday"
        case .day: "Day"
        case .month: "Month"
        }
    }

    private var isShown: Bool {
        UserDefaults.standard.object(forKey: key) as? Bool ?? true
    }
}
