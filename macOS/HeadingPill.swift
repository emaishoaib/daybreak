import SwiftUI

extension View {
    func headingPill() -> some View {
        font(.headline)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 6))
    }
}
