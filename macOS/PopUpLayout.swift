import CoreGraphics
import Foundation
import Observation

@MainActor
@Observable
final class PopUpLayout {
    static let shared = PopUpLayout()
    static let estimatedHeight: CGFloat = 790
    private static let listExpandedKey = "listExpanded"

    var contentHeight = estimatedHeight

    var isListExpanded = UserDefaults.standard.bool(forKey: listExpandedKey) {
        didSet { UserDefaults.standard.set(isListExpanded, forKey: Self.listExpandedKey) }
    }
}
