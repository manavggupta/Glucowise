import SwiftUI

struct BloodSugarInputView: View {
    @State private var bloodSugar: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToHome = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Enter your last blood sugar level reading")
                .font(.system(size: 20, weight: .bold))
                .multilineTextAlignment(.center)
                .padding()
            
            HStack {
                TextField("120", text: $bloodSugar)
                    .keyboardType(.numberPad)
                    .frame(height: 50)
                    .padding(.leading, 15)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        HStack {
                            Spacer()
                            Text("mg/dL")
                                .foregroundColor(.gray)
                                .padding(.trailing, 15)
                        }
                    )
            }
            .frame(width: 350)
            
            Spacer()
        }
        .padding(.top, 50)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(bloodSugar.isEmpty ? "Skip" : "Done") {
                    if let value = Double(bloodSugar) {
                        // Update user's current blood sugar in UserManager
                        if let userIndex = UserManager.shared.getAllUsers().firstIndex(where: { $0.id == UserId }) {
                            var updatedUser = UserManager.shared.getAllUsers()[userIndex]
                            updatedUser.currentBloodSugar = value
                            UserManager.shared.updateUser(updatedUser)
                        }
                    }
                    navigateToHome = true
                }
            }
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            ContentView()
        }
    }
}

struct BloodSugarInputView_Previews: PreviewProvider {
    static var previews: some View {
        BloodSugarInputView()
    }
}
