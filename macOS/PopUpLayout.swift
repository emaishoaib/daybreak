import CoreGraphics
import Foundation
import Observation

@MainActor
@Observable
final class PopUpLayout {
    static let shared = PopUpLayout()
    static let estimatedHeight: CGFloat = 790
    private static let listExpandedKey = "listExpanded"
    private static let monthOpenKey = "monthOpen"

    var contentHeight = estimatedHeight

    var isMonthOpen = UserDefaults.standard.object(forKey: monthOpenKey) as? Bool ?? true {
        didSet { UserDefaults.standard.set(isMonthOpen, forKey: Self.monthOpenKey) }
    }

    var isListExpanded = UserDefaults.standard.bool(forKey: listExpandedKey) {
        didSet { UserDefaults.standard.set(isListExpanded, forKey: Self.listExpandedKey) }
    }
}
