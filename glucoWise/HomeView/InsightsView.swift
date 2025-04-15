import SwiftUI
import Charts

public struct InsightsView: View {
    let selectedDate: Date
    @AppStorage("currentUserId") var userId: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var contentSize: CGSize = .zero
    @State private var refreshTrigger = false
    
    public init(selectedDate: Date) {
        self.selectedDate = selectedDate
    }
    
    private var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter
    }()
    
    public var body: some View {
        let readings = UserManager.shared.getReadings(for: selectedDate, userId: userId)
        let lastReading = readings.last
        let averageReading = UserManager.shared.getAverage(for: selectedDate, userId: userId)
        let bloodSugarDifference = UserManager.shared.differenceBetweenBloodSugar(for: selectedDate, userId: userId) ?? 0
        
        NavigationView {
            ScrollView {
                VStack(spacing: 16) { // Added consistent spacing
                    // MARK: - Blood Glucose Summary
                    if let lastReading = lastReading {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Blood Glucose Level")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("\(averageReading, specifier: "%.1f") mg/dL")
                                .font(.system(size: 32, weight: .bold)) // More controlled size
                                .minimumScaleFactor(0.8) // Allow text to scale down
                            
                            HStack {
                                Text("\(bloodSugarDifference, specifier: "%.1f") mg/dL")
                                    .foregroundColor(Color(hex: "#6CAB9C"))
                                    .font(.footnote)
                                
                                Text("since yesterday")
                                    .foregroundColor(.gray)
                                    .font(.footnote)
                            }
                            
                            Text("Updated at \(formattedTime(from: lastReading.date))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal).offset(y: 10)
                        // MARK: - Blood Sugar Graph
                        BloodSugarGraphView(title: "Blood Sugar Trend", readings: readings)
                            .frame(width:380)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .padding(.horizontal).padding()
                        
                    } else {
                        VStack(spacing: 10) {
                            Text("No Readings Available")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text("Tap below to add a new reading")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                // Handle Add Reading Action
                            }) {
                                Text("Add Reading")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(hex: "6CAB9C"))
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 150)
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Today's Readings List
                    if !readings.isEmpty {
                        VStack {
                            Text("Today's Readings")
                                .font(.title3)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            ForEach(readings.reversed()) { reading in
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading) {
                                        Text(reading.type.rawValue)
                                            .font(.headline)
                                            .foregroundColor(Color(hex: "#6CAB9C"))
                                        
                                        Text(timeFormatter.string(from: reading.date))
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(reading.value, specifier: "%.0f")")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex: "#6CAB9C"))
                                    
                                    Text("mg/dL")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(12)
                                .frame(alignment:.center)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // MARK: - Insights Message
                    if !readings.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Get Insights")
                                .font(.title3)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                        }
                        VStack{
                            Text("Great job! Your blood glucose level is currently within a healthy range at \(averageReading, specifier: "%.0f") mg/dL. Keep up the consistent routine and make sure to log your meals and activity throughout the day to stay on track.")
                                .font(.body)
                                .foregroundColor(.gray)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: false) // Ensure text wraps
                        }.padding()
                        .frame(width:380)
                        .background(Color.white)
                        .cornerRadius(16).padding(.bottom ,20)
    
                    }
                }
                .background(Color(UIColor.systemGray6))
                .frame(width:400)
            }
            
        }
        .id(refreshTrigger)
        .onAppear {
            // Set up notification observer
            NotificationCenter.default.addObserver(forName: NSNotification.Name("BloodReadingAdded"), object: nil, queue: .main) { _ in
                refreshTrigger.toggle()
            }
        }
    }
}
// Preview Provider
struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView(selectedDate: Date())
    }
}
