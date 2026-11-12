import SwiftUI

struct WorldPanel: View {
    let zones: ZoneList
    let moment: ChosenMoment

    @State private var isSearching = false
    @State private var globeSize = GlobeSize.large
    @State private var handleDrag: CGFloat = 0

    private var globeHeight: CGFloat {
        GlobeSize.clamped(globeSize.height + handleDrag)
    }

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
