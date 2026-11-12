import SwiftUI

struct WorldPanel: View {
    private static let globeHeight: CGFloat = 240
    private static let searchHeight: CGFloat = 420

    let zones: ZoneList
    let moment: ChosenMoment

    @State private var isSearching = false
    @State private var flight: GlobeFlight?
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
                if layout.isMonthOpen {
                    MonthCard(moment: moment)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                ZoneListView(zones: zones, moment: moment, isExpanded: layout.isListExpanded) { place in
                    flight = GlobeFlight(place: place)
                }
                Globe(places: zones.places, moment: moment, flight: flight)
                    .frame(height: Self.globeHeight)
                    .overlay(alignment: .top) {
                        ListControls(
                            hiddenCount: max(0, zones.places.count - ZoneListView.collapsedCount),
                            isExpanded: layout.isListExpanded
                        ) {
                            withAnimation(.snappy) { layout.isListExpanded.toggle() }
                        } onAdd: {
                            isSearching = true
                        }
                    }
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
                Spacer()
                Button {
                    isSearching = false
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Cancel")
            } else {
                DateButton(moment: moment, isOpen: layout.isMonthOpen) {
                    withAnimation(.snappy) { layout.isMonthOpen.toggle() }
                }
                Spacer()
                SettingsButton()
            }
        }
    }
}
