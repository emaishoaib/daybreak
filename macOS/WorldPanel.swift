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
                TimeScrubber(moment: moment) {
                    AddPlaceButton {
                        isSearching = true
                    }
                }
                .padding(.top, -6)
                ZoneListView(zones: zones, moment: moment, isExpanded: layout.isListExpanded) { place in
                    flight = GlobeFlight(place: place)
                }
                if hiddenCount > 0 {
                    ShowMoreButton(hiddenCount: hiddenCount, isExpanded: layout.isListExpanded) {
                        withAnimation(.snappy) { layout.isListExpanded.toggle() }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 8)
                }
                Globe(places: zones.places, moment: moment, flight: flight)
                    .frame(height: Self.globeHeight)
                    .padding(.bottom, 8)
            }
        }
    }

    private var hiddenCount: Int {
        max(0, zones.places.count - ZoneListView.collapsedCount)
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
