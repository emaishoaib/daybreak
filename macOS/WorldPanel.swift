import SwiftUI

struct WorldPanel: View {
    private static let globeHeight: CGFloat = 240

    let zones: ZoneList
    let moment: ChosenMoment

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
            if !isSearching {
                Globe(places: zones.places, moment: moment)
                    .frame(height: Self.globeHeight)
            }
            content
            if !isSearching {
                Divider()
                TimeScrubber(moment: moment)
            }
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
            ZoneListView(zones: zones, moment: moment)
        }
    }
}
