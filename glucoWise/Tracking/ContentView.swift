import SwiftUI
import Charts
import Foundation
struct TrackingView: View {
    @State private var selectedTab = "Blood Sugar"
    let tabs = ["Blood Sugar", "Meals", "Activity"]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Picker("", selection: $selectedTab) {
                    ForEach(tabs, id: \.self) { tab in
                        Text(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if selectedTab == "Blood Sugar" {
                    BloodSugarView()
                } else if selectedTab == "Meals" {
                    MealsView()
                } else if selectedTab == "Activity" {
                    HealthStatsView()
                }
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("Tracking")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct BloodSugarView: View {
    @AppStorage("currentUserId") var userId: String = ""
    @State private var selectedGraph = 0
    @State private var isShowingAddReading = false
    @State private var readings: [BloodReading] = [] // State variable for readings

    let graphOptions = ["Today", "Week", "Month"]

    var body: some View {
        VStack(alignment: .leading) {
            TabView(selection: $selectedGraph) {
                BloodSugarGraphView(title: "Today", readings: readings)
                    .tag(0)

                Text("Week Data Coming Soon").tag(1)
                Text("Month Data Coming Soon").tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: 250)

            HStack {
                Text("Readings")
                    .font(.headline)

                Spacer()

                Button(action: {
                    isShowingAddReading = true
                }) {
                    Text("Add Reading")
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .background(Color(hex: "6CAB9C"))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.top)

            List {
                            ForEach(readings.reversed()) { reading in
                                ReadingRow(
                                    title: reading.type.rawValue,
                                    time: BloodSugarView.timeFormatter.string(from: reading.date),
                                    value: "\(reading.value) mg/dL",
                                    onDelete: {
                                        deleteReading(reading)
                                    }
                                )
                                .padding(.horizontal)
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { index in
                                    let reading = readings.reversed()[index]
                                    deleteReading(reading)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
        }
        .onAppear {
            fetchReadings() // Refresh readings when the view appears
        }
        // In BloodSugarView, modify your sheet presentation:
        .sheet(isPresented: $isShowingAddReading, onDismiss: {
            fetchReadings() // This is good, but might not be enough
        }) {
            AddReadingView(onSave: {
                // This explicitly triggers the save action
                fetchReadings()
            })
        }
        
    }
    private static let timeFormatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateFormat = "h:mm a"
           return formatter
       }()
    private func deleteReading(_ reading: BloodReading) {
        UserManager.shared.deleteReading(reading, for: userId)
          fetchReadings() // This will refresh both the list and graph
      }
    func fetchReadings() {
        readings = UserManager.shared.getReadings(for: Date(), userId: userId) // Fetch latest readings
    }
}


struct BloodSugarGraphView: View {
    let title: String
    let readings: [BloodReading]
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding(.top)
            
            if readings.isEmpty {
                Text("No readings available for today.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Chart(readings) { reading in
                    LineMark(
                        x: .value("Time", reading.date),
                        y: .value("Blood Sugar", reading.value)
                    )
                    .foregroundStyle(Color(hex: "#6CAB9C"))
                    .symbol(Circle())
                }
                .chartXAxis {
                    AxisMarks(values: timeMarkers()) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel(formatTime(date)) // Format time labels
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(width: 350, height: 200)
                .padding()
            }
        }
    }

    /// Formats time labels for the x-axis
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a" // "6 AM", "12 PM", "6 PM", "12 AM"
        return formatter.string(from: date)
    }

    /// Returns fixed time markers (6 AM, 12 PM, 6 PM, 12 AM)
    private func timeMarkers() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        
        var components = calendar.dateComponents([.year, .month, .day], from: today)
        return [6, 12, 18, 24].compactMap { hour -> Date? in
            components.hour = hour
            components.minute = 0
            return calendar.date(from: components)
        }
    }
}


struct PageIndicator: View {
    @Binding var selectedIndex: Int
    let count: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(index == selectedIndex ? .black : .gray.opacity(0.5))
            }
        }
    }
}

struct ReadingRow: View {
    let title: String
    let time: String  // Now expects pre-formatted string
    let value: String
    var onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(time)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(value)
                .bold()
        }
        .padding()
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .background(Color.white)
    }
}
struct TrackingView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingView()
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

