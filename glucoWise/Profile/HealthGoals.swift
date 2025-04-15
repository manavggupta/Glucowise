import SwiftUI

struct HealthGoalsView: View {
    @State private var isShowingPicker = false
    @State private var pickerType: PickerType = .bloodSugar
    @State private var bloodSugarGoal: Int = 120
    @State private var bodyWeightGoal: Int = 75
    @State private var dailyActivityGoal: Int = 300
    @State private var weightManagementGoal: WeightManagement = .loseWeight

    enum PickerType {
        case bloodSugar, bodyWeight, dailyActivity, weightManagement
    }

    enum WeightManagement: String, CaseIterable {
        case loseWeight = "Lose Weight"
        case maintainWeight = "Maintain Weight"
        case gainWeight = "Gain Weight"
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Header with descriptive text
                VStack(alignment: .leading, spacing: 10) {
                    Text("Setting and tracking health goals is crucial for maintaining a healthy lifestyle. It helps you stay focused, motivated, and accountable.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }
                .padding(.horizontal)

                // List of goals
                VStack(spacing: 0) {
                    GoalRow(title: "Blood Sugar Level Goal", value: "\(bloodSugarGoal) mg/dL")
                        .onTapGesture {
                            pickerType = .bloodSugar
                            isShowingPicker = true
                        }

                    Divider().padding(.leading)

                    GoalRow(title: "Body Weight Goal", value: "\(bodyWeightGoal) kg")
                        .onTapGesture {
                            pickerType = .bodyWeight
                            isShowingPicker = true
                        }

                    Divider().padding(.leading)

                    GoalRow(title: "Daily Activity Goal", value: "Burn up to \(dailyActivityGoal) kcal")
                        .onTapGesture {
                            pickerType = .dailyActivity
                            isShowingPicker = true
                        }

                    Divider().padding(.leading)

                    GoalRow(title: "Weight Management Goal", value: weightManagementGoal.rawValue)
                        .onTapGesture {
                            pickerType = .weightManagement
                            isShowingPicker = true
                        }
                }
                .background(Color.white)

                Spacer()
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle("Health Goals")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                Group {
                    if isShowingPicker {
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                isShowingPicker = false
                            }

                        VStack {
                            Text(alertTitle())
                                .font(.headline)
                                .padding(.top)

                            if pickerType == .weightManagement {
                                Picker("", selection: $weightManagementGoal) {
                                    ForEach(WeightManagement.allCases, id: \.self) { option in
                                        Text(option.rawValue).tag(option)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(height: 150)
                                .clipped()
                            } else {
                                Picker("", selection: selectedValue()) {
                                    ForEach(pickerRange(), id: \.self) { value in
                                        Text("\(value) \(pickerUnit())").tag(value)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(height: 150)
                                .clipped()
                            }

                            Divider()

                            Button("Done") {
                                isShowingPicker = false
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.blue)
                        }
                        .frame(width: 300)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                    }
                }
            )
        }
    }

    private func alertTitle() -> String {
        switch pickerType {
        case .bloodSugar: return "Select Blood Sugar Goal"
        case .bodyWeight: return "Select Body Weight Goal"
        case .dailyActivity: return "Select Daily Activity Goal"
        case .weightManagement: return "Select Weight Goal"
        }
    }

    private func pickerRange() -> ClosedRange<Int> {
        switch pickerType {
        case .bloodSugar: return 70...200
        case .bodyWeight: return 30...200
        case .dailyActivity: return 100...1000
        case .weightManagement: return 0...0 // Not used for weight management
        }
    }

    private func pickerUnit() -> String {
        switch pickerType {
        case .bloodSugar: return "mg/dL"
        case .bodyWeight: return "kg"
        case .dailyActivity: return "kcal"
        case .weightManagement: return "" // No unit needed
        }
    }

    private func selectedValue() -> Binding<Int> {
        switch pickerType {
        case .bloodSugar: return $bloodSugarGoal
        case .bodyWeight: return $bodyWeightGoal
        case .dailyActivity: return $dailyActivityGoal
        case .weightManagement: return .constant(0) // Not used for weight management
        }
    }
}

// Goal Row View
struct GoalRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .contentShape(Rectangle())
        .background(Color.white)
    }
}

// Preview
struct HealthGoalsView_Previews: PreviewProvider {
    static var previews: some View {
        HealthGoalsView()
    }
}
