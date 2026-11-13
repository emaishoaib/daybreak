import SwiftUI

struct WorldPanel: View {
    private static let globeHeight: CGFloat = 240
    private static let searchMotion = Animation.spring(duration: 0.4, bounce: 0.2)
    private static let searchSlide: CGFloat = 16

    let zones: ZoneList
    let moment: ChosenMoment

    @State private var isSearching = false
    @State private var placeListHeight: CGFloat = 0
    @State private var flight: GlobeFlight?
    @State private var layout = PopUpLayout.shared

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            if layout.isMonthOpen {
                MonthCard(moment: moment)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            ZStack(alignment: .top) {
                if isSearching {
                    CitySearchView { place in
                        zones.add(place)
                        withAnimation(Self.searchMotion) { isSearching = false }
                    } trailing: {
                        AddPlaceButtonSpace()
                    }
                    .frame(height: placeListHeight, alignment: .top)
                    .transition(.opacity.combined(with: .offset(y: Self.searchSlide)))
                } else {
                    placeList
                        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { placeListHeight = $0 }
                        .transition(.opacity.combined(with: .offset(y: -Self.searchSlide)))
                }
            }
            .overlay(alignment: .topTrailing) {
                AddPlaceButton(isOpen: isSearching) {
                    withAnimation(Self.searchMotion) { isSearching.toggle() }
                }
                .padding(.top, 10)
                .padding(.trailing, 16)
            }
            .padding(.top, -6)
            Globe(places: zones.places, moment: moment, flight: flight)
                .frame(height: Self.globeHeight)
                .padding(.bottom, 8)
        }
    }

    private var placeList: some View {
        VStack(spacing: 0) {
            TimeScrubber(moment: moment) {
                AddPlaceButtonSpace()
            }
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
        }
    }

    private var hiddenCount: Int {
        max(0, zones.places.count - ZoneListView.collapsedCount)
    }

    private var header: some View {
        HStack {
            DateButton(moment: moment, isOpen: layout.isMonthOpen) {
                withAnimation(.snappy) { layout.isMonthOpen.toggle() }
            }
            Spacer()
            SettingsButton()
        }
    }
}
