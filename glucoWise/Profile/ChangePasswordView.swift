import SwiftUI

struct ChangePasswordView: View {
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isCurrentPasswordVisible: Bool = false
    @State private var isNewPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var isValidPassword: Bool {
        let passwordRegex = "^(?=.*[0-9])(?=.*[!@#$%^&*]).{5,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: newPassword)
    }
    
    var passwordsMatch: Bool {
        return newPassword == confirmPassword
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Current Password
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Password")
                    .font(.headline)
                
                HStack {
                    if isCurrentPasswordVisible {
                        TextField("Current Password", text: $currentPassword)
                    } else {
                        SecureField("Current Password", text: $currentPassword)
                    }
                    
                    Button(action: {
                        isCurrentPasswordVisible.toggle()
                    }) {
                        Image(systemName: isCurrentPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
            }
            
            // New Password
            VStack(alignment: .leading, spacing: 8) {
                Text("New Password")
                    .font(.headline)
                
                HStack {
                    if isNewPasswordVisible {
                        TextField("New Password", text: $newPassword)
                    } else {
                        SecureField("New Password", text: $newPassword)
                    }
                    
                    Button(action: {
                        isNewPasswordVisible.toggle()
                    }) {
                        Image(systemName: isNewPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
            }
            
            // Confirm New Password
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm New Password")
                    .font(.headline)
                
                HStack {
                    if isConfirmPasswordVisible {
                        TextField("Confirm New Password", text: $confirmPassword)
                    } else {
                        SecureField("Confirm New Password", text: $confirmPassword)
                    }
                    
                    Button(action: {
                        isConfirmPasswordVisible.toggle()
                    }) {
                        Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
            }
            
            // Error message
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            // Password requirements text
            Text("Your new password should be at least 5 characters long, contain at least one special symbol, and one number.")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 4)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    if isValidPassword && passwordsMatch {
                        showError = false
                        dismiss()
                    } else {
                        showError = true
                        errorMessage = !isValidPassword ? "Password must be at least 5 characters long, contain at least one special symbol, and one number." : "New password and confirm password must match."
                    }
                }
                .foregroundColor(isValidPassword && passwordsMatch ? .blue : .gray)
                .disabled(!isValidPassword || !passwordsMatch)
            }
        }
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChangePasswordView()
        }
    }
}
