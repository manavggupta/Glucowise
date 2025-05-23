import SwiftUI

struct GoalsSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var userVM: UserViewModel
    @State private var weightGoal: String = "0"
    @State private var bloodGlucoseGoal: String = "0"
    @State private var hba1cGoal: String = "0"
    @State private var activityGoal: String = "0"
    @State private var navigateToBloodInput = false
    
    private let accentColor = Color(red: 108/255, green: 171/255, blue: 157/255)
    
    var body: some View {
        VStack(spacing: 20) {
            // Navigation trigger (hidden)
            NavigationLink(destination: BloodSugarInputView(), isActive: $navigateToBloodInput) {
                EmptyView()
            }

            // Goal Items
            goalItem(
                icon: "scalemass.fill",
                title: "Goal weight",
                subtitle: "Enter your ideal weight. (kg)",
                value: $weightGoal,
                isDecimal: false
            )
            
            goalItem(
                icon: "drop.fill",
                title: "Blood Glucose Levels",
                subtitle: "Enter blood sugar level goal. (mg/dL)",
                value: $bloodGlucoseGoal,
                isDecimal: false
            )
            
            goalItem(
                icon: "plusminus",
                title: "HbA1c Level",
                subtitle: "Enter HbA1c goal. (%)",
                value: $hba1cGoal,
                isDecimal: true
            )
            
            goalItem(
                icon: "figure.walk",
                title: "Activity Goal",
                subtitle: "Enter daily activity goal. (mins)",
                value: $activityGoal,
                isDecimal: false
            )
            
            Spacer()
        }
        .padding(.top, 20)
        .navigationTitle("Set Goals")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("Done") {
            saveUserAndNavigate()
        })
    }
    private func saveUserAndNavigate() {
        if let weight = Double(weightGoal), let bloodSugar = Double(bloodGlucoseGoal),
           let hba1c = Double(hba1cGoal), let activity = Int(activityGoal) {
            
            userVM.updateGoals(
                weight: weight,
                bloodSugar: bloodSugar,
                hba1c: hba1c,
                activityMinutes: activity
            )
            
            Task {
                do {
                    // 1. ✅ Sign up user in Supabase Auth
                    let authResponse = try await SupabaseManager.shared.client.auth.signUp(
                        email: userVM.emailId,
                        password: userVM.password
                    )
                    
                    // 2. ✅ Get UID from auth
                    let uid = authResponse.user.id.uuidString
                    userVM.id = uid // Set ID
                    
                    // Save userId to UserDefaults - THIS IS THE KEY ADDITION
                    UserDefaults.standard.set(uid, forKey: "currentUserId")
                    print("✅ User ID saved to UserDefaults: \(uid)")
                    
                    // 3. ✅ Create the user in your custom 'users' table
                    let user = userVM.toUserModel
                    try await SupabaseManager.shared.client.database
                        .from("users")
                        .insert([user])
                        .execute()
                    
                    print("✅ User registered and saved in DB!")
                    navigateToBloodInput = true
                } catch {
                    print("❌ Error: \(error)")
                }
            }
        }
    }

    
    private func goalItem(icon: String, title: String, subtitle: String, value: Binding<String>, isDecimal: Bool) -> some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(accentColor)
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            
            Spacer()
            
            HStack(spacing: 10) {
                TextField("", text: value)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 60, height: 36)
                    .background(Color.white)
                    .cornerRadius(8)
                    .keyboardType(.numberPad)
                    .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
                    .onChange(of: value.wrappedValue) { newValue in
                        value.wrappedValue = filterNumericInput(newValue, isDecimal: isDecimal)
                    }
            }
            .frame(width: 100)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private func filterNumericInput(_ input: String, isDecimal: Bool) -> String {
        let allowedCharacters = isDecimal ? "0123456789." : "0123456789"
        return input.filter { allowedCharacters.contains($0) }
    }
}

struct GoalsSetupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GoalsSetupView(userVM: UserViewModel())
        }
    }
}
