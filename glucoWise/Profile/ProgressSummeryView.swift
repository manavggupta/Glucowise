import SwiftUI

struct HbA1cEstimatorView: View {
    @State private var selectedDays: String = ""
    @State private var estimatedHbA1c: String = ""
    @AppStorage("currentUserId") var userId: String = ""
    private let userManager = UserManager.shared
    private let primaryColor = Color(hex: "#6cab9c")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Title
            Text("HbA1c Estimator")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            // Section: Average Glucose Level
            Text("Average Glucose Level")
                .font(.headline)
                .padding(.top, 8)
            
            GridView()
            
            // Section: Estimate HbA1c
            Text("Estimate my HbA1c")
                .font(.headline)
                .padding(.top, 8)
            
            // Input Field
            HStack {
                TextField("Enter number of days", text: $selectedDays)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(height: 44)
                
                Button(action: calculateHbA1c) {
                    Image(systemName: "calendar")
                        .foregroundColor(primaryColor)
                }
                .padding(.trailing, 8)
            }
            
            // HbA1c Output
            if !estimatedHbA1c.isEmpty {
                Text("Your estimated HbA1c is \(estimatedHbA1c)%")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
            
            // Disclaimer
            Text("This calculator provides an estimate of your HbA1c based on your average glucose levels over a period of time. Your actual HbA1c may vary from this estimate.")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 4)
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("HbA1c Estimator", displayMode: .inline)
    }
    
    // Function to calculate HbA1c
    private func calculateHbA1c() {
        guard let days = Int(selectedDays), days > 0 else {
            estimatedHbA1c = "Invalid input"
            return
        }
        
        let readings = fetchAverageGlucose(forDays: days)
        let hba1c = (readings + 46.7) / 28.7
        estimatedHbA1c = String(format: "%.1f", hba1c)
    }
    
    // Fetch past glucose readings
    private func fetchAverageGlucose(forDays days: Int) -> Double {
        let calendar = Calendar.current
        var total: Double = 0
        var count: Int = 0
        
        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let readings = userManager.getReadings(for: date, userId: userId)
                let dailyAverage = readings.map { $0.value }.reduce(0, +) / Double(readings.count)
                
                if !readings.isEmpty {
                    total += dailyAverage
                    count += 1
                }
            }
        }
        return count > 0 ? total / Double(count) : 0
    }
}

// Grid View for showing past 7, 14, 30, 60-day glucose levels
struct GridView: View {
    private let userManager = UserManager.shared
    private let daysList = [7, 14, 30, 60]
    @AppStorage("currentUserId") var userId: String = ""
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            ForEach(daysList, id: \.self) { days in
                VStack {
                    Text("\(days) days")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("\(fetchAverageGlucose(forDays: days)) mg/dL")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                .frame(width: 150, height: 80)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding(.top, 8)
    }
    
    // Fetch past glucose readings
    private func fetchAverageGlucose(forDays days: Int) -> String {
        let calendar = Calendar.current
        var total: Double = 0
        var count: Int = 0
        
        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let readings = userManager.getReadings(for: date, userId: userId)
                let dailyAverage = readings.map { $0.value }.reduce(0, +) / Double(readings.count)
                
                if !readings.isEmpty {
                    total += dailyAverage
                    count += 1
                }
            }
        }
        
        return count > 0 ? String(format: "%.0f", total / Double(count)) : "--"
    }
}

struct HbA1cEstimatorView_Previews: PreviewProvider {
    static var previews: some View {
        HbA1cEstimatorView()
    }
}
