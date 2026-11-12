import SwiftUI

struct ZoneListView: View {
    let zones: ZoneList

    var body: some View {
        TimelineView(.everyMinute) { context in
            List {
                ForEach(zones.places) { place in
                    ZoneRow(place: place, date: context.date)
                        .listRowBackground(Color.clear)
                        .contextMenu {
                            Button("Remove", role: .destructive) {
                                zones.remove(place)
                            }
                        }
                }
                .onMove { zones.move(fromOffsets: $0, toOffset: $1) }
                .onDelete { zones.remove(atOffsets: $0) }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}
