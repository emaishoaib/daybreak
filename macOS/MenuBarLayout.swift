import Foundation

enum MenuBarLayout: String, CaseIterable {
    static let key = "menuBarLayout"

    case horizontal
    case stacked
    case calendarPage

    static var current: MenuBarLayout {
        UserDefaults.standard.string(forKey: key).flatMap(MenuBarLayout.init) ?? .stacked
    }

    var name: String {
        switch self {
        case .horizontal: "Side by side"
        case .stacked: "Stacked"
        case .calendarPage: "Calendar page"
        }
    }
}
