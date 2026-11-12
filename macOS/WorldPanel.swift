import SwiftUI

struct WorldPanel: View {
    let zones: ZoneList

    @State private var isSearching = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(isSearching ? "Add a place" : "World")
                    .font(.headline)
                Spacer()
                Button {
                    isSearching.toggle()
                } label: {
                    Image(systemName: isSearching ? "xmark" : "plus")
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(isSearching ? "Cancel" : "Add a place")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            content
        }
    }

    @ViewBuilder
    private var content: some View {
        if isSearching {
            CitySearchView { place in
                zones.add(place)
                isSearching = false
            }
        } else if zones.places.isEmpty {
            Text("Add a place with the plus button")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ZoneListView(zones: zones)
        }
    }
}
