import SwiftUI

struct DailyReadingsView: View {
    @AppStorage("currentUserId") var userId: String = ""
    var selectedDate: Date
    @State private var readings: [BloodReading] = []  // ✅ Use @State

    init(selectedDate: Date) {
        self.selectedDate = selectedDate
    }

    var body: some View {
        VStack {
            Text("Blood Glucose Readings")
                .font(.title2)
                .bold()

            if readings.isEmpty {
                Text("No readings available for this date")
                    .foregroundColor(.gray)
            } else {
                List(readings) { reading in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(reading.type.rawValue)
                                .font(.headline)
                            Text("At \(formattedTime(from: reading.date))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("\(reading.value, specifier: "%.1f") mg/dL")
                            .font(.body)
                            .foregroundColor(reading.value > 180 ? .red : (reading.value > 120 ? .orange : .green))
                    }
                }
            }
        }
        .padding()
        .onAppear {
            readings = UserManager.shared.getReadings(for: selectedDate, userId: userId)  // ✅ Fetch dynamically
        }
    }
}
