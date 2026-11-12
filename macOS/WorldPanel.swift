import SwiftUI

struct WorldPanel: View {
    let zones: ZoneList
    let moment: ChosenMoment

    @State private var isSearching = false
    @State private var month = MonthPage.shared
    @State private var globeSize = GlobeSize.large
    @State private var handleDrag: CGFloat = 0

    private var globeHeight: CGFloat {
        GlobeSize.clamped(globeSize.height + handleDrag)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            if !isSearching {
                if month.isOpen {
                    MonthDropDown(moment: moment)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 8)
                        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { month.height = $0 }
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                Globe(places: zones.places, moment: moment, showsTimes: GlobeSize.settled(at: globeHeight).showsTimes)
                    .frame(height: globeHeight)
                if !zones.places.isEmpty {
                    ListHandle()
                        .onTapGesture {
                            withAnimation(.snappy) { globeSize = globeSize.toggled }
                        }
                        .gesture(resize)
                }
            }
            content
            if !isSearching {
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
                DateButton(moment: moment, isOpen: month.isOpen) {
                    withAnimation(.snappy) { month.isOpen.toggle() }
                }
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

    private var resize: some Gesture {
        DragGesture()
            .onChanged { handleDrag = $0.translation.height }
            .onEnded { value in
                let settled = GlobeSize.settled(at: GlobeSize.clamped(globeSize.height + value.predictedEndTranslation.height))
                withAnimation(.snappy) {
                    globeSize = settled
                    handleDrag = 0
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
