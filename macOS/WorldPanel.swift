import SwiftUI

struct WorldPanel: View {
    private static let globeHeight: CGFloat = 240
    private static let searchHeight: CGFloat = 420

    let zones: ZoneList
    let moment: ChosenMoment

    @State private var isSearching = false
    @State private var layout = PopUpLayout.shared

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            if isSearching {
                CitySearchView { place in
                    zones.add(place)
                    isSearching = false
                }
                .frame(height: Self.searchHeight)
            } else {
                MonthCard(moment: moment)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                places
                Globe(places: zones.places, moment: moment)
                    .frame(height: Self.globeHeight)
                Divider()
                TimeScrubber(moment: moment)
            }
        }
    }

    private var header: some View {
        HStack {
            if isSearching {
                Text("Add a place")
                    .font(.headline)
            } else {
                DateTitle(moment: moment)
            }
            Spacer()
            Button {
                isSearching.toggle()
            } label: {
                Image(systemName: isSearching ? "xmark" : "plus")
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(isSearching ? "Cancel" : "Add a place")
        }
    }

    @ViewBuilder
    private var places: some View {
        if zones.places.isEmpty {
            Text("Add a place with the plus button")
                .foregroundStyle(.secondary)
                .padding(.vertical, 16)
        } else {
            ZoneListView(zones: zones, moment: moment, isExpanded: layout.isListExpanded)
            if zones.places.count > ZoneListView.collapsedCount {
                ListExpander(hiddenCount: zones.places.count - ZoneListView.collapsedCount, isExpanded: layout.isListExpanded) {
                    withAnimation(.snappy) { layout.isListExpanded.toggle() }
                }
            }
        }
    }
}
