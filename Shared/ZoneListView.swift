import SwiftUI
import WorldTimeKit

struct ZoneListView: View {
    static let collapsedCount = 3
    static let rowHeight: CGFloat = 46
    private static let maximumVisibleRows = 6

    let zones: ZoneList
    let moment: ChosenMoment
    let isExpanded: Bool
    let onSelect: (Place) -> Void

    var body: some View {
        let places = isExpanded ? zones.places : Array(zones.places.prefix(Self.collapsedCount))

        TimelineView(.everyMinute) { context in
            List {
                HereRow(date: moment.date(at: context.date))
                    .frame(height: Self.rowHeight)
                    .listRowInsets(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                ForEach(places) { place in
                    ZoneRow(place: place, date: moment.date(at: context.date))
                        .frame(height: Self.rowHeight)
                        .listRowInsets(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                        .listRowBackground(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { onSelect(place) }
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
            .frame(height: CGFloat(min(places.count, Self.maximumVisibleRows) + 1) * Self.rowHeight)
        }
    }
}
