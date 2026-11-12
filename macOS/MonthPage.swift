import CoreGraphics
import Observation

@MainActor
@Observable
final class MonthPage {
    static let shared = MonthPage()
    static let estimatedHeight: CGFloat = 230

    var isOpen = true
    var height = estimatedHeight

    var addedHeight: CGFloat {
        isOpen ? height : 0
    }
}
