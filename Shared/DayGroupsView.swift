import SwiftUI
import WorldTimeKit

struct DayGroupsView: View {
    let places: [Place]
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("At the chosen moment")
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(rows, id: \.dayDifference) { row in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(label(forDayDifference: row.dayDifference))
                        .fontWeight(.medium)
                        .frame(width: 56, alignment: .leading)
                    Text(row.names.joined(separator: ", "))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var rows: [(dayDifference: Int, names: [String])] {
        let groups = DayGroup.groups(of: places, from: .autoupdatingCurrent, at: date)
        var rows = groups.map { (dayDifference: $0.dayDifference, names: $0.places.map(\.name)) }
        if let index = rows.firstIndex(where: { $0.dayDifference == 0 }) {
            rows[index].names.insert("Here", at: 0)
        } else {
            rows.append((dayDifference: 0, names: ["Here"]))
            rows.sort { $0.dayDifference < $1.dayDifference }
        }
        return rows
    }

    private func label(forDayDifference difference: Int) -> String {
        let day = Calendar.autoupdatingCurrent.date(byAdding: .day, value: difference, to: date) ?? date
        return day.formatted(.dateTime.weekday(.abbreviated).day())
    }
}
