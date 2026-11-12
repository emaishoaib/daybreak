import SwiftUI
import WorldTimeKit

struct ZoneListView: View {
    static let collapsedCount = 3
    static let rowHeight: CGFloat = 46
    private static let maximumVisibleRows = 6
    private static let rowInsets = EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)

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
                    .contentShape(Rectangle())
                    .onTapGesture { onSelect(Here.shared.place) }
                    .listRowInsets(Self.rowInsets)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.blue.opacity(0.12))
                            .padding(.horizontal, 6)
                    )
                    .listRowSeparator(.hidden)
                ForEach(places) { place in
                    row(for: place, at: moment.date(at: context.date))
                    .frame(height: Self.rowHeight)
                    .listRowInsets(Self.rowInsets)
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

    private func row(for place: Place, at date: Date) -> ZoneRow {
        #if os(macOS)
        ZoneRow(place: place, date: date, isInMenuBar: zones.isInMenuBar(place)) {
            zones.toggleMenuBar(place)
        }
        #else
        ZoneRow(place: place, date: date)
        #endif
    }
}
