import SwiftUI

struct ForgetPasswordView: View {
    @State private var email: String = ""
    @State private var showAlert: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    // Email validation function
    private var isValidEmail: Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email) && !email.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Recover Password")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 50)
            
            VStack(spacing: 20) {
                // Email field
                TextField("Enter your email", text: $email)
                    .padding()
                    .frame(height: 55)
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled(true)
            }
            
            Spacer()
            
            // Recover button
            Button(action: {
                showAlert = true
            }) {
                HStack {
                    Spacer()
                    Text("Recover")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(isValidEmail ?
                    Color(red: 101/255, green: 175/255, blue: 158/255) :
                    Color(red: 101/255, green: 175/255, blue: 158/255).opacity(0.5))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .disabled(!isValidEmail)
            .padding(.bottom, 40)
        }
        .alert("Password Recovery", isPresented: $showAlert) {
            Button("OK") {
                dismiss() // This will take you back to the previous view (login)
            }
        } message: {
            Text("Password sent to your email: \(email)")
        }
    }
}

struct ForgetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgetPasswordView()
    }
}
