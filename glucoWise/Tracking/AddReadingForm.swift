import SwiftUI

struct AddReadingView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("currentUserId") var userId: String = ""
    @State private var bloodSugarReading: String = ""
    @State private var selectedTime: Date
    @State private var selectedTag: BloodReadingType = .fasting
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let tags: [BloodReadingType] = [.fasting, .preMeal, .postMeal, .preWorkout, .postWorkout]
    let onSave: () -> Void
    
    init(selectedDate: Date = Date(), onSave: @escaping () -> Void = {}) {
        _selectedTime = State(initialValue: selectedDate)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Blood Sugar Reading")) {
                    TextField("Enter reading (0-600)", text: $bloodSugarReading)
                        .keyboardType(.numberPad)
                        .onChange(of: bloodSugarReading) { newValue in
                            // Remove any non-integer characters
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                bloodSugarReading = filtered
                            }
                            
                            // Check if the number exceeds 600
                            if let number = Int(filtered), number > 600 {
                                bloodSugarReading = "600"
                            }
                        }
                }
                
                Section(header: Text("Time of Reading")) {
                    DatePicker("Select Time", selection: $selectedTime, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Tag")) {
                    Picker("Select Tag", selection: $selectedTag) {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag.rawValue)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .navigationTitle("Add Reading")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let value = Int(bloodSugarReading) {
                            if value > 600 {
                                alertMessage = "Reading cannot exceed 600 mg/dL"
                                showAlert = true
                                return
                            }
                            if value < 0 {
                                alertMessage = "Reading cannot be negative"
                                showAlert = true
                                return
                            }
                            let newReading = BloodReading(type: selectedTag, value: Double(value), date: selectedTime)
                            UserManager.shared.addBloodReading(newReading, for: userId)
                            onSave()
                            dismiss()
                        } else {
                            alertMessage = "Please enter a valid number"
                            showAlert = true
                        }
                    }
                }
            }
            .alert("Invalid Input", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}
